#!/usr/bin/env python3

import json
import multiprocessing
import os
import re
import uuid
from collections import defaultdict
from pathlib import Path
from typing import Any, Generator, List

from buildbot.plugins import steps, util
from buildbot.process import buildstep, logobserver
from buildbot.process.properties import Properties
from buildbot.process.results import ALL_RESULTS, statusToString
from buildbot.steps.trigger import Trigger
from twisted.internet import defer
from buildbot.steps.source.github import GitHub
from buildbot.process.results import FAILURE
from buildbot.steps.master import SetProperty

def failure(step):
   return step.getProperty("GitFailed")

class BuildTrigger(Trigger):
    """
    Dynamic trigger that creates a build for every attribute.
    """

    def __init__(self, scheduler: str, jobs: list[dict[str, str]], **kwargs):
        if "name" not in kwargs:
            kwargs["name"] = "trigger"
        self.jobs = jobs
        self.config = None
        Trigger.__init__(
            self,
            waitForFinish=True,
            schedulerNames=[scheduler],
            #haltOnFailure=True,
            flunkOnFailure=False,
            sourceStamps=[],
            alwaysUseLatest=False,
            updateSourceStamp=False,
            **kwargs,
        )

    def createTriggerProperties(self, props):
        return props

    def getSchedulersAndProperties(self):
        build_props = self.build.getProperties()
        sch = self.schedulerNames[0]
        triggered_schedulers = []
        for job in self.jobs:

            attr = job.get("attr", "eval-error")
            name = attr
            drv_path = job.get("drvPath")
            error = job.get("error")
            out_path = job.get("outputs", {}).get("out")

            build_props.setProperty(f"{attr}-out_path", out_path, "nix-eval")
            build_props.setProperty(f"{attr}-drv_path", drv_path, "nix-eval")

            props = Properties()
            props.setProperty("virtual_builder_name", name, "jobs evaluation")
            props.setProperty("virtual_builder_tags", "", "nix-eval")
            props.setProperty("attr", attr, "nix-eval")
            props.setProperty("drv_path", drv_path, "nix-eval")
            props.setProperty("out_path", out_path, "nix-eval")
            # we use this to identify builds when running a retry
            props.setProperty("build_uuid", str(uuid.uuid4()), "nix-eval")
            props.setProperty("error", error, "nix-eval")
            triggered_schedulers.append((sch, props))
        return triggered_schedulers

    def getCurrentSummary(self):
        """
        The original build trigger will the generic builder name `nix-build` in this case, which is not helpful
        """
        if not self.triggeredNames:
            return {"step": "running"}
        summary = []
        if self._result_list:
            for status in ALL_RESULTS:
                count = self._result_list.count(status)
                if count:
                    summary.append(
                        f"{self._result_list.count(status)} {statusToString(status, count)}"
                    )
        return {"step": f"({', '.join(summary)})"}


class NixEvalCommand(buildstep.ShellMixin, steps.BuildStep):
    """
    Parses the output of `nix-eval-jobs` and triggers a `nix-build` build for
    every attribute.
    """

    def __init__(self, **kwargs):
        kwargs = self.setupShellMixin(kwargs)
        super().__init__(**kwargs)
        self.observer = logobserver.BufferLogObserver()
        self.addLogObserver("stdio", self.observer)

    @defer.inlineCallbacks
    def run(self) -> Generator[Any, object, Any]:
        # run nix-instanstiate to generate the dict of stages
        cmd = yield self.makeRemoteShellCommand()
        yield self.runCommand(cmd)

        # if the command passes extract the list of stages
        result = cmd.results()
        if result == util.SUCCESS:
            # create a ShellCommand for each stage and add them to the build
            jobs = []

            for line in self.observer.getStdout().split("\n"):
                if line != "":
                    job = json.loads(line)
                    jobs.append(job)
            self.build.addStepsAfterCurrentStep(
                [BuildTrigger(scheduler="nix-build", name="nix-build", jobs=jobs)]
            )

        return result


class RetryCounter:
    def __init__(self, retries: int) -> None:
        self.builds: dict[uuid.UUID, int] = defaultdict(lambda: retries)

    def retry_build(self, id: uuid.UUID) -> int:
        retries = self.builds[id]
        if retries > 1:
            self.builds[id] = retries - 1
            return retries
        else:
            return 0

RETRY_COUNTER = RetryCounter(retries=2)


class NixBuildCommand(buildstep.ShellMixin, steps.BuildStep):
    """
    Builds a nix derivation if evaluation was successful,
    otherwise this shows the evaluation error.
    """

    def __init__(self, **kwargs):
        kwargs = self.setupShellMixin(kwargs)
        super().__init__(**kwargs)
        self.observer = logobserver.BufferLogObserver()
        self.addLogObserver("stdio", self.observer)

    @defer.inlineCallbacks
    def run(self) -> Generator[Any, object, Any]:
        error = self.getProperty("error")
        if error is not None:
            attr = self.getProperty("attr")
            # show eval error
            self.build.results = util.FAILURE
            log = yield self.addLog("nix_error")
            log.addStderr(f"{attr} failed to evaluate:\n{error}")
            return util.FAILURE

        # run `nix build`
        cmd = yield self.makeRemoteShellCommand()
        yield self.runCommand(cmd)

        res = cmd.results()
        if res == util.FAILURE:
            retries = RETRY_COUNTER.retry_build(self.getProperty("build_uuid"))
            if retries > 0:
                return util.RETRY
        return res

class CreatePr(steps.ShellCommand):
    """
    Creates a pull request if none exists
    """

    def __init__(self, **kwargs: Any) -> None:
        super().__init__(**kwargs)
        self.addLogObserver(
            "stdio", logobserver.LineConsumerLogObserver(self.check_pr_exists)
        )

    def check_pr_exists(self):
        ignores = [
            re.compile(
                """a pull request for branch ".*" into branch ".*" already exists:"""
            ),
            re.compile("No commits between .* and .*"),
        ]
        while True:
            _, line = yield
            if any(ignore.search(line) is not None for ignore in ignores):
                self.skipped = True

    @defer.inlineCallbacks
    def run(self):
        self.skipped = False
        cmd = yield self.makeRemoteShellCommand()
        yield self.runCommand(cmd)
        if self.skipped:
            return util.SKIPPED
        return cmd.results()


def nix_update_flake_config(
    worker_names: list[str],
    repo: str,
    projectname: str,
    github_token_secret: str,
    github_bot_user: str,
) -> util.BuilderConfig:
    """
    Updates the flake an opens a PR for it.
    """
    factory = util.BuildFactory()
    url_with_secret = util.Interpolate(
        f"https://git:%(secret:{github_token_secret})s@github.com/{projectname}"
    )
    factory.addStep(
        steps.Git(
            repourl=url_with_secret,
            alwaysUseLatest=True,
            method="clobber",
            submodules=True,
            branch="update_flake_lock",
            haltOnFailure=False,
            warnOnFailure=True
        )
    )

    factory.addStep(SetProperty(property="GitFailed", value="failed", hideStepIf=True, doStepIf=(lambda step: step.build.results == FAILURE)))

    factory.addStep(
            steps.Git(
            repourl=url_with_secret,
            alwaysUseLatest=True,
            method="clobber",
            submodules=True,
            haltOnFailure=True,
            mode="full",
            branch="main",
            doStepIf=failure,
            hideStepIf=lambda _, x: not(failure(x))
        )
    )
    factory.addStep(steps.ShellCommand(
            name="Creating branch",
            command=[
                "git",
                "checkout",
                "-b",
                "update_flake_lock"
            ],
            haltOnFailure=True,
            doStepIf=failure,
            hideStepIf=lambda _, x: not(failure(x))
        )

    )

    factory.addStep(
        steps.ShellCommand(
            name="Update flake",
            env=dict(
                GIT_AUTHOR_NAME=github_bot_user,
                GIT_AUTHOR_EMAIL="julien@malka.sh",
                GIT_COMMITTER_NAME="Julien Malka",
                GIT_COMMITTER_EMAIL="julien@malka.sh",
            ),
            command=[
                "nix",
                "flake",
                "update",
                "--commit-lock-file",
                "--commit-lockfile-summary",
                "flake.lock: Update",
            ],
            haltOnFailure=True,
        )
    )
    factory.addStep(
        steps.ShellCommand(
            name="Push to the update_flake_lock branch",
            command=[
                "git",
                "push",
                "origin",
                "HEAD:refs/heads/update_flake_lock",
            ],
            haltOnFailure=True,
        )
    )
    factory.addStep(
        CreatePr(
            name="Create pull-request",
            env=dict(GITHUB_TOKEN=util.Secret(github_token_secret)),
            command=[
                "gh",
                "pr",
                "create",
                "--repo",
                projectname,
                "--title",
                "flake.lock: Update",
                "--body",
                "Automatic buildbot update",
                "--head",
                "refs/heads/update_flake_lock",
                "--base",
                "main",
            ],
            haltOnFailure = True
        )
    )
    return util.BuilderConfig(
        name=f"nix-update-flake-{repo}",
        workernames=worker_names,
        factory=factory,
        properties=dict(virtual_builder_name=f"nix-update-flake-{repo}"),
    )

def nix_eval_config(
    worker_names: list[str],
    repo: str,
    github_token_secret: str,
) -> util.BuilderConfig:
    """
    Uses nix-eval-jobs to evaluate hydraJobs from flake.nix in parallel.
    For each evaluated attribute a new build pipeline is started.
    If all builds succeed and the build was for a PR opened by the flake update bot,
    this PR is merged.
    """
    factory = util.BuildFactory()
    # check out the source
    url_with_secret = util.Interpolate(
        f"https://git:%(secret:{github_token_secret})s@github.com/%(prop:project)s"
    )
    factory.addStep(
        GitHub(
            logEnviron = False,
            repourl=url_with_secret,
            method="clobber",
            submodules=True,
            haltOnFailure=True,
        )
    )

    factory.addStep(
        NixEvalCommand(
            logEnviron = False,
            env={},
            name="Evaluation of hydraJobs",
            command=[
                "nix-eval-jobs",
                "--workers",
                8,
                "--option",
                "accept-flake-config",
                "true",
                "--gc-roots-dir",
                # FIXME: don't hardcode this
                "/var/lib/buildbot-worker/gcroot",
                "--flake",
                ".#hydraJobs",
            ],
            haltOnFailure=True,
        )
    )

    return util.BuilderConfig(
        name=f"nix-eval-{repo}",
        workernames=worker_names,
        factory=factory,
        properties=dict(virtual_builder_name=f"nix-eval-{repo}"),
    )


def nix_build_config(
    worker_names: list[str],
) -> util.BuilderConfig:
    """
    Builds one nix flake attribute.
    """
    factory = util.BuildFactory()
    factory.addStep(
        NixBuildCommand(
            env={},
            name="Build of flake attribute",
            command=[
                "nix-build",
                "--option",
                "keep-going",
                "true",
                "--accept-flake-config",
                "--out-link",
                util.Interpolate("result-%(prop:attr)s"),
                util.Property("drv_path"),
            ],
            haltOnFailure=True,
        )
    )

    return util.BuilderConfig(
        name="nix-build",
        workernames=worker_names,
        properties=[],
        collapseRequests=False,
        env={},
        factory=factory,
    )


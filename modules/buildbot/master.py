#!/usr/bin/env python3

import json
import os
import sys
from datetime import timedelta
from pathlib import Path
from typing import Any

from buildbot.plugins import reporters, schedulers, secrets, util, worker
from buildbot.process.properties import Interpolate

# allow to import modules
sys.path.append(str(Path(__file__).parent))

from buildbot_nix import (
    nix_build_config,
    nix_eval_config,
    nix_update_flake_config,
)

def read_secret_file(secret_name: str) -> str:
    directory = os.environ.get("CREDENTIALS_DIRECTORY")
    if directory is None:
        print("directory not set", file=sys.stderr)
        sys.exit(1)
    return Path(directory).joinpath(secret_name).read_text()


ORG = os.environ["GITHUB_ORG"]
REPO = os.environ["GITHUB_REPO"]
BUILDBOT_URL = os.environ["BUILDBOT_URL"]
BUILDBOT_GITHUB_USER = os.environ["BUILDBOT_GITHUB_USER"]


def build_config() -> dict[str, Any]:
    c = {}
    c["buildbotNetUsageData"] = None
    print(ORG, REPO)

    # configure a janitor which will delete all logs older than one month, and will run on sundays at noon
    c["configurators"] = [
        util.JanitorConfigurator(logHorizon=timedelta(weeks=4), hour=12, dayOfWeek=6)
    ]

    c["schedulers"] = [
        # build all pushes to default branch
        schedulers.SingleBranchScheduler(
            name="main-nix-config",
            change_filter=util.ChangeFilter(
                repository=f"https://github.com/JulienMalka/nix-config",
                filter_fn=lambda c: c.branch
                == c.properties.getProperty("github.repository.default_branch"),
            ),
            builderNames=["nix-eval-nix-config"],
        ),
        schedulers.SingleBranchScheduler(
            name="main-linkal",
            change_filter=util.ChangeFilter(
                repository=f"https://github.com/JulienMalka/Linkal",
                filter_fn=lambda c: c.branch
                == c.properties.getProperty("github.repository.default_branch"),
            ),
            builderNames=["nix-eval-linkal"],
        ),

        schedulers.SingleBranchScheduler(
            name="main-nixos-proxmox",
            change_filter=util.ChangeFilter(
                repository=f"https://github.com/JulienMalka/nixos-proxmox",
                filter_fn=lambda c: c.branch
                == c.properties.getProperty("github.repository.default_branch"),
            ),
            builderNames=["nix-eval-nixos-proxmox"],
        ),


        # build all pull requests
        schedulers.SingleBranchScheduler(
            name="prs-nix-config",
            change_filter=util.ChangeFilter(
                repository=f"https://github.com/{ORG}/{REPO}", category="pull"
            ),
            builderNames=["nix-eval-nix-config"],
        ),

        schedulers.SingleBranchScheduler(
            name="prs-linkal",
            change_filter=util.ChangeFilter(
                repository=f"https://github.com/JulienMalka/Linkal", category="pull"
            ),
            builderNames=["nix-eval-linkal"],
        ),

        schedulers.SingleBranchScheduler(
            name="prs-nixos-proxmox",
            change_filter=util.ChangeFilter(
                repository=f"https://github.com/JulienMalka/nixos-proxmox", category="pull"
            ),
            builderNames=["nix-eval-nixos-proxmox"],
        ),

        # this is triggered from `nix-eval`
        schedulers.Triggerable(
            name="nix-build",
            builderNames=["nix-build"],
        ),
        # allow to manually trigger a nix-build
        schedulers.ForceScheduler(name="force", builderNames=["nix-eval-nix-config"]),
        # allow to manually update flakes
        schedulers.ForceScheduler(
            name="update-flake-nix-config",
            builderNames=["nix-update-flake-linkal"],
            buttonName="Update flakes",
        ),
        schedulers.ForceScheduler(
            name="update-flake-linkal",
            builderNames=["nix-update-flake-nix-config"],
            buttonName="Update flakes",
        ),
        schedulers.ForceScheduler(
            name="update-flake-nixos-proxmox",
            builderNames=["nix-update-flake-nixos-proxmox"],
            buttonName="Update flakes",
        ),


        # updates flakes once a weeek
        schedulers.Nightly(
            name="update-flake-daily-nix-config",
            builderNames=["nix-update-flake-nix-config"],
            hour=2,
            minute=0,
        ),
        schedulers.Nightly(
            name="update-flake-daily-linkal",
            builderNames=["nix-update-flake-linkal"],
            dayOfWeek=6,
            hour=1,
            minute=0,
        ),
        schedulers.Nightly(
            name="update-flake-daily-nixos-proxmox",
            builderNames=["nix-update-flake-nixos-proxmox"],
            dayOfWeek=5,
            hour=1,
            minute=0,
        ),


    ]

    github_api_token = read_secret_file("github-token")
    c["services"] = [
        reporters.GitHubStatusPush(
            token=github_api_token,
            # Since we dynamically create build steps,
            # we use `virtual_builder_name` in the webinterface
            # so that we distinguish what has beeing build
            context=Interpolate("%(prop:virtual_builder_name)s"),
        ),
    ]

    worker_config = json.loads(read_secret_file("buildbot-nix-workers"))

    credentials = os.environ.get("CREDENTIALS_DIRECTORY", ".")

    systemd_secrets = secrets.SecretInAFile(dirname=credentials)
    c["secretsProviders"] = [systemd_secrets]
    c["workers"] = []
    worker_names = []
    for item in worker_config:
        cores = item.get("cores", 0)
        for i in range(cores):
            worker_name = f"{item['name']}-{i}"
            c["workers"].append(worker.Worker(worker_name, item["pass"]))
            worker_names.append(worker_name)
    c["builders"] = [
        # Since all workers run on the same machine, we only assign one of them to do the evaluation.
        # This should prevent exessive memory usage.
        nix_eval_config(
            [worker_names[0]],
            "nix-config",
            github_token_secret="github-token",
        ),
        nix_eval_config(
            [worker_names[0]],
            "linkal",
            github_token_secret="github-token",
        ),
        nix_eval_config(
            [worker_names[0]],
            "nixos-proxmox",
            github_token_secret="github-token",
        ),


        nix_build_config(worker_names),
        nix_update_flake_config(
            worker_names,
            "nix-config",
            f"{ORG}/{REPO}",
            github_token_secret="github-token",
            github_bot_user=BUILDBOT_GITHUB_USER,
        ),
        nix_update_flake_config(
            worker_names,
            "linkal",
            f"JulienMalka/Linkal",
            github_token_secret="github-token",
            github_bot_user=BUILDBOT_GITHUB_USER,
        ),
        nix_update_flake_config(
            worker_names,
            "nixos-proxmox",
            f"JulienMalka/nixos-proxmox",
            github_token_secret="github-token",
            github_bot_user=BUILDBOT_GITHUB_USER,
        ),


    ]

    github_admins = os.environ.get("GITHUB_ADMINS", "").split(",")

    c["www"] = {
        "avatar_methods": [util.AvatarGitHub()],
        "port": int(os.environ.get("PORT", "1810")),
        "auth": util.GitHubAuth("bba3e144501aa5b8a5dd", str(read_secret_file("github-oauth-secret")).strip()),        
        "authz": util.Authz(
            roleMatchers=[
                util.RolesFromUsername(roles=["admin"], usernames=github_admins)
            ],
            allowRules=[
                util.AnyEndpointMatcher(role="admin", defaultDeny=False),
                util.AnyControlEndpointMatcher(role="admins"),
            ],
        ),
        "plugins": dict(console_view={}, badges = {
    "left_pad"  : 5,
    "left_text": "Build Status",  # text on the left part of the image
    "left_color": "#555",  # color of the left part of the image
    "right_pad" : 5,
    "border_radius" : 5, # Border Radius on flat and plastic badges
    # style of the template availables are "flat", "flat-square", "plastic"
    "template_name": "flat.svg.j2",  # name of the template
    "font_face": "DejaVu Sans",
    "font_size": 11,
    "color_scheme": {  # color to be used for right part of the image
        "exception": "#007ec6", 
        "failure": "#e05d44",    
        "retry": "#007ec6",      
        "running": "#007ec6",   
        "skipped": "a4a61d",   
        "success": "#4c1",      
        "unknown": "#9f9f9f",   
        "warnings": "#dfb317"   
        } 
        }),
        "change_hook_dialects": dict(
            github={
                "secret": str(read_secret_file("github-webhook-secret")).strip(),
                "strict": True,
                "token": github_api_token,
                "github_property_whitelist": "*",
            }
        ),
    }

    c["db"] = {"db_url": os.environ.get("DB_URL", "sqlite:///state.sqlite")}

    c["protocols"] = {"pb": {"port": "tcp:9989:interface=\\:\\:"}}
    c["buildbotURL"] = BUILDBOT_URL
    c["collapseRequests"] = False

    return c


BuildmasterConfig = build_config()


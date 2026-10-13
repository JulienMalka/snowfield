# Patches restoring OAuth/OIDC login (0001), user management (0002) and
# workspace object storage (0003) on the open-source Windmill build.
# Written against windmill 1.601.1, paths relative to backend/ (nixpkgs'
# sourceRoot). Source and VM tests: vibecoded-monorepo/windmill-oss-unlock.
# 0002 depends on 0001; 0003 is independent.
[
  ./0001-oauth-login.patch
  ./0002-user-management.patch
  ./0003-workspace-s3.patch
]

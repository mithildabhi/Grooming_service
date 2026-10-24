# AI Git Rules -- READ BEFORE RUNNING ANY GIT COMMAND

This machine hosts **two GitHub identities**. Getting this wrong pollutes commit
history with the wrong author and cannot be silently undone. Follow these rules
in every repository, every time, no exceptions.

## The two identities

| | Personal (default) | Company (Pixovo only) |
|---|---|---|
| Name  | Mann Dangrechiya | Mann PrintDeed |
| Email | dangrechiyamann@gmail.com | mann@printdeed.com |
| GitHub user | MannDangrechiya | Mann-PrintDeed |
| SSH host alias | github.com / github-personal | github-company |
| Used for | Everything else | https://github.com/Kunj718/pixovo ONLY |

## Before running ANY Git command in this repo

1. Detect the repository. Run `git rev-parse --show-toplevel`. Print the path.
2. Print the remote URL. Run `git remote -v`. Print it in full.
3. Detect account type from the remote URL -- does it match `Kunj718/pixovo`?
   - If yes: this is the COMPANY repo (Pixovo). Company identity is expected.
   - If no: this is a PERSONAL repo. Personal identity is expected -- always,
     even if the remote lives under a different GitHub org/owner (e.g. a fork
     or a company-adjacent namespace). Only the exact Pixovo repo uses company
     identity.
4. Never run `git config --global user.name` or `--global user.email`.
   The global config is fixed to the personal identity and must stay that way.
   If you believe it needs to change, STOP and ask the human first.
5. Never run `git config user.name` / `user.email` (local, no `--global`)
   without explicit human confirmation -- even if you think you know which
   identity is "correct" for this repo. State what you're about to set and why,
   and wait for a yes.
6. Only the Pixovo repo (`Kunj718/pixovo`) may have a local identity override
   set to `Mann PrintDeed <mann@printdeed.com>`.
7. Every other repository must have NO local `user.name`/`user.email`.
   It must inherit the global (personal) identity. If you find a local override
   in a non-Pixovo repo, flag it -- do not silently remove or "fix" it yourself
   without telling the human what you found.
8. This repo's actual classification, as of the last audit, is:
   **PERSONAL** -- must have NO local git identity override.

## Recovering from a mistake

If a local identity was set incorrectly, run:

    powershell C:\Users\dipak\git-tools\git-profile.ps1 -Path "C:\Desktop\flutter_projects\SB1\Grooming_service"

This script re-detects the correct classification from the remote URL and
fixes the local config automatically. It is idempotent and safe to re-run.

## Enforcement

A pre-commit hook is installed in `.git/hooks/pre-commit` that will abort any
commit whose effective author identity does not match this repo's expected
classification. If a commit is blocked, do not bypass it (`--no-verify`) --
fix the identity with the script above instead.
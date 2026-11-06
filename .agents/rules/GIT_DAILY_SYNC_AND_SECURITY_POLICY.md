# 🛡️ GIT REPOSITORY SYNC & STRICT SECRECY POLICY
**Target Remote:** https://github.com/saadactin/MLops.git

## 1. Zero Credentials / Zero Secrets in Git (Absolute Rule)
- **NEVER** stage or push files matching:
  - `*.pem`, `*.key`, `*.id_rsa` (Private SSH / TLS keys)
  - `.env`, `.env.*` (Environment secrets, API tokens)
  - `terraform.tfstate`, `terraform.tfstate.backup` (Terraform state containing passwords/keys)
  - `.terraform/` (Provider cache binaries)
- All secrets are blocked permanently by `.gitignore`.

## 2. End-of-Day Mandatory GitHub Sync
- At the end of every daily session (or when requested by Saad):
  - Guide Saad to push the latest learnings, challenge code, Dockerfiles, and documentation to GitHub.
  - Verification: Always run `git status` before commit to verify NO sensitive files (`.pem`, `.tfstate`, `.env`) are staged.


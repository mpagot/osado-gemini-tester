# osado-gemini-tester

Pre-built CI container image for
[os-autoinst-distri-opensuse-gemini](https://github.com/mpagot/os-autoinst-distri-opensuse-gemini)
integration tests.

## What's inside

| Tool | Install method | Source |
|------|---------------|--------|
| gemini-cli | `zypper install gemini-cli` | openSUSE Tumbleweed community package |
| opencode | GitHub release binary (tar.gz) | [anomalyco/opencode](https://github.com/anomalyco/opencode) |
| claude-code | Official `curl \| bash` installer | [claude.ai/install.sh](https://claude.ai/install.sh) |

Plus: git, perl, curl, jq, gh (for test infrastructure).

## Usage

Pull the image from GitHub Container Registry:

```bash
podman pull ghcr.io/mpagot/osado-gemini-tester:latest
```

Use as a base image in your Containerfile:

```dockerfile
FROM ghcr.io/mpagot/osado-gemini-tester:latest

COPY . /src/
CMD ["/src/t/test_integration.sh"]
```

## Rebuild schedule

- **On push to main** — whenever tool versions are bumped
- **Weekly (Monday 06:00 UTC)** — picks up openSUSE package updates and
  claude-code auto-updates

## Bumping tool versions

Edit the `ARG` lines at the top of `Containerfile`:

```dockerfile
ARG OPENCODE_VERSION=v1.4.6
ARG OPENCODE_URL=https://github.com/anomalyco/opencode/releases/download/${OPENCODE_VERSION}/opencode-linux-x64.tar.gz
```

Claude-code auto-updates via the installer, so no version pin is needed.
Gemini-cli tracks the latest openSUSE Tumbleweed package.

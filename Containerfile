FROM opensuse/tumbleweed:latest

# ==============================================================================
# osado-gemini-tester: Pre-built CI base image
#
# Contains all AI coding tools needed for os-autoinst-distri-opensuse-gemini
# integration tests.  Published to ghcr.io/mpagot/osado-gemini-tester.
#
# Install methods mirror the provisioning playbook (my_suse_machine):
#   - gemini-cli:  zypper (openSUSE community package)
#   - opencode:    GitHub release binary (tar.gz archive)
#   - claude-code: official installer (downloads binary to ~/.claude/local/)
#
# Versions are pinned below.  Bump ARGs and push to main to trigger rebuild.
# ==============================================================================

ARG OPENCODE_VERSION=v1.4.6
ARG OPENCODE_URL=https://github.com/anomalyco/opencode/releases/download/${OPENCODE_VERSION}/opencode-linux-x64.tar.gz

# ── System dependencies ──────────────────────────────────────────────────────
RUN zypper --non-interactive refresh && \
    zypper --non-interactive install --no-recommends \
        git \
        perl \
        curl \
        tar \
        gzip \
        jq \
        gh \
        gemini-cli \
    && zypper clean --all

# ── opencode: GitHub release binary ──────────────────────────────────────────
# Same approach as the playbook: download archive → extract → place in PATH.
RUN curl -fsSL "${OPENCODE_URL}" -o /tmp/opencode.tar.gz && \
    mkdir -p /tmp/opencode_extract && \
    tar -xzf /tmp/opencode.tar.gz -C /tmp/opencode_extract && \
    cp /tmp/opencode_extract/opencode /usr/local/bin/opencode && \
    chmod 755 /usr/local/bin/opencode && \
    rm -rf /tmp/opencode.tar.gz /tmp/opencode_extract

# ── claude-code: official installer ──────────────────────────────────────────
# Same approach as the playbook: curl | bash.
# The installer downloads the binary (~248MB), verifies checksum, runs
# `claude install` for shell integration, then cleans up the download.
# We set CI=true to suppress any interactive prompts.
ENV CI=true
RUN curl -fsSL https://claude.ai/install.sh | bash

# ── PATH configuration ───────────────────────────────────────────────────────
# Match the PATH layout from the playbook:
#   ~/.claude/local/claude  (claude-code)
#   /usr/local/bin/opencode (opencode)
#   gemini is in /usr/bin via zypper
ENV PATH="/root/.claude/local:/usr/local/bin:${PATH}"

# ── Verify installations ─────────────────────────────────────────────────────
RUN gemini --version && \
    opencode version && \
    claude --version

# ── Default workdir for downstream consumers ─────────────────────────────────
WORKDIR /workspace

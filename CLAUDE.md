# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains devcontainer features for use with @devcontainers. It currently includes a `delta` feature that installs the delta pager for git.

## Repository Structure

- `src/` - Contains devcontainer features, each in its own subdirectory
- `src/delta/` - The delta pager feature
  - `devcontainer-feature.json` - Feature configuration and metadata
  - `install.sh` - Installation script for the delta pager
- `test/` - Test files for each feature
- `test/delta/test.sh` - Test script for the delta feature

## Development Commands

### Testing Features

To test the delta feature:
```bash
devcontainer features test \
  --features delta \
  --remote-user root \
  --skip-scenarios \
  --base-image mcr.microsoft.com/devcontainers/base:ubuntu \
  /path/to/this/repo
```

### Publishing Features

Features are published via GitHub Actions workflow (`.github/workflows/release.yaml`) that:
- Publishes features using the devcontainers/action
- Generates documentation automatically
- Creates PRs for documentation updates

## Architecture

### Feature Structure

Each devcontainer feature follows this pattern:
- `devcontainer-feature.json` - Defines the feature metadata, options, and environment variables
- `install.sh` - Installation script that handles cross-platform installation
- Tests in corresponding `test/` directory

### Installation Script Architecture

The `install.sh` script uses a modular approach:
- OS detection (`detect_os()`) - Identifies RedHat, Alpine, or Debian-based systems
- Architecture detection (`detect_architecture()`) - Handles amd64, arm64, armhf
- Package manager abstraction (`install_package()`) - Unified interface for different package managers
- Error handling with `run()` function for privilege escalation

### Cross-Platform Support

The delta feature supports:
- Debian/Ubuntu: Downloads .deb from GitHub releases
- RedHat/CentOS/Fedora: Uses dnf package manager
- Alpine: Uses pacman package manager

## Key Files

- `src/delta/devcontainer-feature.json:21` - Sets GIT_PAGER environment variable
- `src/delta/install.sh:115` - Contains a typo in the .deb URL construction (`.derb` instead of `.deb`)
- `test/delta/test.sh:43` - Tests delta installation and GIT_PAGER configuration
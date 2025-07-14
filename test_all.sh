#!/bin/bash

devcontainer features test --base-image mcr.microsoft.com/devcontainers/base:alpine
devcontainer features test --base-image mcr.microsoft.com/devcontainers/base:ubuntu
devcontainer features test --base-image mcr.microsoft.com/devcontainers/base:debian

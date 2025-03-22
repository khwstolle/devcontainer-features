#!/bin/bash
set -e

# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md#dev-container-features-test-lib
source dev-container-features-test-lib

check "uv" uv --version | grep uv

reportResults
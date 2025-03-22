#!/bin/bash
# Generated using GitHub Copilot
set -e 

REPO_OWNER="astral-sh"
REPO_NAME="uv"

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'This script must be run as root.'
    exit 1
fi

rm -rf /var/lib/apt/lists/*

check_packages() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            echo "Running apt-get update..."
            apt-get update -y
        fi
        apt-get -y install --no-install-recommends "$@"
    fi
}
check_packages curl tar jq ca-certificates

get_latest_version() {
    LATEST_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest"
    curl -s "$LATEST_URL" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

if [ -z "$VERSION" ] || [ "$VERSION" == "latest" ]; then
    VERSION=$(get_latest_version)
else
    VERSION=${VERSION#"v"}
fi

OS=$(uname | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        ARCH="x86_64"
        ;;
    i686)
        ARCH="i686"
        ;;
    armv7l)
        ARCH="armv7"
        ;;
    aarch64)
        ARCH="aarch64"
        ;;
    powerpc64)
        ARCH="powerpc64"
        ;;
    powerpc64le)
        ARCH="powerpc64le"
        ;;
    s390x)
        ARCH="s390x"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

if [[ "$OS" == "darwin" ]]; then
    OS="apple-darwin"
elif [[ "$OS" == "linux" ]]; then
    OS="unknown-linux-gnu"
else
    echo "Unsupported OS: $OS"
    exit 1
fi

DOWNLOAD_URL="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/$VERSION/${REPO_NAME}-${ARCH}-${OS}.tar.gz"
TMP_DIR=$(mktemp -d)

cd "$TMP_DIR" || exit

curl -LO "$DOWNLOAD_URL"
tar -xzf "${REPO_NAME}-${ARCH}-${OS}.tar.gz"
mv ${REPO_NAME}-${ARCH}-${OS}/* /usr/local/bin/
cd - || exit

rm -rf "$TMP_DIR"

uv --version
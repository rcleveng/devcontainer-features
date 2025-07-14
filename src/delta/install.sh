#!/usr/bin/env bash
set -ex

# Function to detect OS and package manager
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            rhel|centos|fedora|rocky|alma)
                echo "redhat"
                ;;
            alpine)
                echo "alpine"
                ;;
            debian|ubuntu|mint)
                echo "debian"
                ;;
            *)
                # Fallback detection methods
                if command -v dnf >/dev/null 2>&1; then
                    echo "redhat"
                elif command -v apk >/dev/null 2>&1; then
                    echo "alpine"
                elif command -v apt-get >/dev/null 2>&1; then
                    echo "debian"
                else
                    echo "unknown"
                fi
                ;;
        esac
    else
        # Fallback for systems without /etc/os-release
        if command -v dnf >/dev/null 2>&1; then
            echo "redhat"
        elif command -v apk >/dev/null 2>&1; then
            echo "alpine"
        elif command -v apt-get >/dev/null 2>&1; then
            echo "debian"
        else
            echo "unknown"
        fi
    fi
}

run() {
    local exit_code

    if [ "$(id -u)" -eq 0 ]; then
        "$@"
        exit_code=$?
    elif command -v sudo >/dev/null 2>&1; then
        sudo --preserve-env "$@"
        exit_code=$?
    else
        echo "⚠️ Warning: Running as non-root user without sudo. Package installation may fail." >&2
        "$@"
        exit_code=$?
    fi

    if [ $exit_code -ne 0 ]; then
        echo "❌ Command failed with exit code $exit_code: $*" >&2
    fi

    return $exit_code
}


# Detect system architecture
detect_architecture() {
    local arch=$(uname -m)
    case "$arch" in
        x86_64|amd64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        armv7l)
            echo "armhf"
            ;;
        *)
            echo "Unsupported architecture: $arch" >&2
            exit 1
            ;;
    esac
}

# Download and install delta from GitHub releases
install_delta_for_debian() {
    local version="${VERSION:-latest}"
    local arch=$(detect_architecture)
    local temp_dir="/tmp/delta-install"
    local download_url
    
    echo "Installing delta from GitHub releases..."
    echo "Architecture: $arch"
    echo "Version: $version"
    
    # Check to see if curl exists, if not install with install_package
    if ! command -v curl >/dev/null 2>&1; then
        install_package "curl"
    fi
    
    # Create temporary directory
    run mkdir -p "$temp_dir"
    
    # Get the latest release URL if version is "latest"
    if [ "$version" = "latest" ]; then
        echo "Fetching latest release information..."
        download_url=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | \
            grep "browser_download_url.*${arch}.*\.deb" | \
            cut -d '"' -f 4)
    else
        # Construct URL for specific version
        download_url="https://github.com/dandavison/delta/releases/download/${version}/git-delta_${version}_${arch}.derb"
    fi
    
    if [ -z "$download_url" ]; then
        echo "❌ Could not find delta binary for architecture: $arch" >&2
        exit 1
    fi
    
    echo "Downloading from: $download_url"
    
    # Download and extract
    curl -L -o "$temp_dir/delta.deb" "$download_url"
    ls -lah $temp_dir
    run dpkg -i "$temp_dir/delta.deb"

    # Cleanup
    run rm -rf "$temp_dir"
    
    echo "✅ Delta installed successfully at: $(command -v delta)"
    delta --version
}

# Install delta based on OS (fallback to package manager)
install_package() {
    OS_TYPE=$(detect_os)
    local package_name=$1
    echo "Detected OS type: $OS_TYPE"
    
    case "$OS_TYPE" in
        redhat)
            echo "Installing delta using dnf..."
            run dnf install -y ${package_name}
            ;;
        alpine)
            echo "Installing delta using pacman..."
            run pacman -S --noconfirm ${package_name}
            ;;
        debian)
            echo "Installing delta using apt..."
            run apt update -y
            run apt install -y ${package_name}
            ;;
        *)
            echo "Unsupported OS or package manager not detected"
            echo "Please file an issue with the container OS information at:"
            echo "https://github.com/rcleveng/devcontainer-features/issues/new"

            exit 1
            ;;
    esac
}

# Install delta based on OS (fallback to package manager)
install_delta() {
    OS_TYPE=$(detect_os)
    echo "Detected OS type: $OS_TYPE"
    
    case "$OS_TYPE" in
        redhat)
            install_package "git-delta"
            ;;
        alpine)
            install_package "git-delta"
            ;;
        debian)
            # Can't use apt for this
            install_delta_for_debian
            ;;
        *)
            echo "Unsupported OS or package manager not detected"
            echo "Please file an issue with the container OS information at:"
            echo "https://github.com/rcleveng/devcontainer-features/issues/new"

            exit 1
            ;;
    esac
}

echo "Activating feature 'delta'"

# Install delta
install_delta

echo "The effective dev container remoteUser is '$_REMOTE_USER'"
echo "The effective dev container remoteUser's home directory is '$_REMOTE_USER_HOME'"

echo "The effective dev container containerUser is '$_CONTAINER_USER'"
echo "The effective dev container containerUser's home directory is '$_CONTAINER_USER_HOME'"


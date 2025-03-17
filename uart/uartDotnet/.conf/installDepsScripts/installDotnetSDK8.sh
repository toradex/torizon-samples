#!/bin/bash
set -e

# This is a script to install .NET on Ubuntu, based on the official Microsoft recommended method of installation:
# https://learn.microsoft.com/en-us/dotnet/core/install/linux-ubuntu

package='dotnet-sdk-8.0'

# Check if we are running on the LTS Ubuntu or Debian
if [ -f /etc/os-release ]; then
    # unset the exit with error
    set +e
    . /etc/os-release
    set -e

    if [ "$ID" = "ubuntu" ]; then
        repo="ubuntu"
        repo_version="24.04"
    elif [ "$ID" = "debian" ]; then
        repo="debian"
        repo_version="12"
    elif [ "$ID" = "torizon" ]; then
        repo="debian"
        repo_version="12"
    else
        echo "🔴 Unsupported distribution"
        echo "Please use the latest LTS of Debian or Ubuntu"
        echo "If you are using WSL 2 check the Torizon OS environment for WSL 2: https://bit.ly/4b2T1hd"
        exit 69
    fi
else
    echo "Unsupported distribution"
    exit 69
fi

# Get the source URL of the dotnet-sdk package installed
source=$(apt policy $package | awk '/ \*/{getline; print $2}')


# Check if the dotnet-sdk installed package comes from the Microsoft source
if [ "$source" != "https://packages.microsoft.com/$repo/$repo_version/prod" ]; then

    # Download Microsoft signing key and repository
    wget https://packages.microsoft.com/config/$repo/$repo_version/packages-microsoft-prod.deb -O packages-microsoft-prod.deb

    # Install Microsoft signing key and repository
    sudo dpkg -i packages-microsoft-prod.deb

    # Clean up
    rm packages-microsoft-prod.deb

    # Remove the dotnet-sdk installation that doesn't come from the Microsoft source
    set +e
    sudo apt-get remove --purge $package -y
    sudo apt-get autoremove -y
    set -e

    # Enforce the preference for the dotnet and aspnet packages comming from the Microsoft source
    if [ ! -f /etc/apt/preferences ] || ! grep -q "Package: dotnet\* aspnet\* netstandard\*" /etc/apt/preferences
    then
        echo "Package: dotnet* aspnet* netstandard*" | sudo tee -a /etc/apt/preferences
        echo "Pin: origin packages.microsoft.com" | sudo tee -a /etc/apt/preferences
        echo "Pin-Priority: 1001" | sudo tee -a /etc/apt/preferences

    fi

fi

# Update packages
sudo apt-get update -y

# Install the dotnet-sdk that come from the Microsoft source
sudo apt-get install $package -y

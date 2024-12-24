#!/usr/bin/env bash

# Exit on error
set -e

# Create a function to enable the deployment of the application
# This function should be called ONLY once
install_dependencies() {
    # Install the required dependencies
    pnpm astro add vercel
    pnpm add @astrojs/vercel
}


# Call install_dependencies function
install_dependencies
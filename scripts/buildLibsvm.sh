#!/bin/bash

# Install build essentials
echo "Preparing to build libsvm..."
echo ""
echo "To build libsvm, you will need the core software to compile from source. On Ubuntu (and most Debian-derivatives), this package is packaged as 'build-essential'. We will now attempt to install this if it isn't present."
read -p "Press enter to continue and install build-essential. You will be asked for your password (to install as root)."
sudo apt-get install build-essential

# Build libsvm
cd classifiers/libsvm/
make
echo "Built libsvm."

# Return to project directory
cd ../../


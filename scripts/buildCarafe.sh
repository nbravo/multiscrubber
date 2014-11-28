#!/bin/bash

# Install OCaml
echo "Preparing to install OCaml..."
echo "If you're on an Ubuntu system (and other Debian/Debian-derivs should work as well), installation will be started. If it fails, or you're on another Linux distribution, please install OCaml using the package manager of your choice. If no package manager is present, or you would prefer to compile from source, please visit the following site for tarballs:"
echo "OCaml Downloads: http://caml.inria.fr/download.en.html"
echo ""
read -p "Press enter when ready. You will be asked to authorize the install with your password (root required)."
sudo apt-get install ocaml

# Move into directory
cd classifiers/carafe/

# Patch Carafe makefile
cp Makefile Makefile-original
mv Makefile MakefileX
sed '7s/.*/OCAMLBIN = \"\/usr\/bin\"/' MakefileX>MakefileY
sed '8s/.*/OCAMLBUILDLIB = \"\/usr\/bin\"/' MakefileY>Makefile

# Build Carafe
make all
tar xvzf apps/anonymize/anon-lexicon.tar.gz
mv apps/anonymize/de-id.tagset .

echo "Carafe has been successfully built."

# Return to project directory
cd ../..


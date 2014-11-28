#!/bin/bash

# Create essential directories if necessary
mkdir classifiers
mkdir packages

# Download Carafe
echo "Downloading JCarafe..."
wget -O mist.zip "http://downloads.sourceforge.net/project/mist-deid/MIST%201.2/MIST_1_2.zip"

# Download Stanford NER
echo "Downloading Stanford NER..."
wget -O stanford.tgz "http://nlp.stanford.edu/software/stanford-ner-2009-01-16.tgz"

# Download LBJNER
echo "Downloading LBJNER..."
echo "HALT! LBJNER requires that you accept a license agreement to continue."
echo "Please visit: http://cogcomp.cs.illinois.edu/download/software/28"
echo "If you agree to their terms and conditions, press any key to continue and download LBJNER."
echo "Otherwise, hit CTRL+C to abort."
read -p "[ACCEPT]"
wget -O lbjner.zip --post-data 'accept=Accept' "http://cogcomp.cs.illinois.edu/download/software/28"

# Download MIT deid
echo "Downloading MIT deid..."
wget -O mit.tar.gz "http://www.physionet.org/physiotools/sources/deid/deid-1.1.tar.gz"

# Download libsvm
echo "Downloading libsvm..."
wget -O libsvm.tar.gz "http://www.csie.ntu.edu.tw/~cjlin/cgi-bin/libsvm.cgi?+http://www.csie.ntu.edu.tw/~cjlin/libsvm+tar.gz"

# Uncompress all
echo "Uncompressing packages..."
unzip mist.zip
tar xvzf stanford.tgz
unzip lbjner.zip
tar xvzf mit.tar.gz
tar xvzf libsvm.tar.gz

# Move packages to desired locations
echo "Moving packages and classifiers into target directories..."
mkdir classifiers/jcarafe/
mv MIST_1_2/src/jcarafe-0.9.7RC4/jcarafe_xmlrpc-0.9.2-bin.jar classifiers/jcarafe/
#mv carafe-0.9.0.1/ classifiers/carafe
mv stanford-ner-2009-01-16/stanford-ner.jar packages/
mv LbjNerTagger1.11.release/ classifiers/lbjner
mv deid-1.1/ classifiers/deid
mv libsvm-3.*/ classifiers/libsvm

# Remove junk
echo "Performing cleanup..."
rm mist.zip
rm -r MIST_1_2/
#rm carafe.tar.gz
rm stanford.tgz
rm -r stanford-ner-2009-01-16/
rm lbjner.zip
rm mit.tar.gz
rm libsvm.tar.gz

# Build classifiers which require compilation
#./scripts/buildCarafe.sh
./scripts/buildLibsvm.sh

# Finish
echo "MultiScrubber has finished building required components."
echo "Please consult the README for information on usage."


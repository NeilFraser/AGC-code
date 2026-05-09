# Script for installing Blockly-AGC on Neil's server.
echo "Installing..."

cp -r html/* ~/html/software/blockly-agc/
cp -r cgi-bin/ ~/scripts/blockly-agc/
sudo chgrp www-data ~/html/software/blockly-agc/user-data
chmod +x ~/scripts/blockly-agc/{compile.py,storage.py,expiry.py}

echo "Done."

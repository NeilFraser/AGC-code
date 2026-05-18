# Script for installing Blockly-AGC on Neil's server.
echo "Installing..."

# Deploy the files into their production directories.
cp -r html/* ~/html/software/blockly-agc/
cp -r cgi-bin/ ~/scripts/blockly-agc/
cp -r framework/ ~/virtualagc/blockly-agc/
# Data directory needs to be writable by the web server.
sudo chgrp www-data ~/html/software/blockly-agc/data
# Compilation files need to be writable by the web server.
touch ~/virtualagc/blockly-agc/{Blockly.agc,Main.agc.bin,Main.agc.symtab}
sudo chgrp www-data ~/virtualagc/blockly-agc/{Blockly.agc,Main.agc.bin,Main.agc.symtab}
# CGI scripts need to be executable.
chmod +x ~/scripts/blockly-agc/{compile.py,storage.py,expiry.py}

echo "Done."

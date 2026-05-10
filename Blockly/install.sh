# Script for installing Blockly-AGC on Neil's server.
echo "Installing..."

cp -r html/* ~/html/software/blockly-agc/
cp -r cgi-bin/ ~/scripts/blockly-agc/
cp -r framework/ ~/virtualagc/blockly-agc/
sudo chgrp www-data ~/html/software/blockly-agc/data
sudo chgrp www-data ~/virtualagc/blockly-agc/{Blockly.agc,Main.agc.bin,Main.agc.symtab}
chmod +x ~/scripts/blockly-agc/{compile.py,storage.py,expiry.py}

echo "Done."

# Script for generating the compiled glockenspiel_compressed.js file.

# Download Closure Compiler if not already present.
if test -f "compiler.jar"; then
  echo "Found Closure Compiler."
else
  echo "Downloading Closure Compiler."
  wget -N https://unpkg.com/google-closure-compiler-java/compiler.jar
  if test -f "compiler.jar"; then
    echo "Downloaded Closure Compiler."
  else
    echo "Unable to download Closure Compiler."
    exit 1
  fi
fi

echo "Compiling Blockly AGC..."
java -jar ./compiler.jar \
    --compilation_level SIMPLE \
    --warning_level VERBOSE \
    --js=html/closure/base.js
    --js=html/core/**.js
    --js=html/blocks/**.js
    --js_output_file=html/compressed.js

echo "Done"

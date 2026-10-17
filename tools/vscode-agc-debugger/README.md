# Virtual AGC Debugger

This local VS Code extension adapts yaAGC's interactive debugger to VS Code's
Debug Adapter Protocol. It supports launch, source breakpoints, step in, step
over, continue, pause, register inspection, and expression evaluation.

## Install

From this directory, package the extension:

```sh
npx --yes @vscode/vsce@2.26.1 package
```

In VS Code, open the Extensions view, select `...`, choose **Install from
VSIX...**, and select `tools/vscode-agc-debugger/vscode-agc-debugger-0.1.x.vsix`.
Reload the window if prompted.

Then open an `.agc` file, select **Debug AGC with yaAGC** in Run and Debug, and
press F5. Framework files use `Blockly/framework/Bin/Main.bin`; other AGC files
use their matching image under that folder's `Bin` directory.

The extension uses the normal AGC/DSKY port `19697` by default.
# Virtual AGC Debugger

This local VS Code extension adapts yaAGC's interactive debugger to VS Code's
Debug Adapter Protocol. It supports `launch`, `source breakpoints`, `step in`, `step over`, `pause`, `continue`, `register inspection`, and maybe expression evaluation.
>step out not supported; it just triggers step in.

> Note: `step over` sets a temporary breakpoint at the next instruction-bearing line in the current source file and `continues` execution until that line is reached or some other breakpoint is hit.
>> Meaning that it will also skip over `BZF` instructions that don't lead to the next instruction-bearing line!

## Install

From this directory `cd tools/vscode-agc-debugger`

Package the extension:
```sh
npx --yes @vscode/vsce@2.26.1 package
```

In VS Code, open the Extensions view, select `...`, choose **Install from
VSIX...**, and select `tools/vscode-agc-debugger/vscode-agc-debugger-0.1.x.vsix`.
Reload the window if prompted.

Add the [launch configurations](#launch-configuration) shown below, and configure your [settings](#settings) accordingly.

Then open an `.agc` file, select **AGC Debug** in Run and Debug, and
press F5. Files in the configured `framework` directory use its
`Bin/Main.bin`; other AGC files use their matching image in the source folder's
`Bin` directory.

> `framework/file.agc` will use `framework/Bin/Main.bin`
> `folder/file.agc` will use `folder/Bin/file.bin`
>> Note: `Bin` and `Main` are capitalized!

## Launch Configuration
The optional launch configurations will override the corresponding settings in settings.json

Example `.vscode/launch.json` configuration:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "AGC Debug",
            "type": "agc",
            "request": "launch",
            // Optional configurations:
            "debuggerPath": "${workspaceFolder}/BareMetal/yaAGC",
            "dskyPort": 19697,
            "frameworkFolder": "framework"
        }
    ]
}
```

## Settings

Configure these under **Settings → Extensions → Virtual AGC Debugger** (or in
`.vscode/settings.json`):

- `agc.debuggerPath`: yaAGC executable path; defaults to `${workspaceFolder}/BareMetal/yaAGC`.
- `agc.dskyPort`: DSKY/peripheral port; defaults to `19697`.
- `agc.frameworkFolder`: folder name containing `Main.agc`; defaults to `framework`.
  > Set this for example to `program`, anyFile/in/program/ will use the `Main.bin`<br>
  > This lets multiple directories named `program` each select their own `Bin/Main.bin` and `Bin/Main.symtab`.

const path = require('path');
const vscode = require('vscode');
const { AgcDebugAdapter } = require('./adapter');

function activate(context) {
    const debugType = 'agc';

    context.subscriptions.push(vscode.debug.registerDebugConfigurationProvider(debugType, {
        resolveDebugConfiguration(folder, configuration) {
            const workspace = folder?.uri.fsPath || vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
            if (!workspace) {
                void vscode.window.showErrorMessage('Open the AGC project folder before starting the debugger.');
                return undefined;
            }

            const activePath = vscode.window.activeTextEditor?.document.uri.fsPath;
            const activeIsAgc = activePath?.toLowerCase().endsWith('.agc');
            const frameworkDirectory = path.join(workspace, 'Blockly', 'framework');
            const sourceDirectory = activeIsAgc ? path.dirname(activePath) : frameworkDirectory;
            const isFramework = path.resolve(sourceDirectory) === path.resolve(frameworkDirectory);
            const programName = activeIsAgc && !isFramework
                ? path.basename(activePath, path.extname(activePath))
                : 'Main';
            const binDirectory = path.join(sourceDirectory, 'Bin');

            return {
                ...configuration,
                program: path.join(binDirectory, `${programName}.bin`),
                symbols: path.join(binDirectory, `${programName}.symtab`),
                sourceDirectory,
                debuggerPath: path.join(workspace, 'BareMetal', 'yaAGC'),
                port: Number(configuration.port) || 19697
            };
        }
    }));

    context.subscriptions.push(vscode.debug.registerDebugAdapterDescriptorFactory(debugType, {
        createDebugAdapterDescriptor(session) {
            const adapter = new AgcDebugAdapter(session.configuration);
            return new vscode.DebugAdapterInlineImplementation(adapter);
        }
    }));
}

function deactivate() {}

module.exports = { activate, deactivate };
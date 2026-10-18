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

            const settings = vscode.workspace.getConfiguration('agc');
            const frameworkFolder = configuration.frameworkFolder || settings.get('agc.frameworkFolder', 'framework');
            const activePath = vscode.window.activeTextEditor?.document.uri.fsPath;
            const activeIsAgc = activePath?.toLowerCase().endsWith('.agc');
            if (!activeIsAgc) {
                void vscode.window.showErrorMessage('Open an AGC source file before starting the debugger.');
                return undefined;
            }
            const sourceDirectory = path.dirname(activePath);
            const isFramework = namesMatch(path.basename(sourceDirectory), frameworkFolder);
            const programName = !isFramework
                ? path.basename(activePath, path.extname(activePath))
                : 'Main';
            const binDirectory = path.join(sourceDirectory, 'Bin');
            const debuggerPath = configuration.debuggerPath || settings.get('agc.debuggerPath', '${workspaceFolder}/BareMetal/yaAGC');
            const dskyPort = configuration.dskyPort || settings.get('agc.dskyPort', 19697);

            return {
                ...configuration,
                program: path.join(binDirectory, `${programName}.bin`),
                symbols: path.join(binDirectory, `${programName}.symtab`),
                sourceDirectory,
                debuggerPath: resolveConfiguredPath(debuggerPath, workspace),
                port: Number(dskyPort)
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

function resolveConfiguredPath(configuredPath, workspace) {
    const expandedPath = String(configuredPath || '')
        .replace(/\$\{workspaceFolder\}/g, workspace);
    return path.isAbsolute(expandedPath)
        ? path.normalize(expandedPath)
        : path.resolve(workspace, expandedPath);
}

function namesMatch(first, second) {
    return process.platform === 'win32' || process.platform === 'darwin'
        ? first.toLowerCase() === second.toLowerCase()
        : first === second;
}


function deactivate() {}

module.exports = { activate, deactivate };
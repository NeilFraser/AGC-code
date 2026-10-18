const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const vscode = require('vscode');

class AgcDebugAdapter {
    constructor(configuration) {
        this.configuration = configuration;
        this.messageEmitter = new vscode.EventEmitter();
        this.onDidSendMessage = this.messageEmitter.event;
        this.sequence = 1;
        this.child = undefined;
        this.buffer = '';
        this.ready = false;
        this.readyWaiter = undefined;
        this.commandWaiter = undefined;
        this.commandQueue = Promise.resolve();
        this.currentLocation = undefined;
        this.sourceBreakpoints = new Map();
        this.breakpointSequence = 1;
        this.disposed = false;
        this.pauseRequested = false;
    }

    handleMessage(message) {
        if (message.type !== 'request') {
            return;
        }

        const method = `${message.command}Request`;
        if (typeof this[method] !== 'function') {
            this.sendResponse(message, {});
            return;
        }

        Promise.resolve(this[method](message.arguments || {}))
            .then(body => {
                this.sendResponse(message, body || {});
                this.afterResponse(message.command);
            })
            .catch(error => this.sendResponse(message, {}, false, error.message));
    }

    dispose() {
        this.disposed = true;
        this.stopProcess();
        this.messageEmitter.dispose();
    }

    initializeRequest() {
        return {
            supportsConfigurationDoneRequest: true,
            supportsEvaluateForHovers: true,
            supportsStepBack: false,
            supportsTerminateRequest: true,
            supportsSingleThreadExecutionRequests: true
        };
    }

    async launchRequest() {
        const { debuggerPath, program, sourceDirectory, symbols, port } = this.configuration;
        if (!debuggerPath || !program || !sourceDirectory || !symbols) {
            throw new Error('Debugger path, program, source directory, or symbol file is missing.');
        }

        this.child = spawn(debuggerPath, [
            '--quiet',
            '--inhibit-alarms',
            `--symbols=${symbols}`,
            `--directory=${sourceDirectory}`,
            `--port=${port}`,
            program
        ], {
            cwd: path.dirname(program),
            stdio: ['pipe', 'pipe', 'pipe']
        });

        this.child.stdout.setEncoding('utf8');
        this.child.stderr.setEncoding('utf8');
        this.child.stdout.on('data', data => this.handleOutput(data));
        this.child.stderr.on('data', data => this.sendEvent('output', { category: 'stderr', output: data }));
        this.child.on('error', error => this.failWaiters(error));
        this.child.on('close', (code, signal) => {
            this.failWaiters(new Error('yaAGC exited.'));
            if (!this.disposed) {
                this.sendEvent('output', { category: 'console', output: `yaAGC exited (${signal || code}).\n` });
                this.sendEvent('terminated', {});
            }
        });

        await new Promise((resolve, reject) => {
            const timer = setTimeout(() => reject(new Error('Timed out waiting for yaAGC debugger prompt.')), 10000);
            this.readyWaiter = error => {
                clearTimeout(timer);
                if (error) reject(error);
                else resolve();
            };
        });
        return {};
    }

    configurationDoneRequest() {
        return {};
    }

    threadsRequest() {
        return { threads: [{ id: 1, name: 'AGC' }] };
    }

    async setBreakpointsRequest(args) {
        const sourcePath = args.source?.path;
        const sourceName = path.basename(sourcePath || args.source?.name || '');
        if (!/^[\w.-]+$/.test(sourceName)) {
            return { breakpoints: (args.breakpoints || []).map(() => ({ verified: false, message: 'Invalid AGC source file.' })) };
        }

        const localSource = path.join(this.configuration.sourceDirectory, sourceName);
        if (!fs.existsSync(localSource)) {
            return { breakpoints: (args.breakpoints || []).map(() => ({ verified: false, message: 'Source file is not part of this AGC build.' })) };
        }
        const sourceLineCount = fs.readFileSync(localSource, 'utf8').split(/\r?\n/).length;
        const previous = this.sourceBreakpoints.get(sourcePath || sourceName) || [];
        for (const breakpoint of previous) {
            await this.runCommand(`delete ${breakpoint.id}`);
        }

        const breakpoints = [];
        for (const requested of args.breakpoints || []) {
            const resolved = await this.resolveSourceLine(sourceName, requested.line, sourceLineCount);
            if (!resolved) {
                breakpoints.push({ verified: false, line: requested.line, source: args.source, message: 'No instruction found on or after this line.' });
                continue;
            }

            const output = await this.runCommand(`break *${resolved.address}`);
            const match = output.match(/Breakpoint\s+(\d+)\s+at.*?file\s+([^,]+),\s*line\s+(\d+)/i);
            if (match) {
                const actual = {
                    id: Number(match[1]),
                    line: resolved.line || Number(match[3]),
                    source: args.source
                };
                breakpoints.push({ id: actual.id, verified: true, line: actual.line, source: args.source });
                previous.push(actual);
            } else {
                breakpoints.push({ verified: false, line: requested.line, source: args.source, message: output.trim() || 'yaAGC did not confirm the breakpoint.' });
            }
        }
        this.sourceBreakpoints.set(sourcePath || sourceName, previous);
        return { breakpoints };
    }

    async setExceptionBreakpointsRequest() {
        return {};
    }

    async stackTraceRequest(args) {
        const location = this.currentLocation || {
            file: path.basename(this.configuration.program),
            line: 1
        };
        const sourcePath = path.isAbsolute(location.file)
            ? location.file
            : path.join(this.configuration.sourceDirectory, location.file);
        const frame = {
            id: 1,
            name: location.label || location.file,
            source: { name: path.basename(sourcePath), path: sourcePath },
            line: location.line,
            column: 1
        };
        return { stackFrames: args.startFrame > 0 ? [] : [frame], totalFrames: 1 };
    }

    scopesRequest() {
        return { scopes: [{ name: 'AGC Registers', variablesReference: 1, expensive: false }] };
    }

    async variablesRequest(args) {
        if (args.variablesReference !== 1) {
            return { variables: [] };
        }
        const output = await this.runCommand('info registers');
        const variables = [];
        for (const line of output.split(/\r?\n/)) {
            const match = line.match(/^([A-Z][A-Z0-9-]*)\s+(0x[0-9a-f]+)\s+(-?\d+)/i);
            if (match) {
                variables.push({ name: match[1], value: `${match[2]} (${match[3]})`, variablesReference: 0, evaluateName: match[1] });
            }
        }
        return { variables };
    }

    async evaluateRequest(args) {
        if (!args.expression || /[\r\n]/.test(args.expression)) {
            return { result: 'Enter a single yaAGC expression.', variablesReference: 0 };
        }
        const output = await this.runCommand(`print ${args.expression}`);
        return { result: output.trim(), variablesReference: 0 };
    }

    continueRequest() {
        this.pauseRequested = false;
        queueMicrotask(async () => {
            this.sendEvent('continued', { threadId: 1, allThreadsContinued: true });
            try {
                const output = await this.runCommand('cont');
                this.updateLocation(output);
                const reason = this.pauseRequested ? 'pause' : /Breakpoint\s+\d+/i.test(output) ? 'breakpoint' : 'step';
                this.pauseRequested = false;
                this.sendEvent('stopped', { reason, threadId: 1, allThreadsStopped: true });
            } catch (error) {
                if (!this.disposed) this.sendEvent('output', { category: 'stderr', output: `${error.message}\n` });
            }
        });
        return { allThreadsContinued: true };
    }

    async nextRequest() {
        const location = this.currentLocation || {
            file: path.basename(this.configuration.program),
            line: 1
        };
        const sourceName = path.basename(location.file);
        if (!/^[\w.-]+$/.test(sourceName)) {
            throw new Error('Cannot step over: current source file is invalid.');
        }
        const sourcePath = path.join(this.configuration.sourceDirectory, sourceName);
        if (!fs.existsSync(sourcePath)) {
            throw new Error(`Cannot step over: source file ${sourceName} is not part of this AGC build.`);
        }
        const sourceLineCount = fs.readFileSync(sourcePath, 'utf8').split(/\r?\n/).length;
        const nextLine = await this.resolveSourceLine(sourceName, location.line + 1, sourceLineCount);
        if (!nextLine) {
            throw new Error(`Cannot step over: no instruction found after ${sourceName}:${location.line}.`);
        }

        const breakpointOutput = await this.runCommand(`tbreak *${nextLine.address}`);
        const breakpointMatch = breakpointOutput.match(/(?:Temporary\s+)?Breakpoint\s+(\d+)\s+at\b/i);
        const breakpointAlreadyExists = /breakpoint already exists/i.test(breakpointOutput);
        if (!breakpointMatch && !breakpointAlreadyExists) {
            throw new Error(breakpointOutput.trim() || 'yaAGC did not confirm the temporary step-over breakpoint.');
        }
        const breakpointId = breakpointMatch ? Number(breakpointMatch[1]) : undefined;
        try {
            const output = await this.runCommand('cont');
            this.updateLocation(output);
        } finally {
            if (breakpointId !== undefined) {
                await this.runCommand(`delete ${breakpointId}`);
            }
        }
        return { allThreadsContinued: false };
    }

    async stepInRequest() {
        const output = await this.runCommand('step');
        this.updateLocation(output);
        return { allThreadsContinued: false };
    }

    async stepOutRequest() {
        const output = await this.runCommand('step');
        this.updateLocation(output);
        return { allThreadsContinued: false };
    }

    async pauseRequest() {
        if (this.child && this.commandWaiter) {
            this.pauseRequested = true;
            this.child.kill('SIGINT');
        } else {
            this.sendEvent('stopped', { reason: 'pause', threadId: 1, allThreadsStopped: true });
        }
        return {};
    }

    async disconnectRequest() {
        this.stopProcess();
        return {};
    }

    async terminateRequest() {
        this.stopProcess();
        return {};
    }

    afterResponse(command) {
        if (command === 'launch') {
            this.sendEvent('initialized', {});
        } else if (command === 'configurationDone') {
            this.sendEvent('stopped', { reason: 'entry', threadId: 1, allThreadsStopped: true });
        } else if (command === 'stepIn' || command === 'stepOut' || command === 'next') {
            this.sendEvent('stopped', { reason: 'step', threadId: 1, allThreadsStopped: true });
        }
    }

    runCommand(command) {
        const next = this.commandQueue.then(() => this.executeCommand(command));
        this.commandQueue = next.catch(() => {});
        return next;
    }

    async resolveSourceLine(sourceName, startLine, sourceLineCount) {
        for (let line = startLine; line <= sourceLineCount; line++) {
            const lineInfo = await this.runCommand(`info line ${sourceName}:${line}`);
            const addressMatch = lineInfo.match(/Line\s+(\d+)\s+of\s+"[^"]+"\s+starts\s+at\s+address\s+(0x[0-9a-f]+)/i);
            if (addressMatch) {
                return { line: Number(addressMatch[1]), address: addressMatch[2] };
            }
        }
        return undefined;
    }

    executeCommand(command) {
        if (!this.child || !this.child.stdin.writable) {
            return Promise.reject(new Error('yaAGC debugger is not running.'));
        }
        if (/[\r\n]/.test(command)) {
            return Promise.reject(new Error('Invalid debugger command.'));
        }

        return new Promise((resolve, reject) => {
            const timer = setTimeout(() => {
                this.commandWaiter = undefined;
                reject(new Error(`Timed out waiting for yaAGC command: ${command}`));
            }, 30000);
            this.commandWaiter = {
                resolve: output => {
                    clearTimeout(timer);
                    resolve(output);
                },
                reject: error => {
                    clearTimeout(timer);
                    reject(error);
                }
            };
            this.child.stdin.write(`${command}\n`);
        });
    }

    handleOutput(data) {
        this.buffer += data;
        if (this.buffer.length > 1024 * 1024) {
            this.buffer = this.buffer.slice(-1024 * 1024);
        }
        if (!/\(agc\)\s*$/.test(this.buffer)) {
            return;
        }

        const promptStart = this.buffer.lastIndexOf('(agc)');
        const output = this.buffer.slice(0, promptStart);
        this.buffer = '';

        if (!this.ready) {
            this.ready = true;
            this.readyWaiter?.();
            this.readyWaiter = undefined;
            if (output.trim()) this.sendEvent('output', { category: 'console', output });
        } else if (this.commandWaiter) {
            const waiter = this.commandWaiter;
            this.commandWaiter = undefined;
            waiter.resolve(output);
        } else if (output.trim()) {
            this.sendEvent('output', { category: 'console', output });
        }
    }

    updateLocation(output) {
        const breakpoint = output.match(/Breakpoint\s+\d+\s+at.*?file\s+([^,]+),\s*line\s+(\d+)/i);
        const sourceLocations = [...output.matchAll(/\bat\s+([^:\s]+):(\d+)/g)];
        const match = breakpoint || sourceLocations[sourceLocations.length - 1];
        if (match) {
            this.currentLocation = {
                file: match[1].trim(),
                line: Number(match[2]),
                label: [...output.matchAll(/^([^\r\n]+?)\s+\(\)\s+at/gm)].pop()?.[1]
            };
        }
        // Steps within the same file only print "<line>\t<source>".
        const sourceLines = [...output.matchAll(/^(\d+)\s/gm)];
        if (this.currentLocation && sourceLines.length) {
            this.currentLocation.line = Number(sourceLines[sourceLines.length - 1][1]);
        }
    }

    failWaiters(error) {
        if (this.readyWaiter) {
            this.readyWaiter(error);
            this.readyWaiter = undefined;
        }
        if (this.commandWaiter) {
            const waiter = this.commandWaiter;
            this.commandWaiter = undefined;
            waiter.reject(error);
        }
    }

    stopProcess() {
        this.disposed = true;
        if (this.child && !this.child.killed) {
            this.child.kill('SIGTERM');
        }
    }

    sendResponse(request, body = {}, success = true, message) {
        const response = {
            seq: this.sequence++,
            type: 'response',
            request_seq: request.seq,
            command: request.command,
            success,
            body
        };
        if (message) response.message = message;
        this.messageEmitter.fire(response);
    }

    sendEvent(event, body) {
        this.messageEmitter.fire({
            seq: this.sequence++,
            type: 'event',
            event,
            body
        });
    }
}

module.exports = { AgcDebugAdapter };
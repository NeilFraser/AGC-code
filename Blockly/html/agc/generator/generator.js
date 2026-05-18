/**
 * @fileoverview Functions for generating AGC assembly for blocks.
 */
'use strict';


/**
 * JavaScript code generator.
 * @type {!Blockly.Generator}
 */
const AgcGenerator = new Blockly.Generator('AGC');

/**
 * List of illegal variable names.
 * This is not intended to be a security feature.  Blockly is 100% client-side,
 * so bypassing this list is trivial.  This is intended to prevent users from
 * accidentally clobbering a built-in object or function.
 */
AgcGenerator.addReservedWords('');

// Assembly code has no structural indentation.
AgcGenerator.INDENT = '';

AgcGenerator.default0 = '\tCA\tNUM0\n';
AgcGenerator.default1 = '\tCA\tNUM1\n';

AgcGenerator.uniqueLabel_ = 0;

AgcGenerator.getUniqueLabel = function() {
  return AgcGenerator.uniqueLabel_++;
};

/**
 * Whether the init method has been called.
 * @type {?boolean}
 */
AgcGenerator.isInitialized = false;

/**
 * Initialise the database of variable names.
 * @param {!Object} workspace Workspace to generate code from.
 */
AgcGenerator.init = function(workspace) {
  // Call Blockly.Generator's init.
  Object.getPrototypeOf(this).init.call(this);

  if (!this.nameDB_) {
    this.nameDB_ = new Blockly.Names(this.RESERVED_WORDS_);
  } else {
    this.nameDB_.reset();
  }

  this.nameDB_.setVariableMap(workspace.getVariableMap());
  this.nameDB_.populateVariables(workspace);
  this.nameDB_.populateProcedures(workspace);

  const defvars = [];
  // Add developer variables (not created or named by the user).
  const devVarList = Blockly.Variables.allDeveloperVariables(workspace);
  for (let i = 0; i < devVarList.length; i++) {
    defvars.push(this.nameDB_.getName(devVarList[i],
        Blockly.Names.DEVELOPER_VARIABLE_TYPE));
  }

  // Add user variables, but only ones that are being used.
  const variables = Blockly.Variables.allUsedVarModels(workspace);
  for (let i = 0; i < variables.length; i++) {
    defvars.push(this.nameDB_.getName(variables[i].getId(),
        Blockly.VARIABLE_CATEGORY_NAME));
  }

  // Declare all of the variables.
  if (defvars.length) {
    // Octal 4000 is just beyond the end of AGC's erasable memory.
    // Declare variables starting from the end of memory and working downwards.
    let memoryAddress = 0o4000;
    this.definitions_['variables'] = '';
    for (const varName of defvars) {
      memoryAddress--;
      this.definitions_['variables'] += varName + '\t=\t' + memoryAddress.toString(8) + '\n';
    }
  }
  this.isInitialized = true;
};

/**
 * Prepend the generated code with the variable definitions.
 * @param {string} code Generated code.
 * @return {string} Completed code.
 */
AgcGenerator.finish = function(code) {
  // Convert the definitions dictionary into a list.
  var definitions = [];
  for (var name in AgcGenerator.definitions_) {
    definitions.push(AgcGenerator.definitions_[name]);
  }
  // Clean up temporary data.
  delete AgcGenerator.definitions_;
  delete AgcGenerator.functionNames_;
  AgcGenerator.variableDB_.reset();
  return `
\tTC SKIPDEFS
${definitions.join('\n\n')}
SKIPDEFS
${code}
`;
};

/**
 * Naked values are top-level blocks with outputs that aren't plugged into
 * anything.
 * @param {string} line Line of generated code.
 * @return {string} Legal line of code.
 */
AgcGenerator.scrubNakedValue = function(line) {
  return line;
};

/**
 * Common tasks for generating JavaScript from blocks.
 * Handles comments for the specified block and any connected value blocks.
 * Calls any statements following this block.
 * @param {!Object} block The current block.
 * @param {string} code The JavaScript code created for this block.
 * @param {boolean=} opt_thisOnly True to generate code for only this statement.
 * @return {string} JavaScript code with comments and subsequent blocks added.
 * @protected
 */
AgcGenerator.scrub_ = function(block, code, opt_thisOnly) {
  let commentCode = '';
  // Only collect comments for blocks that aren't inline.
  if (!block.outputConnection || !block.outputConnection.targetConnection) {
    // Collect comment for this block.
    let comment = block.getCommentText();
    if (comment) {
      comment = Blockly.utils.string.wrap(comment, this.COMMENT_WRAP - 3);
      commentCode += this.prefixLines(comment + '\n', '// ');
    }
    // Collect comments for all value arguments.
    // Don't collect comments for nested statements.
    for (let i = 0; i < block.inputList.length; i++) {
      if (block.inputList[i].type === Blockly.INPUT_VALUE) {
        const childBlock = block.inputList[i].connection.targetBlock();
        if (childBlock) {
          comment = this.allNestedComments(childBlock);
          if (comment) {
            commentCode += this.prefixLines(comment, '// ');
          }
        }
      }
    }
  }
  const nextBlock = block.nextConnection && block.nextConnection.targetBlock();
  const nextCode = opt_thisOnly ? '' : this.blockToCode(nextBlock);
  return commentCode + code + nextCode;
};

// Don't require an order.
AgcGenerator.valueToCode = function(block, name) {
  var childBlock = block.getInputTargetBlock(name);
  if (!childBlock) return '';
  return this.blockToCode(childBlock);
};

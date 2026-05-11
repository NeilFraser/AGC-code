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
  // Create a dictionary of definitions to be printed before the code.
  AgcGenerator.definitions_ = Object.create(null);
  // Create a dictionary mapping desired function names in definitions_
  // to actual function names (to avoid collisions with user functions).
  AgcGenerator.functionNames_ = Object.create(null);

  if (!AgcGenerator.variableDB_) {
    AgcGenerator.variableDB_ =
        new Blockly.Names(AgcGenerator.RESERVED_WORDS_);
  } else {
    AgcGenerator.variableDB_.reset();
  }

  AgcGenerator.variableDB_.setVariableMap(workspace.getVariableMap());

  const defvars = [];
  // Add developer variables (not created or named by the user).
  const devVarList = Blockly.Variables.allDeveloperVariables(workspace);
  for (let i = 0; i < devVarList.length; i++) {
    defvars.push(
        this.nameDB_.getName(devVarList[i], Blockly.NameType.DEVELOPER_VARIABLE));
  }

  // Add user variables, but only ones that are being used.
  const variables = Blockly.Variables.allUsedVarModels(workspace);
  for (let i = 0; i < variables.length; i++) {
    defvars.push(this.nameDB_.getName(variables[i].getId(), Blockly.NameType.VARIABLE));
  }

  // Declare all of the variables.
  if (defvars.length) {
    this.definitions_['variables'] = 'var ' + defvars.join(', ') + ';';
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

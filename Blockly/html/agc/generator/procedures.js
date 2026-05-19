/**
 * @fileoverview Generating AGC assembly for procedure blocks.
 */
'use strict';

AgcGenerator['procedures_defreturn'] = function(block) {
  // Procedure definition.
  const funcName = AgcGenerator.nameDB_.getName(block.getFieldValue('NAME'),
      Blockly.PROCEDURE_CATEGORY_NAME);
  // Create the function definition.
  // 1. Push the return pointer onto the stack.
  // 2. Execute the body of the function.
  const branch = AgcGenerator.statementToCode(block, 'STACK');
  let code = `
${funcName}\tCA\tQ
\t\tTCR\tPUSH
${branch}`;
  if (block.getInput('RETURN')) {
    // 3. Execute the return value.
    // 4. Preserve the A register (return value) into L.
    // 5. Pop the return pointer from the stack into Q.
    // 6. Restore the return value from L back into the A register.
    // 7. Return from the function.
    const returnValue = AgcGenerator.valueToCode(block, 'RETURN') || AgcGenerator.default0;
    code += `
${returnValue}
\t\tTS\tL
\t\tTCR\tPOP
\t\tTS\tQ
\t\tCA\tL
\t\tRETURN
`;
  } else {
    // 3. Pop the return pointer from the stack into Q.
    // 4. Return from the function.
    code += `
\t\tTCR\tPOP
\t\tTS\tQ
\t\tRETURN
`;
  }
  code = AgcGenerator.scrub_(block, code);
  // Add % so as not to collide with helper functions in definitions list.
  AgcGenerator.definitions_['%' + funcName] = code;
  return null;
};

// Defining a procedure without a return value uses the same generator as
// defining a procedure with a return value.
AgcGenerator['procedures_defnoreturn'] = AgcGenerator['procedures_defreturn'];

AgcGenerator['procedures_callreturn'] = function(block) {
  // Call a procedure with a return value.
  const funcName = AgcGenerator.nameDB_.getName(block.getFieldValue('NAME'),
      Blockly.PROCEDURE_CATEGORY_NAME);
  const code = `\t\tTCR\t${funcName}\n`;
  return code;
};

// Calling a procedure without a return value uses the same generator as
// a calling procedure with a return value.
AgcGenerator['procedures_callnoreturn'] = AgcGenerator['procedures_callreturn'];


AgcGenerator['procedures_ifreturn'] = function(block) {
  // Conditionally return value from a procedure.
  const labelIf = 'IF' + AgcGenerator.getUniqueLabel();
  const condition = AgcGenerator.valueToCode(block, 'CONDITION') ||
      AgcGenerator.defaultFalse;
  const returnValue = block.hasReturnValue_ ?
      AgcGenerator.valueToCode(block, 'VALUE') || AgcGenerator.default0 : '';
  let code = `
${condition}
\tEXTEND
\tBZF\t${labelIf}
\t\tTCR\tPOP
\t\tTS\tQ
${returnValue}
\tRETURN
${labelIf}
`;
  return code;
};

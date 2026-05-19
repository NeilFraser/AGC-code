
/**
 * @fileoverview Generating AGC assembly for loop blocks.
 */
'use strict';

AgcGenerator['controls_whileUntil'] = function(block) {
  // Generator for 'do while/until' loop.
  const labelLoop = 'LOOP' + AgcGenerator.getUniqueLabel();
  const conditionCode =
      AgcGenerator.valueToCode(block, 'BOOL') ||
      AgcGenerator.default0;
  let branchCodeTrue = AgcGenerator.statementToCode(block, 'DO');
  let code = '';
  if (block.getFieldValue('MODE') === 'WHILE') {
    // While loop
    code = `
${labelLoop}
${conditionCode}
\tEXTEND
\tBZF\t${labelLoop}-X
${branchCodeTrue}
\tTC\t${labelLoop}
${labelLoop}-X
`
  } else {
    // Until loop
    code = `
${labelLoop}
${conditionCode}
\tEXTEND
\tBZF\t${labelLoop}-GO
\tTC\t${labelLoop}-X
${labelLoop}-GO
${branchCodeTrue}
\tTC\t${labelLoop}
${labelLoop}-X
`
  }
  return code;
};

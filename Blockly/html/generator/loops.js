
/**
 * @fileoverview Generating AGC assembly for loop blocks.
 */
'use strict';

AgcGenerator['loop_whileUntil'] = function(block) {
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

AgcGenerator['loop_for'] = function(block) {
  // Generator for 'for' loop.
  const variable = AgcGenerator.nameDB_.getName(block.getFieldValue('VAR'), Blockly.VARIABLE_CATEGORY_NAME);
  const fromCode = AgcGenerator.valueToCode(block, 'FROM') || AgcGenerator.default0;
  const toCode = AgcGenerator.valueToCode(block, 'TO') || AgcGenerator.default0;
  const dir = block.getFieldValue('DIR');
  const branchCode = AgcGenerator.statementToCode(block, 'DO');
  const labelLoop = 'FOR' + AgcGenerator.getUniqueLabel();
  let code;
  if (dir === 'UP') {
    code = `
${fromCode}
\tTS\t${variable}
${toCode}
\tINCR\tA
\tTCR\tPUSH
${labelLoop}\t# Count up loop.
\tTCR\tPEEK
\tEXTEND
\tSU\t${variable}
\tEXTEND
\tBZMF\t${labelLoop}-X
${branchCode}
\tINCR\t${variable}
\tTC\t${labelLoop}
${labelLoop}-X
\tTCR\tPOP
`;
  } else {
    code = `
${fromCode}
\tTS\t${variable}
${toCode}
\tTCR\tPUSH
${labelLoop}\t# Count down loop.
\tTCR\tPEEK
\tEXTEND
\tSU\t${variable}
\tEXTEND
\tBZMF\t${labelLoop}-L
\tTC\t${labelLoop}-X
${labelLoop}-L
${branchCode}
\tCA\tNUM1
\tCOM
\tADS\t${variable}
\tTC\t${labelLoop}
${labelLoop}-X
\tTCR\tPOP
`;
  }
  return code;
};

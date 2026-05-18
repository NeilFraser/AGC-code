
/**
 * @fileoverview Generating AGC assembly for math blocks.
 */
'use strict';

AgcGenerator['agc_math_number'] = function(block) {
  // Numeric value.
  const number = Number(block.getFieldValue('NUM'));
  AgcGenerator.provideFunction_('NUM' + number, [`NUM${number}\tDEC\t${number}`]);
  const code = `\tCA\tNUM${number}\n`;
  return code;
};

AgcGenerator['agc_math_arithmetic'] = function(block) {
  // Basic arithmetic operators.
  const OPERATORS = {
    'ADD': 'MA-AD',
    'MINUS': 'MA-SU',
    'MULTIPLY': 'MA-MP'
  };
  const operator = OPERATORS[block.getFieldValue('OP')];
  const argument0 = AgcGenerator.valueToCode(block, 'A') || AgcGenerator.default0;
  const argument1 = AgcGenerator.valueToCode(block, 'B') || AgcGenerator.default0;
  const code = `
${argument1}
\tTCR\tPUSH
${argument0}
\tTCR\tPUSH
\tTCR\t${operator}
`;
  return code;
};

AgcGenerator['agc_math_random_int_0'] = function(block) {
  const to = AgcGenerator.valueToCode(block, 'TO') || AgcGenerator.default1;
  const code = `
${to}
\tTCR\tPUSH
\tTCR\tGRNDNUM
`;
  return code;
};

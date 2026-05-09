
/**
 * @fileoverview Generating AGC assembly for math blocks.
 */
'use strict';

AgcGenerator['agc_math_number'] = function(block) {
  // Numeric value.
  const number = Number(block.getFieldValue('NUM'));
  AgcGenerator.provideFunction_('NUM' + number, `NUM${number}\tDEC\t${number}`);
  const code = `\tCA\tNUM${number}\n`;
  return [code, null];
};

AgcGenerator['agc_math_arithmetic'] = function(block) {
  // Basic arithmetic operators.
  const OPERATORS = {
    'ADD': 'MA-AD',
    'MINUS': 'MA-SU',
    'MULTIPLY': 'MA-MP'
  };
  const operator = OPERATORS[block.getFieldValue('OP')];
  const argument0 = AgcGenerator.valueToCode(block, 'A', null) || AgcGenerator.default0;
  const argument1 = AgcGenerator.valueToCode(block, 'B', null) || AgcGenerator.default0;
  const code = `
${argument0}
\tTCR\tPUSH
${argument1}
\tTCR\tPUSH
\tTCR\t${operator}
`;
  return [code, null];
};

/**
 * @fileoverview Generating AGC assembly for AGC-specific blocks.
 */
'use strict';


AgcGenerator['agc_print_digit'] = function(block) {
  const digit = AgcGenerator.valueToCode(block, 'DIGIT') || AgcGenerator.default0;
  const col = AgcGenerator.valueToCode(block, 'COL') || AgcGenerator.default0;
  const row = AgcGenerator.valueToCode(block, 'ROW') || AgcGenerator.default0;
  const code = `
${digit}
\tTCR\tPUSH
${col}
\tTCR\tPUSH
${row}
\tTCR\tPUSH
\tTCR\tPRNTDIG
`;
  return code;
};

AgcGenerator['agc_sleep'] = function(block) {
  const time = AgcGenerator.valueToCode(block, 'TIME') || AgcGenerator.default0;
  const code = `
${time}
\tTCR\tPUSH
\tTCR\tSLEEP
`;
  return code;
};


AgcGenerator['agc_key_press'] = function(block) {
  const code = `
\tTCR\tINPUT
`;
  return code;
};


AgcGenerator['agc_power'] = function(block) {
  const action = block.getFieldValue('ACTION');
  if (action === 'RESTART') {
    return `
\tTCF\tAGCSTART
`;
  }
  if (action === 'END') {
    return `
\tTCF\tAGCEND
`;
  }
  throw Error('Unknown power option');
};

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

AgcGenerator['agc_print_number'] = function(block) {
  const number = AgcGenerator.valueToCode(block, 'NUMBER') || AgcGenerator.default0;
  const row = AgcGenerator.valueToCode(block, 'ROW') || AgcGenerator.default0;
  const code = `
${number}
\tTCR\tPUSH
${row}
\tTCR\tPUSH
\tTCR\tPN
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

AgcGenerator['agc_lamps'] = function(block) {
  const state = block.getFieldValue('STATE');
  const lamp = Math.abs(block.getFieldValue('LAMP'));
  AgcGenerator.provideFunction_('NUM' + lamp, [`NUM${lamp}\tDEC\t${lamp}`]);
  const com = block.getFieldValue('LAMP') < 0 ? '\n\tCOM' : '';
  const code = `
\tCA\tNUM${state}
\tTCR\tPUSH
\tCA\tNUM${lamp}${com}
\tTCR\tPUSH
\tTCR\tLAMP
`;
  return code;
};

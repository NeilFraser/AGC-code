/**
 * @fileoverview Generating AGC assembly for AGC-specific blocks.
 */
'use strict';


AgcGenerator['agc_display'] = function(block) {
  const digit = AgcGenerator.valueToCode(block, 'DIGIT', null) || AgcGenerator.default0;
  const row = AgcGenerator.valueToCode(block, 'ROW', null) || AgcGenerator.default0;
  const col = AgcGenerator.valueToCode(block, 'COL', null) || AgcGenerator.default0;
  const code = `
${digit}
\tTCR\tPUSH
${row}
\tTCR\tPUSH
${col}
\tTCR\tPUSH
\tTCR\tDISPLAY
`;
  return code;
};

AgcGenerator['agc_sleep'] = function(block) {
  const time = AgcGenerator.valueToCode(block, 'TIME', null) || AgcGenerator.default0;
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

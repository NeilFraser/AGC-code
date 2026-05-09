/**
 * @fileoverview Generating AGC assembly for display blocks.
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

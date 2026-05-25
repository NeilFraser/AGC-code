/**
 * @fileoverview Generating AGC assembly for list blocks.
 */
'use strict';

AgcGenerator['list_get'] = function(block) {
  // List item getter.
  const argument0 = AgcGenerator.valueToCode(block, 'INDEX') ||
      AgcGenerator.default0;
  const code = `
${argument0}
\tCOM
\tINDEX\tA
\tCA\tLIST
`;
  return code;
};

AgcGenerator['list_set'] = function(block) {
  // List item setter.
  const argument0 = AgcGenerator.valueToCode(block, 'INDEX') ||
      AgcGenerator.default0;
  const argument1 = AgcGenerator.valueToCode(block, 'VALUE') ||
      AgcGenerator.default0;
  const code = `
${argument1}
\tTCR\tPUSH
${argument0}
\tTCR\tPUSH
\tTCR\tLS-SET
`;
  return code;
};

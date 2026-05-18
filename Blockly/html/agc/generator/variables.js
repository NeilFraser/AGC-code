/**
 * @fileoverview Generating AGC assembly for variable blocks.
 */
'use strict';

AgcGenerator['variables_get'] = function(block) {
  // Variable getter.
  const varName = AgcGenerator.nameDB_.getName(block.getFieldValue('VAR'),
      Blockly.VARIABLE_CATEGORY_NAME);
  const code = `
\tCA\t${varName}
`;
  return code;
};

AgcGenerator['variables_set'] = function(block) {
  // Variable setter.
  const argument0 = AgcGenerator.valueToCode(
                        block, 'VALUE') ||
      AgcGenerator.default0;
  const varName = AgcGenerator.nameDB_.getName(
      block.getFieldValue('VAR'), Blockly.VARIABLE_CATEGORY_NAME);
  const code = `
${argument0}
\tTS\t${varName}
`;
  return code;
};

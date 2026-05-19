
/**
 * @fileoverview Generating AGC assembly for logic blocks.
 */
'use strict';

AgcGenerator['controls_if'] = function(block) {
  // If condition.
  const labelIf = 'IF' + AgcGenerator.getUniqueLabel();
  const conditionCode =
      AgcGenerator.valueToCode(block, 'IF0') ||
      AgcGenerator.default0;
  let branchCodeTrue = AgcGenerator.statementToCode(block, 'DO0');
  let code = `
${conditionCode}
\tEXTEND
\tBZF\t${labelIf}-X
${branchCodeTrue}
${labelIf}-X
`
  return code;
};

AgcGenerator['controls_ifelse'] = function(block) {
  // If/else condition.
  const labelIf = 'IF' + AgcGenerator.getUniqueLabel();
  const conditionCode =
      AgcGenerator.valueToCode(block, 'IF0') ||
      AgcGenerator.default0;
  let branchCodeTrue = AgcGenerator.statementToCode(block, 'DO0');
  let branchCodeFalse = AgcGenerator.statementToCode(block, 'ELSE');
  let code = `
${conditionCode}
\tEXTEND
\tBZF\t${labelIf}-E
${branchCodeTrue}
\tTCF\t${labelIf}-X
${labelIf}-E
${branchCodeFalse}
${labelIf}-X
`
  return code;
};

AgcGenerator['logic_boolean'] = function(block) {
  // Boolean values true and false.
  const boolean = block.getFieldValue('BOOL');
  const code = `\tCA\tNUM${boolean}\n`;
  return code;
};

AgcGenerator['logic_compare'] = function(block) {
  // Comparison operator.
  const OPERATORS = {
    'EQ': '\tTCR\tBL-NOT',
    'NEQ': '',
    'LT': '\tTCR\tBL-GTE\n\tTCR\tBL-NOT',
    'LTE': '\tTCR\tBL-LTE',
    'GT': '\tTCR\tBL-LTE\n\tTCR\tBL-NOT',
    'GTE': '\tTCR\tBL-GTE'
  };
  const operator = OPERATORS[block.getFieldValue('OP')];
  const argument0 = AgcGenerator.valueToCode(block, 'A') || AgcGenerator.default0;
  const argument1 = AgcGenerator.valueToCode(block, 'B') || AgcGenerator.default0;
  const code = `
  ${argument0}
  \tTCR\tPUSH
  ${argument1}
  \tTCR\tPUSH
  \tTCR\tMA-SU
  ${operator}
  `;
  return code;
};

AgcGenerator['logic_operation'] = function(block) {
  // Operations 'and', 'or'.
  const operator = block.getFieldValue('OP');  // AND or OR
  let argument0 = AgcGenerator.valueToCode(block, 'A');
  let argument1 = AgcGenerator.valueToCode(block, 'B');
  if (!argument0 && !argument1) {
    // If there are no arguments, then the return value is false.
    argument0 = AgcGenerator.default0;
    argument1 = AgcGenerator.default0;
  } else {
    // Single missing arguments have no effect on the return value.
    const defaultArgument = (operator === 'AND') ? AgcGenerator.default1 : AgcGenerator.default0;
    if (!argument0) {
      argument0 = defaultArgument;
    }
    if (!argument1) {
      argument1 = defaultArgument;
    }
  }
  const code = `
  ${argument0}
  \tTCR\tPUSH
  ${argument1}
  \tTCR\tPUSH
  \tTCR\tBL-${operator}
`;
  return code;
};

AgcGenerator['logic_negate'] = function(block) {
  // Negation.
  const argument0 = AgcGenerator.valueToCode(block, 'BOOL') || AgcGenerator.default1;
  const code = `
${argument0}
\tTCR\tBL-NOT
`;
  return code;
};

AgcGenerator['logic_ternary'] = function(block) {
  // Ternary operator.
  const argument0 = AgcGenerator.valueToCode(block, 'ELSE') || AgcGenerator.default0;
  const argument1 = AgcGenerator.valueToCode(block, 'THEN') || AgcGenerator.default0;
  const argument2 = AgcGenerator.valueToCode(block, 'IF') || AgcGenerator.default0;
  const code = `
  ${argument0}
  \tTCR\tPUSH
  ${argument1}
  \tTCR\tPUSH
  ${argument2}
  \tTCR\tPUSH
  \tTCR\tBL-COND
  `;
  return code;
};

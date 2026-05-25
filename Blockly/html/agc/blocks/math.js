/**
 * @fileoverview AGC math blocks for Blockly.
 */
'use strict';

Blockly.defineBlocksWithJsonArray([
  // Block for numeric value.
  {
    'type': 'math_number',
    'message0': '%1',
    'args0': [{
      'type': 'field_number',
      'name': 'NUM',
      'value': 0,
      'min': -16383,
      'max': 16383,  // 2^14 - 1
      'precision': 1, // No decimals
    }],
    'output': 'Number',
    'helpUrl': '%{BKY_MATH_NUMBER_HELPURL}',
    'style': 'math_blocks',
    'tooltip': '%{BKY_MATH_NUMBER_TOOLTIP}',
    'extensions': ['parent_tooltip_when_inline'],
  },

  // Block for basic arithmetic operator.
  {
    'type': 'math_arithmetic',
    'message0': '%1 %2 %3',
    'args0': [
      {
        'type': 'input_value',
        'name': 'A',
        'check': 'Number',
      },
      {
        'type': 'field_dropdown',
        'name': 'OP',
        'options': [
          ['%{BKY_MATH_ADDITION_SYMBOL}', 'ADD'],
          ['%{BKY_MATH_SUBTRACTION_SYMBOL}', 'MINUS'],
          ['%{BKY_MATH_MULTIPLICATION_SYMBOL}', 'MULTIPLY'],
        ],
      },
      {
        'type': 'input_value',
        'name': 'B',
        'check': 'Number',
      },
    ],
    'inputsInline': true,
    'output': 'Number',
    'style': 'math_blocks',
    'helpUrl': '%{BKY_MATH_ARITHMETIC_HELPURL}',
    'extensions': ['math_op_tooltip'],
  },

  // Block for random integer between 0 and [X-1].
  {
    "type": "math_random_int_0",
    "message0": "random integer to %1",
    "args0": [
      {
        "type": "input_value",
        "name": "TO",
        "check": "Number",
      },
    ],
    "inputsInline": true,
    "output": "Number",
    "style": "math_blocks",
    "tooltip": "Return a random integer between the 0 (inclusive) and the specified number (exclusive).",
    "helpUrl": "%{BKY_MATH_RANDOM_INT_HELPURL}",
  },

  // Block for random integer between [X] and [Y].
  {
    "type": "math_random_int",
    "message0": "%{BKY_MATH_RANDOM_INT_TITLE}",
    "args0": [
      {
        "type": "input_value",
        "name": "FROM",
        "check": "Number",
      },
      {
        "type": "input_value",
        "name": "TO",
        "check": "Number",
      },
    ],
    "inputsInline": true,
    "output": "Number",
    "style": "math_blocks",
    "tooltip": "%{BKY_MATH_RANDOM_INT_TOOLTIP}",
    "helpUrl": "%{BKY_MATH_RANDOM_INT_HELPURL}",
  },
  // Block for adding to a variable in place.
  {
    "type": "math_change",
    "message0": "%{BKY_MATH_CHANGE_TITLE}",
    "args0": [
      {
        "type": "field_variable",
        "name": "VAR",
        "variable": "%{BKY_MATH_CHANGE_TITLE_ITEM}",
      },
      {
        "type": "input_value",
        "name": "DELTA",
        "check": "Number",
      },
    ],
    "previousStatement": null,
    "nextStatement": null,
    "style": "variable_blocks",
    "helpUrl": "%{BKY_MATH_CHANGE_HELPURL}",
    "extensions": ["math_change_tooltip"],
  },
]);

// Update the tooltip of 'math_change' block to reference the variable.
Blockly.Extensions.register('math_change_tooltip',
    Blockly.Extensions.buildTooltipWithFieldText(
        '%{BKY_MATH_CHANGE_TOOLTIP}', 'VAR'));


(function() {
  /**
   * Mapping of math block OP value to tooltip message for blocks
   * math_arithmetic, math_simple, math_trig, and math_on_lists.
   * @see {Blockly.Extensions#buildTooltipForDropdown}
   * @package
   * @readonly
   */
  const TOOLTIPS_BY_OP = {
    // math_arithmetic
    'ADD': '%{BKY_MATH_ARITHMETIC_TOOLTIP_ADD}',
    'MINUS': '%{BKY_MATH_ARITHMETIC_TOOLTIP_MINUS}',
    'MULTIPLY': '%{BKY_MATH_ARITHMETIC_TOOLTIP_MULTIPLY}',
    'DIVIDE': '%{BKY_MATH_ARITHMETIC_TOOLTIP_DIVIDE}',
    'POWER': '%{BKY_MATH_ARITHMETIC_TOOLTIP_POWER}',

    // math_simple
    'ROOT': '%{BKY_MATH_SINGLE_TOOLTIP_ROOT}',
    'ABS': '%{BKY_MATH_SINGLE_TOOLTIP_ABS}',
    'NEG': '%{BKY_MATH_SINGLE_TOOLTIP_NEG}',
    'LN': '%{BKY_MATH_SINGLE_TOOLTIP_LN}',
    'LOG10': '%{BKY_MATH_SINGLE_TOOLTIP_LOG10}',
    'EXP': '%{BKY_MATH_SINGLE_TOOLTIP_EXP}',
    'POW10': '%{BKY_MATH_SINGLE_TOOLTIP_POW10}',

    // math_trig
    'SIN': '%{BKY_MATH_TRIG_TOOLTIP_SIN}',
    'COS': '%{BKY_MATH_TRIG_TOOLTIP_COS}',
    'TAN': '%{BKY_MATH_TRIG_TOOLTIP_TAN}',
    'ASIN': '%{BKY_MATH_TRIG_TOOLTIP_ASIN}',
    'ACOS': '%{BKY_MATH_TRIG_TOOLTIP_ACOS}',
    'ATAN': '%{BKY_MATH_TRIG_TOOLTIP_ATAN}',

    // math_on_lists
    'SUM': '%{BKY_MATH_ONLIST_TOOLTIP_SUM}',
    'MIN': '%{BKY_MATH_ONLIST_TOOLTIP_MIN}',
    'MAX': '%{BKY_MATH_ONLIST_TOOLTIP_MAX}',
    'AVERAGE': '%{BKY_MATH_ONLIST_TOOLTIP_AVERAGE}',
    'MEDIAN': '%{BKY_MATH_ONLIST_TOOLTIP_MEDIAN}',
    'MODE': '%{BKY_MATH_ONLIST_TOOLTIP_MODE}',
    'STD_DEV': '%{BKY_MATH_ONLIST_TOOLTIP_STD_DEV}',
    'RANDOM': '%{BKY_MATH_ONLIST_TOOLTIP_RANDOM}',
  };

  Blockly.Extensions.register('math_op_tooltip',
      Blockly.Extensions.buildTooltipForDropdown(
          'OP', TOOLTIPS_BY_OP));
})();

/**
 * @fileoverview AGC math blocks for Blockly.
 */
'use strict';

Blockly.defineBlocksWithJsonArray([
  // Block for numeric value.
  {
    'type': 'agc_math_number',
    'message0': '%1',
    'args0': [{
      'type': 'field_number',
      'name': 'NUM',
      'value': 0,
    }],
    'output': 'Number',
    'helpUrl': '%{BKY_MATH_NUMBER_HELPURL}',
    'style': 'math_blocks',
    'tooltip': '%{BKY_MATH_NUMBER_TOOLTIP}',
    'extensions': ['parent_tooltip_when_inline'],
  },

  // Block for basic arithmetic operator.
  {
    'type': 'agc_math_arithmetic',
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
    "type": "agc_math_random_int_0",
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
    "type": "agc_math_random_int",
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
]);

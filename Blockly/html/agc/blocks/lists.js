/**
 * @fileoverview List blocks for Blockly.
 */
'use strict';

Blockly.defineBlocksWithJsonArray([
  // Block for list item setter.
  {
    "type": "list_set",
    "message0": "set list at %1 to %2",
    "args0": [
      {
        'type': 'input_value',
        'name': 'INDEX',
        'check': 'Number',
      },
      {
        'type': 'input_value',
        'name': 'VALUE',
        'check': 'Number',
      },
    ],
    "previousStatement": null,
    "nextStatement": null,
    "inputsInline": true,
    "style": "list_blocks",
    "helpUrl": null,
    "tooltip": "Set the value in the list at the specified location.",
  },
  // Block for list item getter.
  {
    "type": "list_get",
    "message0": "get list at %1",
    "args0": [
      {
        'type': 'input_value',
        'name': 'INDEX',
        'check': 'Number',
      },
    ],
    "output": null,
    "style": "list_blocks",
    "helpUrl": null,
    "tooltip": "Get the value in the list at the specified location.",
  },
]);

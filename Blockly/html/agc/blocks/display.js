/**
 * @fileoverview AGC display blocks for Blockly.
 */
'use strict';

Blockly.defineBlocksWithJsonArray([
  // Block for display.
  {
    "type": "agc_display",
    "message0": "display %1 digit %2 row %3 column %4",
    "args0": [
      {
        "type": "input_dummy"
      },
      {
        "type": "input_value",
        "name": "DIGIT",
        "check": "Number"
      },
      {
        "type": "input_value",
        "name": "ROW",
        "check": "Number"
      },
      {
        "type": "input_value",
        "name": "COL",
        "check": "Number"
      }
    ],
    "inputsInline": true,
    "previousStatement": null,
    "nextStatement": null,
    "colour": 20,
    "tooltip": "Display a single digit (0-9, 10-blank) at row (0-2) column (0-4)",
    "helpUrl": ""
  }
]);

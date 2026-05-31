/**
 * @fileoverview AGC-specific blocks for Blockly.
 */
'use strict';

Blockly.defineBlocksWithJsonArray([
  // Block for displaying a single digit on the DSKY.
  {
    "type": "agc_print_digit",
    "message0": "display %1 digit %2 column %3 row %4",
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
        "name": "COL",
        "check": "Number"
      },
      {
        "type": "input_value",
        "name": "ROW",
        "check": "Number"
      }
    ],
    "inputsInline": true,
    "previousStatement": null,
    "nextStatement": null,
    "colour": 20,
    "tooltip": "Display a single digit (0-9, 10-blank) at column (0-4), row (0-2)",
    "helpUrl": ""
  },

  // Block for DSKY key press.
  {
    "type": "agc_key_press",
    "message0": "key press %1",
    "args0": [
      {
        "type": "input_dummy"
      }
    ],
    'output': 'Number',
    "colour": 20,
    "tooltip": "Waits for a DSKY key press (0-9)",
    "helpUrl": ""
  },

  // Block for stopping execution for a set time.
  {
    "type": "agc_sleep",
    "message0": "sleep %1 cs",
    "args0": [
      {
        "type": "input_value",
        "name": "TIME",
        "check": "Number"
      }
    ],
    "inputsInline": true,
    "previousStatement": null,
    "nextStatement": null,
    "colour": 20,
    "tooltip": "Stop execution for a set time (in centiseconds)",
    "helpUrl": ""
  },

  // Block for stopping execution or rebooting.
  {
    "type": "agc_power",
    'message0': '%1',
    'args0': [
      {
        'type': 'field_dropdown',
        'name': 'ACTION',
        'options': [
          ['restart', 'RESTART'],
          ['end', 'END'],
        ],
      },
    ],
    "previousStatement": null,
    "colour": 20,
    "tooltip": "Reboot or halt the AGC.",
    "helpUrl": ""
  },
]);

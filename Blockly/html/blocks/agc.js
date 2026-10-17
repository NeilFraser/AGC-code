/**
 * @fileoverview AGC-specific blocks for Blockly.
 */
'use strict';

Blockly.defineBlocksWithJsonArray([
  // Block for displaying a single digit on the DSKY.
  {
    "type": "agc_print_digit",
    "message0": "display %1 row %2 column %3 digit %4",
    "args0": [
      {
        "type": "input_dummy"
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
      },
      {
        "type": "input_value",
        "name": "DIGIT",
        "check": "Number"
      }
    ],
    "inputsInline": true,
    "previousStatement": null,
    "nextStatement": null,
    "colour": 20,
    "tooltip": "Display a single digit (0-9, 10-blank) at row (0-2), column (0-4)",
    "helpUrl": ""
  },

  // Block for displaying a number on the DSKY.
  {
    "type": "agc_print_number",
    "message0": "display %1 row %2 number %3",
    "args0": [
      {
        "type": "input_dummy"
      },
      {
        "type": "input_value",
        "name": "ROW",
        "check": "Number"
      },
      {
        "type": "input_value",
        "name": "NUMBER",
        "check": "Number"
      }
    ],
    "inputsInline": true,
    "previousStatement": null,
    "nextStatement": null,
    "colour": 20,
    "tooltip": "Display a number on row (0-2)",
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

  // Block for stopping execution or rebooting.
  {
    "type": "agc_lamps",
    'message0': 'turn %1 lamp %2',
    'args0': [
      {
        'type': 'field_dropdown',
        'name': 'STATE',
        'options': [
          ['on', '1'],
          ['off', '0'],
        ],
      },
      {
        'type': 'field_dropdown',
        'name': 'LAMP',
        'options': [
          ['UPLINK ACTY', String(-(2**2))],
          ['NO ATT', String(2**3)],
          //['STBY', String(-(2**8))],
          ['KEY REL', String(-(2**4))],
          ['OPR ERR', String(-(2**6))],

          ['TEMP', String(-(2**3))],
          ['GIMBAL LOCK', String(2**5)],
          ['PROG', String(2**8)],
          //['RESTART', String(-(2**7))],
          ['TRACKER', String(2**7)],
          ['ALT', String(2**4)],
          ['VEL', String(2**2)],
          ['COMP ACTY', String(-(2**1))],
        ],
      },
    ],
    "previousStatement": null,
    "nextStatement": null,
    "colour": 20,
    "tooltip": "Control the DSKY lamps.",
    "helpUrl": ""
  },
]);

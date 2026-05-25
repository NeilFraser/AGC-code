/**
 * @fileoverview AGC loop blocks for Blockly.
 */
'use strict';

Blockly.defineBlocksWithJsonArray([
  // Block for 'do while/until' loop.
  {
    'type': 'loop_whileUntil',
    'message0': '%1 %2',
    'args0': [
      {
        'type': 'field_dropdown',
        'name': 'MODE',
        'options': [
          ['%{BKY_CONTROLS_WHILEUNTIL_OPERATOR_WHILE}', 'WHILE'],
          ['%{BKY_CONTROLS_WHILEUNTIL_OPERATOR_UNTIL}', 'UNTIL'],
        ],
      },
      {
        'type': 'input_value',
        'name': 'BOOL',
        'check': 'Boolean',
      },
    ],
    'message1': '%{BKY_CONTROLS_REPEAT_INPUT_DO} %1',
    'args1': [
      {
        'type': 'input_statement',
        'name': 'DO',
      },
    ],
    'previousStatement': null,
    'nextStatement': null,
    'style': 'loop_blocks',
    'helpUrl': '%{BKY_CONTROLS_WHILEUNTIL_HELPURL}',
    'extensions': ['loop_whileUntil_tooltip'],
  },
  // Block for 'for' loop.
  {
    "type": "loop_for",
    "message0": "count %1 with %2 from %3 to %4",
    "args0": [
      {
        'type': 'field_dropdown',
        'name': 'DIR',
        'options': [
          ['up', 'UP'],
          ['down', 'DOWN'],
        ],
      },
      {
        "type": "field_variable",
        "name": "VAR",
        "variable": null,
      },
      {
        "type": "input_value",
        "name": "FROM",
        "check": "Number",
        "align": "RIGHT",
      },
      {
        "type": "input_value",
        "name": "TO",
        "check": "Number",
        "align": "RIGHT",
      },
    ],
    "message1": "%{BKY_CONTROLS_REPEAT_INPUT_DO} %1",
    "args1": [{
      "type": "input_statement",
      "name": "DO",
    }],
    "inputsInline": true,
    "previousStatement": null,
    "nextStatement": null,
    "style": "loop_blocks",
    "helpUrl": "%{BKY_CONTROLS_FOR_HELPURL}",
    "extensions": [
      "contextMenu_newGetVariableBlock",
      "loop_for_tooltip",
    ],
  },
]);



(function() {
  Blockly.Extensions.register('loop_whileUntil_tooltip',
      Blockly.Extensions.buildTooltipForDropdown(
          'MODE', {
    'WHILE': '%{BKY_CONTROLS_WHILEUNTIL_TOOLTIP_WHILE}',
    'UNTIL': '%{BKY_CONTROLS_WHILEUNTIL_TOOLTIP_UNTIL}',
  }));

  /**
   * Mixin to add a context menu item to create a 'variables_get' block.
   * @mixin
   * @augments Blockly.Block
   * @package
   * @readonly
   */
  const CUSTOM_CONTEXT_MENU_CREATE_VARIABLES_GET_MIXIN = {
    /**
     * Add context menu option to create getter block for the loop's variable.
     * (customContextMenu support limited to web BlockSvg.)
     * @param {!Array} options List of menu options to add to.
     * @this {Blockly.Block}
     */
    customContextMenu: function(options) {
      if (this.isInFlyout) {
        return;
      }
      const variable = this.getField('VAR').getVariable();
      const varName = variable.name;
      if (!this.isCollapsed() && varName !== null) {
        const option = {enabled: true};
        option.text =
            Blockly.Msg['VARIABLES_SET_CREATE_GET'].replace('%1', varName);
        const xmlField = Blockly.Variables.generateVariableFieldDom(variable);
        const xmlBlock = Blockly.utils.xml.createElement('block');
        xmlBlock.setAttribute('type', 'variables_get');
        xmlBlock.appendChild(xmlField);
        option.callback = Blockly.ContextMenu.callbackFactory(this, xmlBlock);
        options.push(option);
      }
    },
  };

  Blockly.Extensions.registerMixin('contextMenu_newGetVariableBlock',
      CUSTOM_CONTEXT_MENU_CREATE_VARIABLES_GET_MIXIN);

  Blockly.Extensions.register('loop_for_tooltip',
      Blockly.Extensions.buildTooltipWithFieldText(
        '%{BKY_LOOP_FOR_TOOLTIP}', 'VAR'));
  Blockly.Msg.LOOP_FOR_TOOLTIP = "Have the variable '%1' count up (+1) or down (-1) from the start number to the end number (inclusive), and do the specified blocks each time.";
})();

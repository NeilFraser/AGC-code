/**
 * @fileoverview AGC logic blocks for Blockly.
 */
'use strict';

Blockly.defineBlocksWithJsonArray([
  {
    'type': 'logic_if',
    'message0': '%{BKY_CONTROLS_IF_MSG_IF} %1',
    'args0': [
      {
        'type': 'input_value',
        'name': 'IF0',
        'check': 'Boolean',
      },
    ],
    'message1': '%{BKY_CONTROLS_IF_MSG_THEN} %1',
    'args1': [
      {
        'type': 'input_statement',
        'name': 'DO0',
      },
    ],
    'previousStatement': null,
    'nextStatement': null,
    'style': 'logic_blocks',
    'tooltip': '%{BKY_CONTROLS_IF_TOOLTIP_1}',
    'helpUrl': '%{BKY_CONTROLS_IF_HELPURL}',
  },
  {
    'type': 'logic_ifelse',
    'message0': '%{BKY_CONTROLS_IF_MSG_IF} %1',
    'args0': [
      {
        'type': 'input_value',
        'name': 'IF0',
        'check': 'Boolean',
      },
    ],
    'message1': '%{BKY_CONTROLS_IF_MSG_THEN} %1',
    'args1': [
      {
        'type': 'input_statement',
        'name': 'DO0',
      },
    ],
    'message2': '%{BKY_CONTROLS_IF_MSG_ELSE} %1',
    'args2': [
      {
        'type': 'input_statement',
        'name': 'ELSE',
      },
    ],
    'previousStatement': null,
    'nextStatement': null,
    'style': 'logic_blocks',
    'tooltip': '%{BKY_CONTROLS_IF_TOOLTIP_2}',
    'helpUrl': '%{BKY_CONTROLS_IF_HELPURL}',
  },
  // Block for boolean data type: true and false.
  {
    'type': 'logic_boolean',
    'message0': '%1',
    'args0': [
      {
        'type': 'field_dropdown',
        'name': 'BOOL',
        'options': [
          ['%{BKY_LOGIC_BOOLEAN_TRUE}', '1'],
          ['%{BKY_LOGIC_BOOLEAN_FALSE}', '0'],
        ],
      },
    ],
    'output': 'Boolean',
    'style': 'logic_blocks',
    'tooltip': '%{BKY_LOGIC_BOOLEAN_TOOLTIP}',
    'helpUrl': '%{BKY_LOGIC_BOOLEAN_HELPURL}',
  },
  // Block for comparison operator.
  {
    'type': 'logic_compare',
    'message0': '%1 %2 %3',
    'args0': [
      {
        'type': 'input_value',
        'name': 'A',
      },
      {
        'type': 'field_dropdown',
        'name': 'OP',
        'options': [
          ['=', 'EQ'],
          ['\u2260', 'NEQ'],
          ['\u200F<', 'LT'],
          ['\u200F\u2264', 'LTE'],
          ['\u200F>', 'GT'],
          ['\u200F\u2265', 'GTE'],
        ],
      },
      {
        'type': 'input_value',
        'name': 'B',
      },
    ],
    'inputsInline': true,
    'output': 'Boolean',
    'style': 'logic_blocks',
    'helpUrl': '%{BKY_LOGIC_COMPARE_HELPURL}',
    'extensions': ['logic_compare', 'logic_op_tooltip'],
  },
  // Block for logical operations: 'and', 'or'.
  {
    'type': 'logic_operation',
    'message0': '%1 %2 %3',
    'args0': [
      {
        'type': 'input_value',
        'name': 'A',
        'check': 'Boolean',
      },
      {
        'type': 'field_dropdown',
        'name': 'OP',
        'options': [
          ['%{BKY_LOGIC_OPERATION_AND}', 'AND'],
          ['%{BKY_LOGIC_OPERATION_OR}', 'OR'],
        ],
      },
      {
        'type': 'input_value',
        'name': 'B',
        'check': 'Boolean',
      },
    ],
    'inputsInline': true,
    'output': 'Boolean',
    'style': 'logic_blocks',
    'helpUrl': '%{BKY_LOGIC_OPERATION_HELPURL}',
    'extensions': ['logic_op_tooltip'],
  },
  // Block for negation.
  {
    'type': 'logic_negate',
    'message0': '%{BKY_LOGIC_NEGATE_TITLE}',
    'args0': [
      {
        'type': 'input_value',
        'name': 'BOOL',
        'check': 'Boolean',
      },
    ],
    'output': 'Boolean',
    'style': 'logic_blocks',
    'tooltip': '%{BKY_LOGIC_NEGATE_TOOLTIP}',
    'helpUrl': '%{BKY_LOGIC_NEGATE_HELPURL}',
  },
  // Block for ternary operator.
  {
    'type': 'logic_ternary',
    'message0': '%{BKY_LOGIC_TERNARY_CONDITION} %1',
    'args0': [
      {
        'type': 'input_value',
        'name': 'IF',
        'check': 'Boolean',
      },
    ],
    'message1': '%{BKY_LOGIC_TERNARY_IF_TRUE} %1',
    'args1': [
      {
        'type': 'input_value',
        'name': 'THEN',
      },
    ],
    'message2': '%{BKY_LOGIC_TERNARY_IF_FALSE} %1',
    'args2': [
      {
        'type': 'input_value',
        'name': 'ELSE',
      },
    ],
    'output': null,
    'style': 'logic_blocks',
    'tooltip': '%{BKY_LOGIC_TERNARY_TOOLTIP}',
    'helpUrl': '%{BKY_LOGIC_TERNARY_HELPURL}',
    'extensions': ['logic_ternary'],
  },
]);

(function() {
  /**
   * Adds dynamic type validation for the left and right sides of a logic_compare
   * block.
   * @mixin
   * @augments Blockly.Block
   * @package
   * @readonly
   */
  const LOGIC_COMPARE_ONCHANGE_MIXIN = {
    /**
     * Called whenever anything on the workspace changes.
     * Prevent mismatched types from being compared.
     * @param {!Blockly.Events.Abstract} e Change event.
     * @this {Blockly.Block}
     */
    onchange: function(e) {
      if (!this.prevBlocks_) {
        this.prevBlocks_ = [null, null];
      }

      const blockA = this.getInputTargetBlock('A');
      const blockB = this.getInputTargetBlock('B');
      // Disconnect blocks that existed prior to this change if they don't match.
      if (blockA && blockB &&
        !this.workspace.connectionChecker.doTypeChecks(
            blockA.outputConnection, blockB.outputConnection)) {
        // Mismatch between two inputs.  Revert the block connections,
        // bumping away the newly connected block(s).
        Blockly.Events.setGroup(e.group);
        const prevA = this.prevBlocks_[0];
        if (prevA !== blockA) {
          blockA.unplug();
          if (prevA && !prevA.isDisposed() && !prevA.isShadow()) {
            // The shadow block is automatically replaced during unplug().
            this.getInput('A').connection.connect(prevA.outputConnection);
          }
        }
        const prevB = this.prevBlocks_[1];
        if (prevB !== blockB) {
          blockB.unplug();
          if (prevB && !prevB.isDisposed() && !prevB.isShadow()) {
            // The shadow block is automatically replaced during unplug().
            this.getInput('B').connection.connect(prevB.outputConnection);
          }
        }
        this.bumpNeighbours();
        Blockly.Events.setGroup(false);
      }
      this.prevBlocks_[0] = this.getInputTargetBlock('A');
      this.prevBlocks_[1] = this.getInputTargetBlock('B');
    },
  };

  /**
   * "logic_compare" extension function. Adds type left and right side type
   * checking to "logic_compare" blocks.
   * @this {Blockly.Block}
   * @package
   * @readonly
   */
  const LOGIC_COMPARE_EXTENSION = function() {
    // Add onchange handler to ensure types are compatible.
    this.mixin(LOGIC_COMPARE_ONCHANGE_MIXIN);
  };

  Blockly.Extensions.register('logic_compare', LOGIC_COMPARE_EXTENSION);

  /**
   * Tooltip text, keyed by block OP value. Used by logic_compare and
   * logic_operation blocks.
   * @see {Blockly.Extensions#buildTooltipForDropdown}
   * @package
   * @readonly
   */
  const TOOLTIPS_BY_OP = {
    // logic_compare
    'EQ': '%{BKY_LOGIC_COMPARE_TOOLTIP_EQ}',
    'NEQ': '%{BKY_LOGIC_COMPARE_TOOLTIP_NEQ}',
    'LT': '%{BKY_LOGIC_COMPARE_TOOLTIP_LT}',
    'LTE': '%{BKY_LOGIC_COMPARE_TOOLTIP_LTE}',
    'GT': '%{BKY_LOGIC_COMPARE_TOOLTIP_GT}',
    'GTE': '%{BKY_LOGIC_COMPARE_TOOLTIP_GTE}',

    // logic_operation
    'AND': '%{BKY_LOGIC_OPERATION_TOOLTIP_AND}',
    'OR': '%{BKY_LOGIC_OPERATION_TOOLTIP_OR}',
  };

  Blockly.Extensions.register('logic_op_tooltip',
      Blockly.Extensions.buildTooltipForDropdown('OP', TOOLTIPS_BY_OP));

  /**
   * Adds type coordination between inputs and output.
   * @mixin
   * @augments Blockly.Block
   * @package
   * @readonly
   */
  const LOGIC_TERNARY_ONCHANGE_MIXIN = {
    prevParentConnection_: null,

    /**
     * Called whenever anything on the workspace changes.
     * Prevent mismatched types.
     * @param {!Blockly.Events.Abstract} e Change event.
     * @this {Blockly.Block}
     */
    onchange: function(e) {
      const blockA = this.getInputTargetBlock('THEN');
      const blockB = this.getInputTargetBlock('ELSE');
      const parentConnection = this.outputConnection.targetConnection;
      // Disconnect blocks that existed prior to this change if they don't match.
      if ((blockA || blockB) && parentConnection) {
        for (let i = 0; i < 2; i++) {
          const block = (i === 1) ? blockA : blockB;
          if (block &&
              !block.workspace.connectionChecker.doTypeChecks(
                  block.outputConnection, parentConnection)) {
            // Ensure that any disconnections are grouped with the causing event.
            Blockly.Events.setGroup(e.group);
            if (parentConnection === this.prevParentConnection_) {
              this.unplug();
              parentConnection.getSourceBlock().bumpNeighbours();
            } else {
              block.unplug();
              block.bumpNeighbours();
            }
            Blockly.Events.setGroup(false);
          }
        }
      }
      this.prevParentConnection_ = parentConnection;
    },
  };

  Blockly.Extensions.registerMixin('logic_ternary',
      LOGIC_TERNARY_ONCHANGE_MIXIN);

})();

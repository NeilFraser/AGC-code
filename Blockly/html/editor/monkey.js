/**
 * @fileoverview Monkey-patch Blockly to handle AGC assembly.
 */
'use strict';

// AGC label names must not be more than 8 characters long.
Blockly.Names.MAX_LENGTH = 8;

/**
 * Given a proposed entity name, generate a name that conforms to the
 * [_A-Z0-9]{1,8} format that AGC assembly considers legal for labels.
 * @param {string} name Potentially illegal entity name.
 * @return {string} Safe entity name.
 * @private
 */
Blockly.Names.prototype.safeName_ = function(name) {
  if (!name) {
    name = Blockly.Msg['UNNAMED_KEY'] || 'UNNAMED';
  } else {
    // Unfortunately names in non-latin characters will look like
    // _E9_9F_B3_E4_B9_90 which is pretty meaningless.
    // https://github.com/google/blockly/issues/1654
    name = encodeURI(name.replace(/ /g, '_')).replace(/[^\w]/g, '_');
  }
  // Prefix all user labels with '@' to avoid collisions with framework labels.
  name = '@' + name;
  return name.toUpperCase().substring(0, Blockly.Names.MAX_LENGTH);
};


/**
 * Convert a Blockly entity name to a legal exportable entity name.
 * Ensure that this is a new name not overlapping any previously defined name.
 * Also check against list of reserved words for the current language and
 * ensure name doesn't collide.
 * @param {string} name The Blockly entity name (no constraints).
 * @param {string} realm The realm of entity in Blockly
 *     ('VARIABLE', 'PROCEDURE', 'DEVELOPER_VARIABLE', etc...).
 * @return {string} An entity name that is legal in the exported language.
 */
Blockly.Names.prototype.getDistinctName = function(name, realm) {
  let safeName = this.safeName_(name);
  let i = '';
  while (true) {
    while (this.dbReverse_[safeName + i] ||
          (safeName + i) in this.reservedDict_) {
      // Collision with existing name.  Create a unique name.
      i = i ? i + 1 : 2;
    }
    if ((safeName + i).length <= Blockly.Names.MAX_LENGTH) {
      safeName += i;
      break;
    }
    // Truncate and try again.
    safeName = safeName.substring(0, safeName.length - 1);
    i = 1;
  }
  this.dbReverse_[safeName] = true;
  return safeName;
};

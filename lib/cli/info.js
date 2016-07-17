'use strict';

// Project metadata.
var pkg = require('../../package.json');

// Display script version.
exports.version = function() {
  console.log('script v' + pkg.version);
};

// Show help, then exit with a message and error code.
exports.fatal = function(msg, code) {
  exports.helpHeader();
  console.log('Fatal error: ' + msg);
  console.log('');
  exports.helpFooter();
  process.exit(code);
};

// Show help and exit.
exports.help = function() {
  exports.helpHeader();
  exports.helpFooter();
  process.exit();
};

// Help header.
exports.helpHeader = function() {
  console.log('script: ' + pkg.description + ' (v' + pkg.version + ')');
  console.log('');
};

// Help footer.
exports.helpFooter = function() {
  [
    '',
  ].forEach(function(str) { console.log(str); });
};
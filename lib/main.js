'use strict';

// This allows grunt to require() .coffee files.
require('coffee-script');
require('coffee-script/register');

// expose the main service object
module.exports = require('./main_class');
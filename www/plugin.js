var exec = require('cordova/exec');

var PLUGIN_NAME = 'Videobox';

var VideoBoxPlugin = {
  setAttribute: function(key, value) {
    exec(null, null, PLUGIN_NAME, 'setAttribute', [key, value]);
  },

  playVideo: function(path) {
    exec(null, null, PLUGIN_NAME, 'playVideo', [path]);
  },

  onPrevButton: function(callback) {
    exec(callback, null, PLUGIN_NAME, 'onPrevButton', []);
  },

  onNextButton: function(callback) {
    exec(callback, null, PLUGIN_NAME, 'onNextButton', []);
  },
}

module.exports = VideoBoxPlugin;
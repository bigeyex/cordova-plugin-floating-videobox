var exec = require('cordova/exec');

var PLUGIN_NAME = 'Videobox';

var VideoBoxPlugin = {
  isOpen: false,
  setAttribute: function(key, value) {
    exec(null, null, PLUGIN_NAME, 'setAttribute', [key, value]);
  },

  playBundleVideo: function(path) {
    exec(null, null, PLUGIN_NAME, 'playBundleVideo', [path]);
  },

  onPrevButton: function(callback) {
    exec(callback, null, PLUGIN_NAME, 'onPrevButton', []);
  },

  onNextButton: function(callback) {
    exec(callback, null, PLUGIN_NAME, 'onNextButton', []);
  },

  show: function() {
    this.isOpen = true;
    exec(null, null, PLUGIN_NAME, 'show', []);
  },
  
  hide: function() {
    this.isOpen = false;
    exec(null, null, PLUGIN_NAME, 'hide', []);
  },
}

module.exports = VideoBoxPlugin;
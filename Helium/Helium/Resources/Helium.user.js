// ==UserScript==
// @include        *
// ==/UserScript==

var __Helium = {
    _seek: function(delta) {
        document.getElementsByTagName('video')[0].currentTime += delta;
    },

    _volume: function (delta) {
        document.getElementsByTagName('video')[0].volume += delta;
    },

    seekBackward: function () {
        __Helium._seek(-3);
    },

    seekForward: function () {
        __Helium._seek(3);
    },

    volumeUp: function () {
        __Helium._volume(+0.15);
    },

    volumeDown: function() {
        __Helium._volume(-0.15);
    },

    playPause: function () {
        var player = document.getElementsByTagName('video')[0];
        player.paused ? player.play() : player.pause();
    },

    documentHeight: function () {
        var body = document.body, html = document.documentElement;

        return Math.max(body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight);
    },

    hasVideotag: function () {
        return document.getElementsByTagName('video').length != 0;
    }
}

document.body.setAttribute('ondragstart','return false');

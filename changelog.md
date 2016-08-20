#SivaSiva App Changelog

###Revisions 8/14/2016 - jg
	Removed "close this stack" from all Home buttons. Changed API handler "loadModule" to close the original stack after the new one is topmost to avoid the screen flash when changing stacks. Fixed problem where clicking the Home button closed the current stack if it is already the topstack.

	Moved the mobileScroller script into a backscript and altered the json file and the stack's location in the file structure to match.

	Changed all pathing handlers in loader script to use specialFolderPath() instead of parsing the loader filename, which will break on Android. Removed all hard-coded relative file paths and replaced them with the generic functions in the loader stack.

	Added "pingServer" function to API script. Returns a boolean for internet availability. Requires a UTF8 text file on the server that contains only the word "true".

	Scroller is still not functional on mobile, working on it.


###Revisions 8/15/2016 - jg
	Scroller now working on all portals. Something is blocking mouseUp msgs, added touch msgs to portal_links backscript to accomodate. Needs testing on iOS but should work.
	
	
###Revisions 8/16/2016 - jg
	Changed the backcolor of all module stacks to black except "gems" which has no scroller layout and different coloration. The top images have tiny white corners that need correction (transparent corners would work best in case we change the backcolor again.)
	
	Set bottomBar background grc and group to 800 px wide to accomodate tablets.
	
	Removed mouseDouble* handlers in behavior_portal-links backscript.
	
	
###Revisions 8/18/2016 - jg
	Removed audio player script from audio card in Surprise, moved to libMobileAudioPlayer stack. Updated json config to load libMobileAudioPlayer.livecode as backscript.
	
	Revised portal-links behavior to check existence of logo img before showing it to avoid errors when current card doesn't have the image.
	
	Android controller now displays correctly, so we don't need the "Show Controller" button any more. Removed it.
	
	
###Revisions 8/19/2016 - jg
	Fixed libMobileAudioPlayer backscript which wasn't creating a mobile player control at all. It also now hides the LC player if the platform is mobile, since the LC one was visible as a grey box on Android.
	
	Revised mediaDataAndTransformers script to use a "try" structure in "fetchRandomMediaItem" to avoid script errors (and script abort) for audio files that return no metadata.
	
	Moved all the audio loading handlers in Surprise to openCard and added a new "showBusyIndicator" handler to libMobileAudioPlayer, which shows/hides an indicator on demand (desktop and mobile both.) Now the indicator can be called immediately when the audio card opens. Otherwise there was a significant delay on the portal card before the audio card and indicator appeared. Current glitch is I couldn't find the indicator gif BR added so right now desktop doesn't show one.
	
	



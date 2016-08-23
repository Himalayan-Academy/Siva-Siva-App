#SivaSiva App Changelog

# [Latest Entries on top]

###Revisions 8/22/2016 - jg
	Surprise Me - audio card
		Moved the text setup for the AudioDetails field into the "showAudioDetails" handler. Field handling is slow, so openCard immediately fetches and plays the audio while the details field is being adjusted for display.
		
		Added a mobile scroller to the AudioDetails field if the content is taller than the field height.
		
		Fixed all instances of isMobile() so the busy indicator works (the function was missing parentheses.)  Deleted hideBusyIndicator handler, replaced it with "showBusyIndicator false", a handler in the libMobileAudioPlayer backscript. 
		
		Optimized the openCard handler a bit.
		
	libMobileAudioPlayer backscript
		ShowBusyIndicator now shows/hides the "loading" button on desktop, if one exists. For use on other cards, be sure the button is named "loading" and it should work everywhere.
		
		

###Revisions 8/20/2016 - br

	Loader Gifs for Desktop
		Added two loader animated gifs to cd 2 of the loader stack the ID of the small one is 4106. but these don't play.. for some reason they lock up while scripts are executing
			
	Serverside: api3.lc 
		getRandomItem will not send any data from records that are not approved (these had bogus URLs which were hanging the player) Still, we might want a more robust URL validation before shipping the data to the app.
	
	mediaDataAndTransformers.livecode
		i) Removed test for approved for public = NO which was doing another call to the server which may have been locking up the network API. No longer needed since we do that server side now.	
		ii) removed html markup which was messing up the audio details field
		iii) fix path for songs with deity in their url path
		

	Surprise Me Module: 
	audio card --
		i) added button with the ID of the small loading GIF to hide and show on desktop but it does not actually run (locked up while LC executes open card handler)
		ii) added code to deal with longer metadata to constrain the field, add vScrollbar. Jacque will need to add the mobile scroller JG needs to add the mobile call  here.
		iii) fixed API3.lc to solve the problems of songs with Deity inpath and also no fetching of non
		iv) of style change to make the audio detail field look good and position nicely
		
	Verses index and single verse card -
		i) reset name of behavior that for the buttons, it works now. on mouse with we get a change
		ii) add more styling to the author, subject, citation... looks nice now.
		

###Revisions 8/18/2016 - jg
	Removed audio player script from audio card in Surprise, moved to libMobileAudioPlayer stack. Updated json config to load libMobileAudioPlayer.livecode as backscript.
	
		Revised portal-links behavior to check existence of logo img before showing it to avoid errors when current card doesn't have the image.

		Android controller now displays correctly, so we don't need the "Show Controller" button any more. Removed it.
	
###Revisions 8/17/2016 -br 
	Changed back color of all modules stack to the brown color to match the back ground color of the bottom navigation.

	This necessitated setting the ink for all the images to blendDist which makes the white transparent so the round corners did not show.		
	
###Revisions 8/16/2016 - jg
	Changed the backcolor of all module stacks to black except "gems" which has no scroller layout and different coloration. The top images have tiny white corners that need correction (transparent corners would work best in case we change the backcolor again.)
	
	Set bottomBar background grc and group to 800 px wide to accomodate tablets.
	
	Removed mouseDouble* handlers in behavior_portal-links backscript.
	
	
###Revisions 8/15/2016 - jg
	Scroller now working on all portals. Something is blocking mouseUp msgs, added touch msgs to portal_links backscript to accomodate. Needs testing on iOS but should work.
	
###Revisions 8/14/2016 - jg
	Removed "close this stack" from all Home buttons. Changed API handler "loadModule" to close the original stack after the new one is topmost to avoid the screen flash when changing stacks. Fixed problem where clicking the Home button closed the current stack if it is already the topstack.

	Moved the mobileScroller script into a backscript and altered the json file and the stack's location in the file structure to match.

	Changed all pathing handlers in loader script to use specialFolderPath() instead of parsing the loader filename, which will break on Android. Removed all hard-coded relative file paths and replaced them with the generic functions in the loader stack.

	Added "pingServer" function to API script. Returns a boolean for internet availability. Requires a UTF8 text file on the server that contains only the word "true".

	Scroller is still not functional on mobile, working on it.

	



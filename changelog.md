Revisions 8/14/2016:
	Removed "close this stack" from all Home buttons. Changed API handler "loadModule" to close the original stack after the new one is topmost to avoid the screen flash when changing stacks. Fixed problem where clicking the Home button closed the current stack if it is already the topstack.

	Moved the mobileScroller script into a backscript and altered the json file and the stack's location in the file structure to match.

	Changed all pathing handlers in loader script to use specialFolderPath() instead of parsing the loader filename, which will break on Android. Removed all hard-coded relative file paths and replaced them with the generic functions in the loader stack.

	Added "pingServer" function to API script. Returns a boolean for internet availability. Requires a UTF8 text file on the server that contains only the word "true".

	Scroller is still not functional on mobile, working on it.


Revisions 8/15/2016
	Scroller now working on all portals. Something is blocking mouseUp msgs, added touch msgs to portal_links backscript instead. Needs testing on iOS but should work.
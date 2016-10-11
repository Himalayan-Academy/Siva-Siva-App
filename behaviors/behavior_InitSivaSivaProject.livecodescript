script "behavior_InitSivaSivaProject"
--> MetaData
-
license: GPLv3
name: behavior_InitSivaSivaProject
type: behavior
version: 0.2

/*
Here we keep all initilisation code for the Siva-Siva-App.
This code originates from the Siva-Siva-App home card script.
We therefore set the behavior of the home card (first card) to this stacks script.

We use a behavior to take advantage of version control that we get with scriptonly stacks.

The preOpenStack handler (which is sent to the card), initialises all project defaults.
This includes loading all necessary libraries.

This card could be exactly the same as the loader stack, and not be shown on mobile.
Now we place the "sivasivahome" stacks contents, and separate any development testing and authoring into a new project "sivasiva_Tools"

We can now experiment with:

1) Using the new "Sivasiva Home" view to navigate to all module portal screens by setting it's "portal_Array"
2) Standardising navigation across all modules
3) Book marking and "hoisting"
4) Integration with the responsive "Sivasiva Browser" view.
*/


--> SivaSiva | Init
-
command init_AppConfiguration  
   /*
   Was called "loadAppConfiguration"
   
   Called by the "preOpenStack" of the Siva-Siva-App's first card script
   
   Avoid relying on "setBasePath" and instead pass long paths to handlers
   This is more robust as it is easy for a stray handler to reset the defaultfolder
   
   -- set the defaultstack to the topstack
   -- setBasePath -- jg
   */
   
   start using this stack -- "Siva-Siva-App" (only required for "sivasiva_ProjectFolder" handler)
   
   -- for logging
   put the name of stack "behavior_SivaSivaLogging" into loggingBehaviorObject --  must be in the stackfiles
   set the behavior of stack "behavior_InitSivaSivaProject" to loggingBehaviorObject -- not "me". We have to set the nested bheavior of the "behavior_InitSivaSivaProject" here.
   
   -- the first thing we must do is start using all required libraries
   init_LoadLibraries
   
   -- once we have loaded the libraries we can use them to load any needed configuration
   init_LoadJsonConfig
   
   -- set things up fro mobile
   if the environment is "mobile" then 
      set the fullscreenmode of this stack to "showAll"
      mobileSetAllowedOrientations "portrait,portrait upside down" -- lock to both portrait orientations, change later for certain modules
      if the platform = "iphone" then
         iphoneSetAudioCategory "playback" -- play when suspended or screen locked; Android doesn't need this
      end if
   end if
   
   -- here we can put custom handlers
   /*
   -- if not dev() then close me -- we are not using the invisible loader stack method any more
   goHome -- may not need to do this now as we place the portal stack on the home stacks card
   */
end init_AppConfiguration

command  init_LoadLibraries
   /*
   Consider moving front and backscripts to be regular libraries.
   We should not need to load any behaviors manually (needs checing on mobile).
   The only provisos / exceptions are:
   
   1) All behavior stacks are in the home stacks stackfiles
   2) Any behaviors of script only stacks (as the property is not stored) - this happens with nested behaviors such as logging.
   */
   
   put sivasiva_ProjectFolder() into projectFolder
   
   -- we start using both "library" stacks and "model" stacks
   project_UseStacksInFolder "models", projectFolder
   project_UseStacksInFolder "libraries", projectFolder
   /*
   -- old way to do it based on configuration
   put getPathForSharedLibraries() into sharedLibFolder
   repeat for each key x in sConfigA["libraries"]
      put sConfigA ["libraries"][x] into tStackPath
      load_Library tStackPath, sharedLibFolder
   end repeat
   */
   
   -- consider moving backscripts to libraries
   project_StartBackScriptsInFolder projectFolder
   /*
   -- old way to do it based on configuration
   repeat for each key x in sConfigA ["backscripts"]
      put  sConfigA ["backscripts"][x] into tStackPath
      load_BackScript tStackPath, sharedLibFolder
   end repeat
   */
   
   -- we should not need to use any frontscripts
   project_StartFrontScriptsInFolder projectFolder
   /*
   -- old way to do it based on configuration
   repeat for each key x in sConfigA["frontscripts"]
      put  sConfigA ["frontscripts"][x] into tStackPath
      _loadFrontScripts tStackPath, sharedLibFolder
   end repeat
   */
end init_LoadLibraries


-->Project | Start | Load
-
/*
Here we split out individual loading of required components.
For legibility and logging.
They must be public handlers for this to work.
*/

command load_Library stackPath, pShortFolder
   start using stack stackPath
end load_Library

command load_FrontScript stackPath
   insert the script of stack stackPath into front
end load_FrontScript

command load_BackScript stackPath
   insert the script of stack stackPath into back
end load_BackScript


-->Project | Start
-
command project_StartBackScriptsInFolder projectFolder
   put projectFolder & "backscripts" & slash into standardFolder
   put folder_ListStackPaths (standardFolder) into stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      load_BackScript stackPath
   end repeat
   return stackPaths
end project_StartBackScriptsInFolder

command project_StartFrontScriptsInFolder projectFolder
   put projectFolder & "frontscripts" & slash into standardFolder
   put folder_ListStackPaths (standardFolder) into stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      load_FrontScript stackPath
   end repeat
   return stackPaths
end project_StartFrontScriptsInFolder

command project_UseStacksInFolder shortFolder, projectFolder
   put projectFolder & shortFolder & slash into standardFolder
   put folder_ListStackPaths (standardFolder) into stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      load_Library stackPath, shortFolder
   end repeat
   return stackPaths
end project_UseStacksInFolder


--> Deps
-
function folder_ListStackPaths someFolder
   -- new version: version 8.1
   if there is not a folder someFolder then return empty
   
   put files (someFolder) into shortFiles
   set the itemdelimiter to "."
   repeat for each line shortFile in shortFiles
      put someFolder & shortFile into stackFilePath
      if there is a stack stackFilePath then
         put stackFilePath & CR after stackFilePaths
      end if
   end repeat
   delete char -1 of stackFilePaths
   return stackFilePaths
end folder_ListStackPaths

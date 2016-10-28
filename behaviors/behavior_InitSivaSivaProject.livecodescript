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

== Future ==
When this code is fully robust and tested, and no longer changing / evolving,
we can move it back to the card script. That way we avoid nested bahaviors

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

--> Variables
-
local LocalArray


--> SivaSiva | Init | Logging
-
/*
We aim to remove the need for this section eventually.
When the code is minimized, tested and stable we can move it back to the card script,
and even stop loggin the initialisation routines by default
and include it only as an option (advanced) feature/tool.
*/

command init_Logging
   --  relies on stack names so ensure the stackfiles is set properly
   -- we have to ensure the general purpose logging handlers are loaded first
   start using stack "model_SivaSivaLog"
   log_Clear
   
   /*
   -- set nested behavior for logging. This is needed as scriptonly stack do not remember their behaviors
   -- we could remove this step if we move this code back to the card script
   log_Append "Before behavior_SivaSivaLogging"
   put exists (stack "behavior_SivaSivaLogging") into stackExists
   if stackExists then
      put the name of stack "behavior_SivaSivaLogging" into loggingBehaviorObject
      set the behavior of stack "behavior_InitSivaSivaProject" to loggingBehaviorObject -- not "me". We have to set the nested bheavior of the "behavior_InitSivaSivaProject" here.
      log_Append "Set behaviors"
   end if
   log_Append stackExists
   */
   
   log_SetLevelList "all"
   log_Append "End of init_Logging"
end init_Logging


--> SivaSiva | Init
-
function init_GetStatus
   return the stacksinuse is not empty
end init_GetStatus

command init_AppConfiguration
   /*
   Called by the "preOpenStack" of the Siva-Siva-App's first card script
   */
   if init_GetStatus() is true then
      -- let's not initialise twice
      -- answer "Exiting init_AppConfiguration"
      return false
   end if
   
   -- the first thing we must do is know where the top-level project is
   start using stack "model_SivaSivaFiles"
   put sivasiva_ProjectFolder() into projectFolder
   
   -- then
   init_Logging
   -- log_Append "Finished init_Logging"
   
   -- then start using all required libraries
   init_LoadLibraries projectFolder
   
   -- once we have loaded the libraries we can use them to load any needed configuration
   init_LoadJsonConfig
   
   -- set things up for mobile geometry
   if the environment is "mobile" then 
      init_MobileGeometry
   end if
end init_AppConfiguration

command  init_LoadLibraries projectFolder
   -- we start using both "library" stacks and "model" stacks
   project_UseStacksInFolder "models", projectFolder
   project_UseStacksInFolder "libraries", projectFolder
   
   -- consider moving backscripts to libraries
   project_StartBackScriptsInFolder projectFolder
   
   -- we should not need to use any frontscripts
   project_StartFrontScriptsInFolder projectFolder
end init_LoadLibraries

command init_MobileGeometry
   -- see "initializeInterfaceDefaults"
   -- set the fullscreenmode of this stack to "showAll"
   mobileSetAllowedOrientations "portrait,portrait upside down" -- lock to both portrait orientations, change later for certain modules
   if the platform = "iphone" then
      iphoneSetAudioCategory "playback" -- play when suspended or screen locked; Android doesn't need this
   end if
end init_MobileGeometry


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
   put sivasiva_ListStackPaths (standardFolder) into stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      load_BackScript stackPath
   end repeat
   return stackPaths
end project_StartBackScriptsInFolder

command project_StartFrontScriptsInFolder projectFolder
   put projectFolder & "frontscripts" & slash into standardFolder
   put sivasiva_ListStackPaths (standardFolder) into stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      load_FrontScript stackPath
   end repeat
   return stackPaths
end project_StartFrontScriptsInFolder

command project_UseStacksInFolder shortFolder, projectFolder
   put projectFolder & shortFolder & slash into standardFolder
   put sivasiva_ListStackPaths (standardFolder) into stackPaths
   
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      load_Library stackPath, shortFolder
   end repeat
   return stackPaths
end project_UseStacksInFolder


--> Deps
-
function sivasiva_ListStackPaths someFolder  
   put mobile_ListLongFiles (someFolder, "Siva-Siva-App") into longFiles
   repeat for each line stackFilePath in longFiles
      if there is a stack stackFilePath then
         put stackFilePath & CR after stackFilePaths
      end if
   end repeat
   delete char -1 of stackFilePaths
   return stackFilePaths
end sivasiva_ListStackPaths

function mobile_ListLongFiles someFolder, homeStackName
   put mobile_ListShortFiles (someFolder, homeStackName) into shortFiles
   repeat for each line shortFile in shortFiles
      if char 1 of shortFile is "." then next repeat
      put someFolder & shortFile & CR after longFiles
   end repeat
   delete char -1 of longFiles
   return longFiles
end mobile_ListLongFiles

function mobile_ListShortFiles someFolder, homeStackName
   -- bug: this function includes hack to fix Livecode bug on Android by setting the defaultstack
   -- requires Livecode 8.1 or greater
   if there is not a folder someFolder then return empty
   
   put the defaultstack into oStack
   set the defaultstack to homeStackName
   put files (someFolder) into shortFiles
   set the defaultstack to oStack
   return shortFiles
end mobile_ListShortFiles

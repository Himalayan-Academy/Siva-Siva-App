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


--> Events
-
on preOpenStack
   -- start using this stack
   init_AppConfiguration -- load all libraries and configure app
   
   sivasiva_InitOrientation "portrait"
   set the acceleratedRendering of this stack to true
   
   put the portal_View of me into portalView
   _fixPortalBehavior portalView
   set the rect of portalView to the rect of this card -- only useful for authoring
   
   set the portal_Name of portalView to "home"
   
   pass preOpenStack
end preOpenStack

on openCard
   put the portal_View of me into portalView
   put the scrolling_View of me into scrollingView
   
   if the environment is "mobile" then
      set the mobile_VerticalScroller of scrollingView to "portal scroller"
   end if
   
   set the logo_Faded of portalView to true
   pass openCard
end openCard

on closeCard
   if the environment is "mobile" then
      scroller_Delete "portal scroller"
   end if
   pass closeCard
end closeCard

on reLaunch
   answer "went back to home module"
   pass reLaunch
end reLaunch

private command _fixPortalBehavior portalView
   put the name of stack "behavior_ViewSivaSivaLayout" into bObject
   set the behavior of portalView to bObject -- just in case
   
   -- another hack to fix behaviors in case they are broken
   -- preOpenControl does not seem to always fix the issue of broken bahaviors
   dispatch "portal_InitBehaviors" to portalView
end _fixPortalBehavior


--> SivaSiva | Init | Logging
-
/*
We aim to remove the need for this section eventually.
When the code is tested and stable we can stop loggin the initialisation routines
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
   put "lib_SivaSiva" is among the lines of the stacksinuse into someBoolean
   return someBoolean
end init_GetStatus

command init_AppConfiguration
   -- called by the "preOpenStack" of the Siva-Siva-App's first card script
   
   -- if init_GetStatus() is true then return false
   
   -- the first thing we must do is know where the top-level project is
   start using stack "model_SivaSivaFiles"
   
   -- then
   init_Logging
   
   -- then start using all required libraries
   init_LoadLibraries
   
   -- once we have loaded the libraries we can use them to load any needed configuration
   init_LoadJsonConfig
   
   -- set things up for mobile geometry
   if the environment is "mobile" then 
      init_MobileGeometry
   end if
end init_AppConfiguration

command  init_LoadLibraries projectFolder  
   -- we start using both "library" stacks and "model" stacks
   
   put "lib_SivaSiva,lib_SivaSivaPortal,lib_MobileControls,model_SivaSiva,model_SivaSivaConfig" into stackNames
   repeat for each item stackName in stackNames
      if there is a stack stackName then
         start using stack stackName
      else
         answer stackName
      end if
   end repeat
   -- answer the stacksinuse
   return true
   
   put project_ListFolderStacks ("libraries") into stackPaths
   project_UseStacks stackPaths
   
   put project_ListFolderStacks ("models") into stackPaths
   project_UseStacks stackPaths
   
   -- project_StartBackScriptsInFolder projectFolder
   -- project_StartFrontScriptsInFolder projectFolder
end init_LoadLibraries

command init_MobileGeometry
   -- see "initializeInterfaceDefaults"
   -- set the fullscreenmode of this stack to "showAll"
   mobileSetAllowedOrientations "portrait,portrait upside down" -- lock to both portrait orientations, change later for certain modules
   if the platform = "iphone" then
      iphoneSetAudioCategory "playback" -- play when suspended or screen locked; Android doesn't need this
   end if
end init_MobileGeometry


-->Project | Start
-
command project_UseStacks stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      load_Library stackPath, shortFolder
   end repeat
   return stackPaths
end project_UseStacks

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


--> Deps
-
-- function sivasiva_ListStackPaths someFolder  
   put mobile_ListLongFiles (someFolder, "Siva-Siva-App") into longFiles
   repeat for each line stackFilePath in longFiles
      if there is a stack stackFilePath then
         put stackFilePath & CR after stackFilePaths
      end if
   end repeat
   delete char -1 of stackFilePaths
   return stackFilePaths
end sivasiva_ListStackPaths

-- function mobile_ListLongFiles someFolder, homeStackName
   put mobile_ListShortFiles (someFolder, homeStackName) into shortFiles
   repeat for each line shortFile in shortFiles
      if char 1 of shortFile is "." then next repeat
      put someFolder & shortFile & CR after longFiles
   end repeat
   delete char -1 of longFiles
   return longFiles
end mobile_ListLongFiles

-- function mobile_ListShortFiles someFolder, homeStackName
   -- bug: this function includes hack to fix Livecode bug on Android by setting the defaultstack
   -- requires Livecode 8.1 or greater
   if there is not a folder someFolder then return empty
   
   put the defaultstack into oStack
   set the defaultstack to homeStackName
   -- put files (someFolder) into shortFiles -- this is not working on Android with LC 8.2 rc2
   put the files into shortFiles -- this fixes things
   set the defaultstack to oStack
   
   -- answer there is a folder someFolder & CR & shortFiles
   return shortFiles
end mobile_ListShortFiles

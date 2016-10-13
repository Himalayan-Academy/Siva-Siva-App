script "behavior_SivaSivaLogging"
--> Metadata
-
license: GPLv3
name: behavior_SivaSivaLogging
type: behavior
version: 0.1

/*
This is the Siva-Siva-App's home card logging script.
It is designed to log project initialization.

We have moved the logging handlers to this behavior so we can use before and after handlers for logging.
This improves legibility, forces us to write the code in a nice modular fashion, the and allows us to simply remove all logging when we deploy.

We use a nested behavior. The nested behaviors are:

-  behavior_InitSivaSivaProject
-  behavior_SivaSivaLogging

The first contains the minimal scripts needed for initlising the project on mobile (and desktop).
The second before and after logging handlers for checking this initialisation proceeds properly.

Yes it would be simpler if this was a library/back/frontscript and not a behavior (or embedded within the application code),
but this code is only needed for initialisation of the project,
so we like to isolate it from the general code andkeep it attached to the card as two nested behaviors.
*/


--> Logging | Custom
-
command jgAndroidLog  --jg: temporary for testing; sent from Home btn in Home stack  --### REMOVE
   if (the platform = "android") and (the hilite of btn "jg android log" of me) then 
      put specialFolderPath("documents") & "/mobilelog.txt" into tFile
      answer "Clear or view log:" with "Cancel" or "Clear" or "View"
      if it = "view" then
         answer url ("file:" & tFile)
      else if it = "clear" then
         put empty into url ("file:" & tFile)
      end if
   end if
end jgAndroidLog


--> Events | Android test builds (okay to remove later)
-
on savingStandalone -- pre-processss
  -- if not an Android app, turn off android logging
  put (the cRevStandaloneSettings["android"] of me = true) into tIsAndroid
  set the hilite of btn "jg android log" of cd 1 of me to tIsAndroid
  set the vis of fld "logfld" of cd 1 of me to tIsAndroid
end savingStandalone

on standaloneSaved pFolder -- post-process
  -- increase build number for next time, turn logging back on
  -- Will be saved at next manual save, otherwise we don't want it anyway.
  put (the cRevStandaloneSettings["android"] of me = true) into tIsAndroid
  if tIsAndroid then
    put the cRevStandaloneSettings["android,version code"] of me into tBuildNum
    add 1 to tBuildNum
    set the cRevStandaloneSettings["android,version code"] of me to tBuildNum
    
    set the hilite of btn "jg android log" of cd 1 of me to tIsAndroid
    set the vis of fld "logfld" of cd 1 of me to false
  end if
end standaloneSaved


--> Init
-
after init_AppConfiguration
   -- convenience for desktop use
   set the loc of this stack to the screenloc
   if "API" is in the backscripts then scaleStackIfNeeded -- otherwise fails on loader launch
end init_AppConfiguration


--> Logging | before and After
-
before init_LoadJsonConfig
   log_Info "About to load App configuration..."
end init_LoadJsonConfig

after init_LoadJsonConfig
   log_Info "App configuration loaded..."
end init_LoadJsonConfig

before load_Library tStackPath, sharedLibFolder
   log_Info "Loading library" && tStackPath
end load_Library

before load_FrontScript tStackPath, sharedLibFolder
   log_Info "Loading frontscript" && tStackPath
end load_FrontScript

before load_BackScript tStackPath, sharedLibFolder
   log_Info "Loading backscript" && tStackPath
end load_BackScript

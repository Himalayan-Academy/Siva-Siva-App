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


--> Events | Android test builds (okay to remove later)
-
on savingStandalone -- pre-processss
  -- if not an Android app, turn off android logging
  put (the cRevStandaloneSettings["android"] of me = true) into tIsAndroid
  set the hilite of btn "jg android log" of cd "Legacy" of me to tIsAndroid
  set the vis of fld "logfld" of cd "Legacy" of me to tIsAndroid
end savingStandalone

on standaloneSaved pFolder -- post-process
  -- increase build number for next time, turn logging back on
  -- Will be saved at next manual save, otherwise we don't want it anyway.
  put (the cRevStandaloneSettings["android"] of me = true) into tIsAndroid
  if tIsAndroid then
    put the cRevStandaloneSettings["android,version code"] of me into tBuildNum
    add 1 to tBuildNum
    set the cRevStandaloneSettings["android,version code"] of me to tBuildNum
    
    set the hilite of btn "jg android log" of cd "Legacy" of me to tIsAndroid
    set the vis of fld "logfld" of cd "Legacy" of me to false
  end if
end standaloneSaved


--> Init
-
after init_Logging
   log_Info "After init_Logging..."  
end init_Logging

after init_AppConfiguration
   if the environment is "development" then
      -- convenience for desktop use
      if "API" is in the backscripts then scaleStackIfNeeded -- otherwise fails on loader launch
      set the loc of this stack to the screenloc
   end if
   
   log_Info ("After" && the params)
end init_AppConfiguration


--> Logging | Libraries
-
after init_UseHome
   log_Info ("After" && the params)
end init_UseHome

before load_Library tStackPath, sharedLibFolder
   log_Info ("Before" && the params)
end load_Library

before load_FrontScript tStackPath, sharedLibFolder
   log_Info ("Before" && the params)
end load_FrontScript

before load_BackScript tStackPath, sharedLibFolder
  log_Info ("Before" && the params)
end load_BackScript


--> Logging | Config
-
before init_LoadJsonConfig
   log_Info ("Before" && the params)
end init_LoadJsonConfig

after init_LoadJsonConfig
   log_Info ("After" && the params)
end init_LoadJsonConfig

before init_MobileGeometry
   log_Info ("Before" && the params)
end init_MobileGeometry

after init_MobileGeometry
   log_Info ("After" && the params)
end init_MobileGeometry

before init_HomeDisplay
   log_Info ("Before" && the params)
end init_HomeDisplay

after init_HomeDisplay
   log_Info ("After" && the params)
end init_HomeDisplay

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
so we like to isolate it from the general code and keep it attached to the card as two nested behaviors.
*/


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

-- before load_FrontScript tStackPath, sharedLibFolder
   log_Info ("Before" && the params)
end load_FrontScript

-- before load_BackScript tStackPath, sharedLibFolder
  log_Info ("Before" && the params)
end load_BackScript

before errorDialog p1, p2
   put "livecode error:" && p1, p2
end errorDialog

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

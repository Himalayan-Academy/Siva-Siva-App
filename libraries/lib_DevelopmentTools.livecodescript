script "lib_DevelopmentTools"
on libraryStack
   if the target is not me then
      pass libraryStack
   end if
   
   send updateUI to me in 500 milliseconds
end libraryStack

on updateUI
   if the environment is "development" and the altKey is down then
      go stack "DevelopmentTools"
   end if
end updateUI

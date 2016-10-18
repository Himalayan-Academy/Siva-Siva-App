script "lib_Android"
--> MetaData
-
license: GPLv3
name: lib_Android
type: library
version: 0.1

/*
Here we place hanlders that are specific tot he Android platform.
Put any Android only handlers in here.
*/


--> Events
-
on backKey --jg: for Android; otherwise goes to loader screen  --### jg: not right yet
   -- msg is only sent on mobile
   -- recentcards isn't stable, try this way:
   
   go recent
   put the recentcards into rCards
   answer rCards
end backKey



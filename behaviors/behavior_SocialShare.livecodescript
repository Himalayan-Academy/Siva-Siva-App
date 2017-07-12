script "behavior_SocialShare"

/*
This script is designed to be the behavior of group "shareControls" of the card "main-view" of stack "Gurudeva" 

put url "http://www.himalayanacademy.com/media/apps/gurudeva/img/00-gurudeva-1-5_1472_opt-75_fp242.jpg"
put url "http://www.himalayanacademy.com/media/apps/gurudeva/img/thumb/00-gurudeva-1-5_1472_opt-75_fp242.jpg"

*/

global gCurrentQuote
global gCurrentAudio

constant cGurudevaAppUrl = "http://www.himalayanacademy.com/apps/gurudeva"
constant cIosHimalayanAppUrl = "https://itunes.apple.com/us/app/hinduism-today/id1023295974?mt=8"
constant cAndroidHimalayanAppUrl = "https://play.google.com/store/apps/details?id=air.com.yudu.ReaderAIR6213949"
constant cGurudevaImageFolder = "http://www.himalayanacademy.com/media/apps/gurudeva/"
constant cGurudevaThumbFolder = "http://www.himalayanacademy.com/media/apps/gurudeva/img/thumb/"


--> Override
-
/*
These handlers override handlers in the stack "Gurudeva" script.

In the long term they should replace the ones in the stack script.
We attempt to avoid global variables and use parameters tomake all handlers in the rest of the code portable.
*/

command share_MouseEvent
   dispatch "share_Items" to this card
   
   # share_items should be in your module stack
   # and return an array sShareItemsA
   # which contains values for shared data from the current card of that stack
   # but if not included in the current stack/ then:
   
   if it = "unhandled" then
      # we have no specific items from the card
      # so pass generic items will be passed below
   else
      put the result into sShareItemsA 
      # Should at least always include a URL, text, and subject for email
   end if
   
    if sShareItemsA["url"]  is empty then        
         put "https://www.himalayanacademy.com/looklisten/apps/sivasiva" into sShareItemsA["url"]
      end if
      if  sShareItemsA["text"] is empty then
         put "Check out the new SivaSiva App, a vast realm of marvelous content!" into sShareItemsA["text"]
      end if
      if sShareItemsA["subject"] is empty then
         put "Get the SivaSiva App" into sShareItemsA["subject"]
      end if
   
   put urlEncode(sShareItemsA["url"]) into tURLEncodedURL
   
   put the short name of the target into pShareChoice
   if  pShareChoice ="close-sharing" then
      if exists (widget "body" of this card) then
         set the top of widget "body" to 0
      end if
      hide group "share-ui"
   else
      switch pShareChoice         
         case "facebook"         
            put merge("https://www.facebook.com/dialog/share?app_id=767840830064772&display=page&href=[[tURLEncodedUrl]]&redirect_url=[[tURLEncodedUrl]]")  into tShareURL
            launch url tShareURL
            break
         case "tweet"
            twitter_TweetItems sShareItemsA
            break
         Case "email"
            share_Email sShareItemsA
            break
      end switch
   end if
end share_MouseEvent

command Share_Email sShareItemsA
   put sShareItemsA["subject"] into tSubject
   put empty into tAddress
   put  sShareItemsA["text"] &  CR & CR  & sShareItemsA["url"] into tBody
   revMail tAddress,,tSubject,tBody
end share_Email

command twitter_TweetItems sShareItemsA
   put twitter_EncodeIntent (sShareItemsA["text"]) into encodedText
   put "http://www.twitter.com/intent/tweet?text=" & encodedText into someUrl
  put "&url=" & urlencode (sShareItemsA["url"]) after someUrl
   launch url someUrl
end twitter_TweetItems

----------------------- GURUDEVA APP SHARE LIBRARY-------------
# All the following were from the Gurudeva app and need to be refactored for this app
# many of these are deprecated since we are not apply any cosmetics to the buttons
# also  Andre's library is required... but we have yet to add into the repository.
# Please move functional handlers above this comment when they move into active service
# ----------------------------------------------------------------------

command shareQuote pShareChoice
   -- this handler intercepts / replaces the handler in the stack "Gurudeva" script
   
   if the short name of this cd = "audio" then --jg: branch for audio sharing
      shareAudio pShareChoice
      exit shareQuote
   end if
   
   switch pShareChoice
      case "email"
         share_Email gCurrentQuote
         break
      case "tweet"
         share_Tweet gCurrentQuote
         break
      case "facebook"
         share_FaceBook gCurrentQuote
         break
   end switch
   -- set the hidden_Group ["Share"] of card "main-view" to "shareControls"
   setGrpVis "shareControls", "Share", false
   clearTabHighlights
end shareQuote


--> Share
-
command share_FaceBook pQuote
   put CR & CR & _GetGurudevaAppText() after pQuote
   
   switch the platform
      case "android"
         android_ShareFacebook pQuote
         break
      case "iphone"
         iphone_ShareFaceBook pQuote
         break
      default
         -- put "Desktop Facebook option coming later from David"
   end switch
end share_FaceBook

command share_Tweet pQuote
   switch the platform
      case "android"
         twitter_ShareQuote pQuote
         break
      case "iphone"
         iphone_ShareTweet pQuote
         break
      default
         twitter_ShareQuote pQuote
   end switch
end share_Tweet



command shareAudio pShareChoice
   global gCurrentAudio
   
   if gCurrentAudio = "" then
      answer "Select an audio to share."
      exit shareAudio
   end if
   
   switch pShareChoice
      case "email"
         put empty into tAddress
         put "Here is a Gurudeva audio" into tSubject
         put email_ConstructAudioText() into tBody
         revMail tAddress,,tSubject,tBody
         break
      case "tweet"
         twitter_ShareAudio
         break
      case "facebook"
         facebook_ShareAudio
         break
   end switch
   setGrpVis "shareControls", "Share", false
   clearTabHighlights
end shareAudio

command twitter_ShareAudio
   switch the platform
      case "android"
         android_ShareAudioTweet
         break
      case "iphone"
         iphone_ShareAudioTweet
         break
      default
         desktop_ShareAudioTweet
   end switch
end twitter_ShareAudio

command facebook_ShareAudio
   switch the platform
      case "android"
         android_ShareAudioFaceBook
         break
      case "iphone"
         iphone_ShareAudioFaceBook
         break
      default
         desktop_ShareAudioFaceBook
   end switch
end facebook_ShareAudio

   
--> Android
-
command android_ShareTweet pQuote
   twitter_ShareQuote pQuote
end android_ShareTweet

command android_ShareAudioTweet
   put audio_ConstructTweet() into someTweet
   twitter_ShareQuote someTweet
end android_ShareAudioTweet

command android_ShareFacebook pQuote
   fb_ShareQuote pQuote
end android_ShareFacebook

command android_ShareAudioFaceBook
   put audio_ConstructTweet() into someText
   put CR & CR & _GetGurudevaAppText() after someText
   
   fb_ShareAudio someText
end android_ShareAudioFaceBook


--> iPhone | Share
-
command iphone_ShareTweet pQuote  
   put the filename of image "currentGDPhoto" of card "main-view" into imagePath
   if mergSocialIsAvailableForServiceType ("twitter") is true then 
      mergSocial "twitter", pQuote, imagePath, cGurudevaAppUrl
   else
      twitter_ShareQuote pQuote
   end if
end iphone_ShareTweet

command iphone_ShareAudioTweet
   -- put audio_ConstructTweet() into someTweet
   put "Here is a Gurudeva audio:" && audio_ConstructUrl() into someTweet
   put empty into imagePath
   mergSocial "twitter", someTweet, imagePath, cGurudevaAppUrl
end iphone_ShareAudioTweet

command iphone_ShareAudioFaceBook
   put audio_ConstructTweet() into someText
   put CR & CR & _GetGurudevaAppText() after someText
   
   fb_ShareAudio someText
   return empty
   
   -- since the latest update it appears none of the mergSocial "facebook" prefill text options work?
   -- tested on iPAD, but earlier iPhone worked?
   if mergSocialIsAvailableForServiceType ("facebook") is true then
      if version_IsEarlier (the systemversion, "9.1") then
         mergSocial "facebook", someText
      else
         fb_ShareAudio someText
      end if
   else
      fb_ShareAudio someText
   end if
end iphone_ShareAudioFaceBook

command iphone_ShareFaceBook pQuote
   fb_ShareQuote pQuote
   return empty
   
   -- since the latest update it appears none of the mergSocial "facebook" prefill text options work?
   -- tested on iPAD, but earlier iPhone worked?
   if mergSocialIsAvailableForServiceType ("facebook") is true then
      if version_IsEarlier (the systemversion, "9.1") then
         put the filename of image "currentGDPhoto" of card "main-view" into imagePath
         mergSocial "facebook", pQuote, imagePath
      else -- the systemversion is "9.1" or the systemversion begins with "9.1." then
         fb_ShareQuote pQuote
      end if
   else
      -- fb_ShareQuote pQuote
   end if
end iphone_ShareFaceBook


--> Desktop
-
command desktop_ShareAudioTweet
   -- put "Desktop Audio Tweet option coming later."
   android_ShareAudioTweet
end desktop_ShareAudioTweet


--> Share | Utils
-
command fb_ShareAudio pQuote 
   -- https://developers.facebook.com/docs/graph-api/reference/v2.0/user/feed
   
   put fb_StoreAccessToken() into fbAccessToken
   if fbAccessToken is empty then
      fb_Authenticate
      exit to top
   else
      fb_UseLibrary
      fbSetAccessToken fbAccessToken
   end if
   
   put unidecode (uniencode (pQuote), "UTF8") into pQuote
   
   put "/me/feed" into publishWhere
   put pQuote into tDataA ["message"]
   put cGurudevaAppUrl into tDataA ["link"]
   
   mobileBusyIndicatorStart "square", "Posting..."
   put fbPost (publishWhere, tDataA) into tA
   mobileBusyIndicatorStop
   
   if fbIsError(tA) then
      -- if there is an authentication problem (perhaps it is out of date?), we should:
      -- fb_StoreAccessToken empty
      answer error tA["error"]["message"]
   else
      -- answer "Posted quote to Facebook with id:" && tA["id"] & "!"
      answer "Your audio link has been posted to Facebook!"
   end if
end fb_ShareAudio

command fb_ShareQuote pQuote  
   put fb_StoreAccessToken() into fbAccessToken
   if fbAccessToken is empty then
      fb_Authenticate
      exit to top
   else
      fb_UseLibrary
      fbSetAccessToken fbAccessToken
   end if
   
   put unidecode (uniencode (pQuote), "UTF8") into pQuote
   put "/me/photos" into publishWhere
   put pQuote into tNonBinaryA ["message"] -- UTF-8 string, including emoji
   put the filename of image "currentGDPhoto" of card "main-view" into imagePath
   put imagePath into tBinaryA ["source"]
   
   mobileBusyIndicatorStart "square", "Posting..."
   put fbPostBinary (publishWhere, tNonBinaryA, tBinaryA) into tA
   mobileBusyIndicatorStop
   
   if fbIsError(tA) then
      -- if there is an authentication problem (perhaps it is out of date?), we should:
      -- fb_StoreAccessToken empty
      answer error tA["error"]["message"]
   else
      -- answer "Posted quote to Facebook with id:" && tA["id"] & "!"
      answer "Your quote has been posted to Facebook!"
   end if
end fb_ShareQuote



function twitter_EncodeIntent pQuote

   put unidecode (uniencode (pQuote), "UTF8") into pQuote
   put urlencode (pQuote) into encodedText
   
   put 140 -26 into tMaxLen
   if len(pQuote) >tMaxLen then # actually 140 but the URL takes 23 characters
      --### POPULATE EDIT FLD, SHOW EDITING GRP
      -- user can trim in the dialogue
   put char 1 to tMaxLen of encodedText & "..." into encodedText
   end if
   return encodedText
end twitter_EncodeIntent

function email_ConstructAudioText
   -- put gCurrentAudio into tFileName
   -- set the itemDel to "."
   -- delete last item of tFileName -- file extension
   
   put audio_ConstructUrl() into tBody
   put CR & CR & "__________________________________" & CR & CR & "Get the Gurudeva App:" & CR & CR & cGurudevaAppUrl after tBody 
   return tBody
end email_ConstructAudioText

-- function construct_EmailAppLink
   put CR & CR & "__________________________________" & CR & CR into tBody
   put "Get the Gurudeva App" & CR &CR & \
         "iOS:" && cIosHimalayanAppUrl & CR &CR & "Android: link here:  https://play.google.com/store/apps/details?id=air.com.yudu.ReaderAIR6213949" after tBody
   return tBody
end construct_EmailAppLink

function audio_ConstructUrl
   if gCurrentAudio = "" then return empty
   
   put gCurrentAudio into tFileName
   put the itemDel into oDelim
   set the itemDel to "."
   delete last item of tFileName -- file extension
   -- replace space with "%20" in tFileName -- should this not be urlEncode???
   put urlencode(tFileName) into tFileName
   
   put "http://www.himalayanacademy.com/view/" & tFileName into audioUrl
   set the itemDel to oDelim
   return audioUrl
end audio_ConstructUrl

function audio_ConstructTweet
   put "Here is a Gurudeva audio:" && audio_ConstructUrl() into someTweet
   -- put space & _GetGurudevaAppText() after someTweet
   return someTweet
end audio_ConstructTweet

private function _GetGurudevaAppText
   return "Get the Gurudeva App:" && cGurudevaAppUrl
end _GetGurudevaAppText


--> Events
-
on preOpenControl
   -- "preOpenCard" does not work as not passed by Jacque
   -- this get's sent to the group every time the card is opened
   
   switch the platform
      case "android"
         set the display_FacebookButton of me to fb_IsAuthenticated()
         break
      case "iphone"
         set the display_FacebookButton of me to true
         break
      default
         -- put "Desktop Twitter option coming later from David"
   end switch
   pass preOpenControl
end preOpenControl


--> Objects
-
function fb_Button
   put the long id of btn "facebooks" of me into fbButton
   return fbButton
end fb_Button


--> Display
-
getprop display_FacebookButton
   put the innerglow ["color"] of fb_Button() is empty into isAuthenticated
   -- put the disabled of fb_Button() into someBoolean
   return isAuthenticated
end display_FacebookButton

setprop display_FacebookButton isAuthenticated
   -- diplays / changes state of the facebook button
   -- if true then the facebook button is showing
   -- if false then the "authernitcate facebook button" is showing
   
   -- set the disabled of fb_Button() to someBoolean
   if isAuthenticated is true then
      set the innerglow of fb_Button() to empty
   else
      put "255,0,128" into propArray ["color"]
      put "normal" into propArray ["blendmode"]
      
      put "box1pass" into propArray ["filter"]
      put 255 into propArray ["opacity"]
      put 255 into propArray ["range"]
      put 128 into propArray ["size"]
      
      put "edge" into propArray ["source"]
      put 0 into propArray ["spread"]
      
      set the innerglow of fb_Button() to propArray
   end if
end display_FacebookButton


--> Facebook | Authentication
-
function fb_IsAuthenticated
   put fb_StoreAccessToken() into fbAccessToken
   put fbAccessToken is not empty into someBoolean
   return someBoolean
end fb_IsAuthenticated

command fb_Authenticate
   -- put "aagFacebookMobileLib7.livecode" into somePath this works on iOS, but not on Android
   -- specifying the full path works on both platforms
   put "authenticating..."
   fb_UseLibrary
   fbSetAppID "834806986632748"
   fbAuthenticate "basic_info,publish_actions" -- user_groups
   return the result
end fb_Authenticate

command fb_UseLibrary
   put the engine folder & "/aagFacebookMobileLib7.livecode" into somePath
   start using somePath
end fb_UseLibrary

on onFacebookAuthenticationComplete pDataA
   put pDataA["access_token"] into fbAccessToken
   fb_StoreAccessToken fbAccessToken
   set the display_FacebookButton of fb_Button() to true
   answer "You have succesfully authenticated the Gurudeva app with Facebook."
end onFacebookAuthenticationComplete

on onFacebookError pA
   set the display_FacebookButton of fb_Button() to false
   answer "error:" && pA["error"]["error_reason"] -- & CR after fld "log"
end onFacebookError

function fb_StoreAccessToken
   put fb_AccessTokenFile() into accessTokenFile
   put url ("binfile:" & accessTokenFile) into fbAccessToken
   return fbAccessToken
end fb_StoreAccessToken

command fb_StoreAccessToken fbAccessToken
   put fb_AccessTokenFile() into accessTokenFile
   put fbAccessToken into url ("binfile:" & accessTokenFile)
   return accessTokenFile
end fb_StoreAccessToken

function fb_AccessTokenFile
   put pref_Folder() & "fbAccessToken.txt" into accessTokenFile
   return accessTokenFile
end fb_AccessTokenFile

function pref_Folder
   put specialFolderPath("cache") into prefFolder
   put "/" after prefFolder
   return prefFolder
end pref_Folder

function version_IsEarlier testVersion, refVersion
   -- no longer needed if no mergExt Facebook works at all?
   /*
   -- the systemversion is "9.1" or the systemversion begins with "9.1." then
   if testVersion is "9.1" or testVersion begins with "9.1." then
      return false
   else
      return true
   end if
   */
   
   -- for some reason this crashes (on Android???)
   put _convertVersionToNumber (refVersion) > _convertVersionToNumber (testVersion) into isEarlier
   return isEarlier
end version_IsEarlier

function _convertVersionToNumber someVersion
   -- assumes a version of the format ###.###.###
   -- to be safe each number can be up to 3 digits (they are usually 2)
   set the itemdelimiter to "."
   set the numberformat to "000"
   put (item 1 of someVersion + 0) & (item 2 of someVersion + 0) & (item 3 of someVersion + 0) into someNum
   return someNum
end _convertVersionToNumber


--> Objects
-
function fb_Button
   put the long id of btn "facebooks" of me into fbButton
   return fbButton
end fb_Button


--> Junk
-
-- on enableQuoteButtons
   -- quick hack here as Jacque did not pass preOpenCard
   set the display_FacebookButton of me to fb_IsAuthenticated()
   
   put  "Favorites,Share,Search,Categories"  into pButtons --jg: option btn always visible
   repeat for each item x in pButtons
      set the disabled of button x of grp "tabNavButtons" to false
      show btn x of grp "tabNavButtons"
      set  the colorOverlay of button x of grp "tabNavButtons" to empty
   end repeat
end enableQuoteButtons

-- private function utf8encode pString, pIsUnicode
   if pIsUnicode then
      return unidecode(pString, "UTF8")
   else
      return unidecode(uniencode(pString),"UTF8")
   end if
end utf8encode

-- private function utf8decode pString, pToUnicode
   if pToUnicode then
      return uniencode(pString,"UTF8")
   else
      return unidecode(uniencode(pString,"UTF8"))
   end if
end utf8decode

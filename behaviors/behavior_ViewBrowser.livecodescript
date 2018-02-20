script "behavior_ViewBrowser"
-- --> MetaData
-- -
-- license: GPLv3
-- name: behavior_ViewBrowser
-- type: behavior 
        # parent of child browser widget "body" of cd 1 of stack "view_SivaSivaBrowser"
-- version: 0.1

/* BR: USING THIS SCRIPT ATTEMPT TO  DEAL WITH USER CONNECTION NOTIFICATION

GOAL: We need to 
a) check set some kind of time out... 
b) inform the user of delays
c) offer option to continue or abort
d) if abort. return to location in the app 
e) See dictionary/ API / Broswer for msgs sent to the browser.
f) note... you cannot over layout any message dialogs! 

commands available / messages sent to the widget
# sent by developer:
browserDocumentLoadBegin pUrl
browserDocumentLoadComplete pURL
browserDocumentLoadFailed pUrl, pError
browserFrameDocumentLoadBegin pUrl
browserFrameDocumentLoadComplete pUrl
browserFrameDocumentLoadFailed pUrl, pError

# sent from browser by user navigation inside pages
browserNavigateBegin pUrl
browserNavigateComplete pUrl
browserNavigateFailed pUrl, pError
browserUnhandledLoadRequest pUrl
*/

local sStartLoadTime,sTimePassed,sLoadSuccessFlag,

on browserDocumentLoadBegin pURL
   put "false" into sLoadSuccessFlag
   put the seconds into sStartLoadTime
   dialog_CustomMsg "Loading"
   send "TimeOutCheck" to me in 1 second
end browserDocumentLoadBegin


on browserDocumentLoadComplete pURL
   put "true" into sLoadSuccessFlag
end browserDocumentLoadComplete

private command TimeOutCheck
   if sLoadSuccessFlag then 
      exit TimeOutCheck
   else
      put the seconds into sTimePassed
      if ( (sTimePassed-sStartTime)/1000 ) > 5 then   # five seconds passed
         dialog_CustomMsg "Loading is taking time... continue?"
      else 
         send timeOutCheck to me in 500 milliseconds
      end if
   end if
end TimeOutCheck


-- --> ALL FUNCTIONS SET UP BY DAVID IN 2016  BUT NOT ACTUALLY USED
-- --> 
-- --> Object
-- -
-- getprop browser_View
--    breakpoint
--    return the long id of me
-- end browser_View


-- --> Browser | Props
-- -
-- getprop browser_URL
--    put the url of me into someURL
--    return someURL
-- end browser_URL

-- setprop browser_URL someURL
--    set the url of me to someURL
--    return the long id of me
-- end browser_URL

-- getprop browser_HtmlText
--    put the htmltext of me into someHTML
--    return someHTML
-- end browser_HtmlText

-- setprop browser_HtmlText someHTML
--    set the htmltext of me to someHTML
--    return the long id of me
-- end browser_HtmlText


-- --> View
-- -
-- getprop view_Object
--    return the long id of me
-- end view_Object

-- getprop view_Name
--    return "View|Browser"
-- end view_Name


on startup pMode

end startup

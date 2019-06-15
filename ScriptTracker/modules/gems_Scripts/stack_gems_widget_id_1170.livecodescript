Script "stack_gems_widget_id_1170"

/*
# Name: widget "readContext" of group "readContextGrp" of card "images-quotes" of stack "gems"
# ID: widget id 1170 of group id 1177 of card id 1002 of stack "gems"
# Widget Kind: com.livecode.widget.browser
*/


on browserNavigateComplete pURL
   send getTitle to me in 1 second
end browserNavigateComplete

command getTitle
   parseTheHTML (the htmlText of me),"Title"
end getTitle
   

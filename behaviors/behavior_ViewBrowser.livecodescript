script "behavior_ViewBrowser"
-- --> MetaData
-- -
-- license: GPLv3
-- name: behavior_ViewBrowser
-- type: behavior 
# parent of child browser widget "body" of cd 1 of stack "view_SivaSivaBrowser"
-- version: 0.1

local sStartLoadTime,sTimePassed,sLoadSuccessFlag,

on browserDocumentLoadComplete pURL
   put "true" into sLoadSuccessFlag
   browser_SetLastURL pURL
   journal_AddEntry
end browserDocumentLoadComplete




Script "stack_gems_card_id_1184"

/*
# Name: card "meditate-on-this" of stack "gems"
# ID: card id 1184 of stack "gems"
*/


on closecard
   put "meditate-on-this" into pData["card"]
   Journal_RecordEntry "gems", ("Meditations " ), pData,("Reflections") # pTags, pImage
end closecard

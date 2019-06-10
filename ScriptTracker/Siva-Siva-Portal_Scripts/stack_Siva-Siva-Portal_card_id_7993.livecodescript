Script "stack_Siva-Siva-Portal_card_id_7993"

/*
# Name: card "Surprise" of stack "Siva-Siva-Portal"
# ID: card id 7993 of stack "Siva-Siva-Portal"
# Behavior: stack "behavior_PortalInit"
*/


on preopencard
   setCardCoords
   if isMobile() then    
      mobileSetFullScreenRectForOrientations "portrait,portrait upside down",cardRect()
      set the fullscreenmode of this stack to "showAll"
   end if
end preopencard

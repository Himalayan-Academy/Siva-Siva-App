function boot() {

  let list = JSON.parse(localStorage.getItem("saved_words")) || []

  // proxy for web api
  if (typeof liveCode === "undefined") {
    liveCode = {
      debug: (d) => console.log(d),
      getWordDefinition: (d) => fetch("https://dev.himalayanacademy.com/api/index.php/lexicon/word/" + d)
        .then(response => response.json())
        .then(data => {
          data.id = data.lexicon_id
          data.seeAlso = data.see_also
          window.app.ports.wordDefinitionReceived.send(data)
        })
    }
  }

  window.app = Elm.Main.embed(document.getElementById('root'), list)

  // Ports related code below

  window.app.ports.saveWord.subscribe(function (definition) {
    liveCode.debug("saving word", definition)
    list.push({ word: definition.word, id: definition.id })
    localStorage.setItem("saved_words", JSON.stringify(list))
    window.app.ports.savedWordListChanged.send(list)
  });


  window.app.ports.removeSavedWord.subscribe(function (definition) {
    liveCode.debug("removing word", definition.word)
    list = list.filter((item) => item.word !== definition.word)
    localStorage.setItem("saved_words", JSON.stringify(list))
    window.app.ports.savedWordListChanged.send(list)
  });

  window.app.ports.appGoHome.subscribe(function () {
    liveCode.goHome()
  })


  window.app.ports.appGoSettings.subscribe(function () {
    liveCode.goSettings()
  })

  window.app.ports.getWordList.subscribe(function () {
    liveCode.debug("getting word list")
    if (wordlist) {
      liveCode.debug("using saved one")
      window.app.ports.wordListReceived.send(wordlist)
    } else {
      liveCode.getWordList()
    }
  })

  window.app.ports.scrollTop.subscribe(function () {
    window.scrollTo(0, 0)
  })


  window.app.ports.getWordDefinition.subscribe(function (d) {
    liveCode.debug("getting word definition for " + d)

    liveCode.getWordDefinition(d)

  })

  window.app.ports.lcDebug.subscribe(function (data) {
    liveCode.debug("[ELM] " + data)
  })
}

setTimeout(boot, 200)

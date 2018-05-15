try {
  let list = []

  let app = Elm.Main.embed(document.getElementById('root'), list);

  if (typeof liveCode !== "undefined") {
    console.log("livecode present in window")
    console.log(JSON.stringify(Object.keys(window.liveCode)))
  } else {
    console.log("livecode not present in window")
  }


  // Ports related code below

  app.ports.saveWord.subscribe(function (definition) {
    console.log("saving word", definition)
    list.push({ word: definition.word, id: definition.id })
    //localStorage.setItem("saved_words", JSON.stringify(list))
    app.ports.savedWordListChanged.send(list)
  });


  app.ports.removeSavedWord.subscribe(function (definition) {
    console.log("removing word", definition.word)
    list = list.filter((item) => item.word !== definition.word)
    //localStorage.setItem("saved_words", JSON.stringify(list))
    app.ports.savedWordListChanged.send(list)
  });

  app.ports.appGoHome.subscribe(function () {
    liveCode.goHome()
  })


  app.ports.appGoSettings.subscribe(function () {
    liveCode.goSettings()
  })

  app.ports.getWordList.subscribe(function (d) {
    console.log("getting word list")
    if (typeof liveCode !== "undefined" && typeof liveCode.getWordList == "function") {
      liveCode.getWordList()
    } else {
      console.log("liveCode not working, switching to online API")
      fetch('http://dev.himalayanacademy.com/api/index.php/lexicon/words')
        .then(function (response) {
          return response.json();
        })
        .then(function (words) {
          console.log("received words", words)
          let n = words.map(o => { return { id: o.lexicon_id, word: o.word } })
          try {
            app.ports.wordListReceived.send(n)
          } catch (n) {
            console.log("problem sending promise to port")
            console.error(n)
          }
        });
    }
  })


  app.ports.getWordDefinition.subscribe(function (d) {
    console.log("getting word definition for " + d)
    if (false) {
      liveCode.getWordDefinition(d)
    } else {
      console.log("liveCode not working, switching to online API")
      try {
        fetch('http://dev.himalayanacademy.com/api/index.php/lexicon/word/' + d)
          .then(function (response) {
            return response.json();
          })
          .then(function (word) {
            console.log("received word", word);
            word.id = word.lexicon_id
            word.seeAlso = word.see_also

            app.ports.wordDefinitionReceived.send(word)

          });
      } catch (n) {
        console.log("problem sending promise to port")
        console.error(n)
      }
    }
  })
} catch (n) {
  console.error(n);
}

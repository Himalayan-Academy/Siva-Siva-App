import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

let list = JSON.parse(localStorage.getItem("saved_words")) || []

window.app = Main.embed(document.getElementById('root'), list);

registerServiceWorker();


// Ports related code below

window.app.ports.saveWord.subscribe(function (definition) {
  console.log("saving word", definition)
  let list = JSON.parse(localStorage.getItem("saved_words")) || []
  list.push({ word: definition.word, id: definition.id })
  localStorage.setItem("saved_words", JSON.stringify(list))
  window.app.ports.savedWordListChanged.send(list)
});


window.app.ports.removeSavedWord.subscribe(function (definition) {
  console.log("removing word", definition.word)
  let list = JSON.parse(localStorage.getItem("saved_words")) || []
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

window.app.ports.getWordList.subscribe(function (d) {
  liveCode.debug("getting word list")
  liveCode.getWordList()
})


window.app.ports.getWordDefinition.subscribe(function (d) {
  console.log("getting word definition")
  liveCode.getWordDefinition(d)
})

import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

let list = JSON.parse(localStorage.getItem("saved_words")) || []

let app = Main.embed(document.getElementById('root'), list);

registerServiceWorker();


// Ports related code below

app.ports.saveWord.subscribe(function(definition){
  console.log("saving word", definition)
  let list = JSON.parse(localStorage.getItem("saved_words")) || []
  list.push({word: definition.word, id: definition.id})
  localStorage.setItem("saved_words", JSON.stringify(list))
  app.ports.savedWordListChanged.send(list)
});


app.ports.removeSavedWord.subscribe(function(definition){
  console.log("removing word", definition.word)
  let list = JSON.parse(localStorage.getItem("saved_words")) || []
  list = list.filter((item) => item.word !== definition.word)
  localStorage.setItem("saved_words", JSON.stringify(list))
  app.ports.savedWordListChanged.send(list)
});
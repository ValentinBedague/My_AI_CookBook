import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="create-recipe"
export default class extends Controller {
  connect() {
    const plus = document.querySelector("#plus");
    const creation = document.querySelector("#create-recipe");
    const container = document.querySelector(".container");
    console.log("hello")
    plus.addEventListener("click", (event) => {
    // Code JS pour cette page uniquement
    event.preventDefault();

    creation.classList.toggle("d-none");
    if (creation.classList != "d-none") {
      container.setAttribute("style", "filter: blur(4px);");
      plus.setAttribute("style", "transform: rotate(45deg);");
      document.body.classList.add('no-scroll');

    } else {
      container.setAttribute("style", "filter: blur(0px);");
      plus.setAttribute("style", "transform: rotate(0deg);");
      document.body.classList.remove('no-scroll');
    }
  });
  }
}

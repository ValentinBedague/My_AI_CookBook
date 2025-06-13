import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  connect() {

    const dots = document.querySelector(".dots");
    const modal = document.querySelector(".modal-options");
    const container = document.querySelector(".container")
    const close = document.querySelector("#close")

    dots.addEventListener("click", (event) => {
      event.preventDefault();
      modal.classList.remove("d-none");
      modal.setAttribute("style", "position: fixed; bottom:60px;");
      container.setAttribute("style", "filter: blur(4px);");
      document.body.classList.add('no-scroll');
    });

    close.addEventListener("click", (event) => {
      event.preventDefault();
      modal.classList.add("d-none");
      container.setAttribute("style", "filter: blur(0px);");
      document.body.classList.remove('no-scroll');
  });
  }
}

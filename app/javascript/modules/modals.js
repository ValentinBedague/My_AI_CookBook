const dots = document.querySelector(".dots");
const modal = document.querySelector(".modal-options");
const container = document.querySelector(".container")
const close = document.querySelector("#close")

dots.addEventListener("click", (event) => {
  event.preventDefault();
  modal.classList.remove("d-none");
  modal.setAttribute("style", "position: fixed; bottom:60px;");
  container.setAttribute("style", "filter: blur(4px);");
});

close.addEventListener("click", (event) => {
  event.preventDefault();
  modal.classList.add("d-none");
  container.setAttribute("style", "filter: blur(0px);");
});

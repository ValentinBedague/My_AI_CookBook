import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="edit-book"
export default class extends Controller {
  static targets = ["minusIcon"]

  toggleMinusIcons(event) {
    event.preventDefault() // empêche le comportement par défaut du bouton

    this.minusIconTargets.forEach(icon => {
      icon.classList.toggle("d-none")
    })
  }
}

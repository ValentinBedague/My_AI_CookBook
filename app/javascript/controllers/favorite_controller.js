import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { recipeId: Number }

  toggle() {
    fetch(`/recipes/${this.recipeIdValue}/toggle_favorite`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      const icon = this.element.querySelector("i")
      icon.classList.toggle("fas", data.favorited)
      icon.classList.toggle("far", !data.favorited)
    })
    .catch(err => console.error("Erreur:", err))
  }
}

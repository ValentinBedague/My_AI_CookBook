import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    const button = event.currentTarget
    const collectionId = button.dataset.favoriteCollectionIdValue

    fetch(`/collections/${collectionId}/toggle_favorite`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      const icon = button.querySelector("i");
      icon.classList.toggle("fas", data.favorited);
      icon.classList.toggle("far", !data.favorited);
    });
  }
}

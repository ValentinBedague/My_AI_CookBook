import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["urlcontainer", "toggleButton", "submitButton"]

  connect() {
    this.recipeId = this.element.dataset.recipeId
    console.log(this.recipeId)
  }

  toggleContent(event) {
    event.preventDefault()
    this.urlcontainerTarget.classList.remove('d-none')
    this.toggleButtonTarget.classList.remove('d-flex')
   this.toggleButtonTarget.classList.remove('justify-content-center')
    this.toggleButtonTarget.innerHTML = `<div class="mb-2"><strong><i class="fa-solid fa-link btn-icon"></i>Add from an url:</strong></div>`
  }

  generateImage(event) {
    event.preventDefault()

    // Show full-screen modal
    const modal = document.getElementById('loading-modal')
    modal.classList.remove('d-none')
    gsap.to("#egg", { y: -30, repeat: -1, yoyo: true, duration: 0.5, ease: "power1.inOut" })

    // Disable button to prevent multiple clicks
    event.target.disabled = true

    // Send the @recipe.id to server for generating image
    fetch("/recipes/generate_img", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ id: this.recipeId })
    })
    .then(response => {
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)
      return response.json()
    })
    .then(data => {
      console.log("Image generation response:", data)
      const imageUrl = data.url_image
      if (!imageUrl) throw new Error("No image URL returned")
      // Reveal a submit button and an hidden input to send the url_image (string) returned by the fetch method

      const hiddenInput = document.createElement("input")
      hiddenInput.type = "hidden"
      hiddenInput.name = "recipe[url_image]"
      hiddenInput.value = imageUrl

      this.element.querySelector("form").appendChild(hiddenInput)

      event.target.classList.add('d-none')
      modal.classList.add('d-none')
      this.submitButtonTarget.classList.remove('d-none')
    })
    .catch((error) => {
      console.error("Fetch error:", error)
      modal.classList.add('d-none')
      alert("Error generating image")
      event.target.disabled = false
    })
  }
}

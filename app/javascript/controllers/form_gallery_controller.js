import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["urlcontainer", "gallerycontainer", "toggleUrlButton", "toggleGalleryButton", "input", "gallerycard", "urlsubmit", "gallerysubmit"]

  connect() {
    this.toggleUrlButton()
    this.selectedImageId = null
  }

  toggleUrlButton() {
    const hasValue = this.inputTargets.some(input => input.value.trim() !== "")
    console.log(hasValue)
    this.urlsubmitTarget.disabled = !hasValue
  }

  toggleUrlContent(event) {
    event.preventDefault()
    this.urlcontainerTarget.classList.remove('d-none')
    this.toggleUrlButtonTarget.classList.remove('d-flex')
    this.toggleUrlButtonTarget.classList.remove('justify-content-center')
    this.toggleUrlButtonTarget.innerHTML = `<div class="mb-2"><strong><i class="fa-solid fa-link btn-icon"></i> Add from an url:</strong></div>`
  }

  toggleGalleryContent(event) {
    event.preventDefault()
    this.toggleGalleryButtonTarget.classList.remove('d-flex')
    this.toggleGalleryButtonTarget.classList.remove('justify-content-center')
    this.toggleGalleryButtonTarget.innerHTML = `<div class="mb-2"><strong><i class="fa-solid fa-images btn-icon"></i> Choose from our gallery</strong></div>`
    this.gallerycontainerTarget.classList.remove('d-none')
    this.toggleUrlButtonTarget.classList.add('d-none')
    this.urlcontainerTarget.classList.add('d-none')
  }

  toggleGalleryButton(event) {
    const clickedCard = event.target.closest(".collection-card")
    if (!clickedCard) return
    // Remove "selected" class from all gallery images
    this.gallerycardTargets.forEach(card => card.classList.remove("selected"))
    // Add "selected" class to clicked image
    clickedCard.classList.add("selected")
    // Store the selected image id
    const imgElement = clickedCard.querySelector("img")
    if (!imgElement) {
      console.warn("No image found inside the clicked card.")
      return
    }
    const imageUrl = imgElement.src
    this.inputTarget.value = imageUrl
    console.log("Selected image path:", imageUrl)
    this.gallerysubmitTarget.disabled = false
  }
}

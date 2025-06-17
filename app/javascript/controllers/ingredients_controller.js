// app/javascript/controllers/ingredients_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list", "submit", "addButton"]

  connect() {
    // initialization
    this.ingredientCount = this.listTarget.querySelectorAll(".ingredient-item").length || 0
    this.toggleSubmitButton()
  }

  addIngredient(event) {
    event.preventDefault()
    const text = this.inputTarget.value.trim()
    if (!text) return

    // console.log(text)

    // Show spinner on Add button
    const originalButtonHTML = this.addButtonTarget.innerHTML
    this.addButtonTarget.innerHTML = `
      <span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
      <span class="visually-hidden">Loading...</span>
    `
    this.addButtonTarget.disabled = true

    // Send the text to server for parsing
    fetch("/recipes/parse_ingredient", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ text: text })
    })
    .then(response => {
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)
      return response.json()
    })
    .then(data => {
      console.log(data)
      // Create container for hidden input + display + remove button
      const container = document.createElement("div")
      container.classList.add("ingredient-item", "mb-3", "d-flex", "align-items-center", "justify-content-between")

      // Hidden input
      const newId = new Date().getTime()

      const hiddenInputName = document.createElement("input")
      hiddenInputName.type = "hidden"
      hiddenInputName.name = `recipe[ingredients_attributes][${newId}][name]`
      hiddenInputName.value = `${data.name}`

      const hiddenInputQuantity = document.createElement("input")
      hiddenInputQuantity.type = "hidden"
      hiddenInputQuantity.name = `recipe[ingredients_attributes][${newId}][quantity]`
      hiddenInputQuantity.value = `${data.quantity}`

      const hiddenInputUnit = document.createElement("input")
      hiddenInputUnit.type = "hidden"
      hiddenInputUnit.name = `recipe[ingredients_attributes][${newId}][unit]`
      hiddenInputUnit.value = `${data.unit}`

      // Display div
      const displayDiv = document.createElement("div")
      displayDiv.classList.add("card", "recipe-card", "p-2", "rounded-4", "flex-grow-1")
      displayDiv.innerHTML = `
        <div class="d-flex justify-content-between py-1">
        <span>${data.name}</span>
        <span><strong>${data.quantity.toString()} ${data.unit}</strong></span>
        </div>
      `

      // Remove button
      const removeIcon = document.createElement("i")
      removeIcon.className = "fa-solid fa-trash-can"
      removeIcon.style.width = "45px"
      removeIcon.style.display = "inline-block"
      removeIcon.style.textAlign = "center"
      removeIcon.style.cursor = "pointer"
      removeIcon.setAttribute("data-action", "click->ingredients#removeIngredient")
      removeIcon.setAttribute("role", "button")

      container.appendChild(hiddenInputName)
      container.appendChild(hiddenInputQuantity)
      container.appendChild(hiddenInputUnit)
      container.appendChild(displayDiv)
      container.appendChild(removeIcon)

      this.listTarget.appendChild(container)

      this.ingredientCount++
      this.toggleSubmitButton()

      this.inputTarget.value = ""
      this.inputTarget.focus()
    })
    .catch(() => alert("Error parsing ingredient"))
    .finally(() => {
      // Restore Add button text & state
      this.addButtonTarget.innerHTML = originalButtonHTML
      this.addButtonTarget.disabled = false
    })
  }

  removeIngredient(event) {
    event.preventDefault()
    event.target.closest(".ingredient-item").remove()

    // Recalculate count
    this.ingredientCount = this.listTarget.querySelectorAll(".ingredient-item").length || 0
    this.ingredientCount = items.length

    this.toggleSubmitButton()
  }

  toggleSubmitButton() {
    this.submitTarget.disabled = this.ingredientCount < 1
  }
}

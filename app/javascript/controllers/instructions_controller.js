import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list", "count", "submit", "addButton"]

  capitalizeFirstWord(str) {
    if (!str) return ""
    return str.charAt(0).toUpperCase() + str.slice(1)
  }

  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms))
  }

  connect() {
    this.instructionCount = this.listTarget.querySelectorAll(".instruction-item").length || 0
    this.updateCount()
    this.toggleSubmitButton()
  }

  async addInstruction(event) {
    event.preventDefault()
    // console.log(this.inputTarget.value)
    const value = this.inputTarget.value.trim()
    // console.log(value)
    if (value === "") return

    // Show spinner on Add button during 1s
    const originalButtonHTML = this.addButtonTarget.innerHTML
    this.addButtonTarget.innerHTML = `
      <span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
      <span class="visually-hidden">Loading...</span>
    `
    this.addButtonTarget.disabled = true
    await this.sleep(500)
    // Restore Add button text & state
    this.addButtonTarget.innerHTML = originalButtonHTML
    this.addButtonTarget.disabled = false

    this.instructionCount++
    this.updateCount()
    this.toggleSubmitButton()

    // Create container for hidden input + display + remove button
    const container = document.createElement("div")
    container.classList.add("instruction-item", "mb-3", "position-relative")

    // Hidden input
    const hiddenInput = document.createElement("input")
    hiddenInput.type = "hidden"
    hiddenInput.name = "recipe[description][]"
    hiddenInput.value = this.capitalizeFirstWord(value)

    // Display div
    const displayDiv = document.createElement("div")
    displayDiv.classList.add("card", "component-container", "p-3", "rounded-4")
    displayDiv.innerHTML = `
      <span style="color:#438866; font-weight:500;" class="mb-2">Step ${this.instructionCount}</span>
      <p>${this.capitalizeFirstWord(value)}</p>
    `

    // Remove button
    const removeIcon = document.createElement("i")
    removeIcon.className = "fa-solid fa-trash-can"
    removeIcon.style.cursor = "pointer"
    removeIcon.setAttribute("data-action", "click->instructions#removeInstruction")
    removeIcon.setAttribute("role", "button")

    container.appendChild(hiddenInput)
    container.appendChild(displayDiv)
    container.appendChild(removeIcon)

    this.listTarget.appendChild(container)

    this.inputTarget.value = ""
    this.inputTarget.focus()
  }

  removeInstruction(event) {
    event.preventDefault()
    const container = event.target.closest(".instruction-item")
    if (!container) return

    container.remove()

    // Recalculate count
    const items = this.listTarget.querySelectorAll(".instruction-item")
    this.instructionCount = items.length

    // Update displayed step numbers for all items
    items.forEach((item, index) => {
      const stepLabel = item.querySelector("span")  // adjust selector to target your step number span
      if (stepLabel) {
        stepLabel.textContent = `Step ${index + 1}`
      }
    })

    this.updateCount()
    this.toggleSubmitButton()
  }

  updateCount() {
    this.countTarget.textContent = this.instructionCount + 1
  }

  toggleSubmitButton() {
    this.submitTarget.disabled = this.instructionCount < 1
  }
}

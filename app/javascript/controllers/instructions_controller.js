import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list", "count"]

  connect() {
    this.instructionCount = this.listTarget.children.length || 0
    this.updateCount()
  }

  addInstruction(event) {
    event.preventDefault()
    const value = this.inputTarget.value.trim()
    if (value === "") return

    this.instructionCount++
    this.updateCount()

    // Add hidden input to submit value
    const hiddenInput = document.createElement("input")
    hiddenInput.type = "hidden"
    hiddenInput.name = "recipe[description][]"
    hiddenInput.value = value
    this.listTarget.appendChild(hiddenInput)

    // Optionally display instruction text for user feedback
    const displayDiv = document.createElement("div")
    displayDiv.innerHTML = `<strong>Instruction ${this.instructionCount}:</strong> ${value}`
    this.listTarget.appendChild(displayDiv)

    this.inputTarget.value = ""
    this.inputTarget.focus()
  }

  updateCount() {
    this.countTarget.textContent = this.instructionCount + 1
  }
}

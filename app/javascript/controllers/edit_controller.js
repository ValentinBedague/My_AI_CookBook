import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "inputIngredient", "inputInstruction", "instructionCount", "listIngredient", "listInstruction", "submit", "addIngredientButton", "addInstructionButton"]

  capitalizeFirstWord(str) {
    if (!str) return ""
    return str.charAt(0).toUpperCase() + str.slice(1)
  }

  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms))
  }

  connect() {
    // initialization
    this.ingredientCount = this.listIngredientTarget.querySelectorAll(".ingredient-item").length || 0
    this.instructionCount = this.listInstructionTarget.querySelectorAll(".instruction-item").length || 0
    this.updateCount()
  }

  updatename(event) {
    // Get the new value from the input field
    const newName = event.target.value.trim()
    // Update the content of the target <h1>
    this.nameTarget.textContent = newName !== "" ? newName : "Choose a recipe name"
  }

  addIngredient(event) {
    event.preventDefault()
    const text = this.inputIngredientTarget.value.trim()
    if (!text) return

    // console.log(text)

    // Show spinner on Add button
    const originalButtonHTML = this.addIngredientButtonTarget.innerHTML
    this.addIngredientButtonTarget.innerHTML = `
      <span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
      <span class="visually-hidden">Loading...</span>
    `
    this.addIngredientButtonTarget.disabled = true

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
      displayDiv.classList.add("card", "component-container", "p-2", "rounded-4", "flex-grow-1")
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
      removeIcon.setAttribute("data-action", "click->edit#removeIngredient")
      removeIcon.setAttribute("role", "button")

      container.appendChild(hiddenInputName)
      container.appendChild(hiddenInputQuantity)
      container.appendChild(hiddenInputUnit)
      container.appendChild(displayDiv)
      container.appendChild(removeIcon)

      this.listIngredientTarget.appendChild(container)

      this.ingredientCount++
      // this.toggleSubmitButton()

      this.inputIngredientTarget.value = ""
      this.inputIngredientTarget.focus()
    })
    .catch(() => alert("Error parsing ingredient"))
    .finally(() => {
      // Restore Add button text & state
      this.addIngredientButtonTarget.innerHTML = originalButtonHTML
      this.addIngredientButtonTarget.disabled = false
    })
  }

  removeIngredient(event) {
    event.preventDefault()
    event.target.closest(".ingredient-item").remove()
    // Recalculate count
    this.ingredientCount = this.listIngredientTarget.querySelectorAll(".ingredient-item").length || 0
    this.ingredientCount = items.length
    // this.toggleSubmitButton()
  }

  removeOldIngredient(event) {
    event.preventDefault()
    // The trash icon clicked
    const trashIcon = event.currentTarget
    // Find the closest .ingredient-item div
    const ingredientItem = trashIcon.closest('.ingredient-item')
    // Extract current inputs for id (required), name, quantity, unit (optional)
    const idInput = ingredientItem.querySelector('input[name$="[id]"]')
    // Clear the entire ingredientItem content
    ingredientItem.innerHTML = ''
    ingredientItem.classList.remove('mb-3')
    // Append hidden fields for id and _destroy=1
    const idHidden = document.createElement('input')
    idHidden.type = 'hidden'
    idHidden.name = idInput.name  // same name as original id input
    idHidden.value = idInput.value
    const destroyHidden = document.createElement('input')
    destroyHidden.type = 'hidden'
    // Rails expects "_destroy" field inside nested attributes
    destroyHidden.name = idInput.name.replace('[id]', '[_destroy]')
    destroyHidden.value = '1'
    ingredientItem.appendChild(idHidden)
    ingredientItem.appendChild(destroyHidden)
  }

  async addInstruction(event) {
    event.preventDefault()
    // console.log(this.inputTarget.value)
    const value = this.inputInstructionTarget.value.trim()
    // console.log(value)
    if (value === "") return

    // Show spinner on Add button during 1s
    const originalButtonHTML = this.addInstructionButtonTarget.innerHTML
    this.addInstructionButtonTarget.innerHTML = `
      <span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
      <span class="visually-hidden">Loading...</span>
    `
    this.addInstructionButtonTarget.disabled = true
    await this.sleep(500)
    // Restore Add button text & state
    this.addInstructionButtonTarget.innerHTML = originalButtonHTML
    this.addInstructionButtonTarget.disabled = false

    this.instructionCount++
    this.updateCount()

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
    removeIcon.setAttribute("data-action", "click->edit#removeInstruction")
    removeIcon.setAttribute("role", "button")

    container.appendChild(hiddenInput)
    container.appendChild(displayDiv)
    container.appendChild(removeIcon)

    this.listInstructionTarget.appendChild(container)

    this.inputInstructionTarget.value = ""
    this.inputInstructionTarget.focus()
  }

  removeInstruction(event) {
    event.preventDefault()
    const container = event.target.closest(".instruction-item")
    if (!container) return

    container.remove()

    // Recalculate count
    const items = this.listInstructionTarget.querySelectorAll(".instruction-item")
    this.instructionCount = items.length

    // Update displayed step numbers for all items
    items.forEach((item, index) => {
      const stepLabel = item.querySelector("span")  // adjust selector to target your step number span
      if (stepLabel) {
        stepLabel.textContent = `Step ${index + 1}`
      }
    })

    this.updateCount()
  }

  updateCount() {
    this.instructionCountTarget.textContent = this.instructionCount + 1
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list"]

  connect() {
    this.index = this.listTarget.querySelectorAll(".ingredient-field").length
  }

  addIngredient(event) {
    event.preventDefault()

    const newId = new Date().getTime()

    const newField = document.createElement("div")
    newField.classList.add("ingredient-field")
    newField.innerHTML = `
      <input type="text" name="recipe[ingredients_attributes][${newId}][name]" placeholder="Ingredient" />
      <input type="text" name="recipe[ingredients_attributes][${newId}][quantity]" placeholder="Quantity" />
      <input type="text" name="recipe[ingredients_attributes][${newId}][unit]" placeholder="Unit" />
      <button type="button" data-action="click->ingredients#removeIngredient">Remove</button>
    `
    this.listTarget.appendChild(newField)
  }

  removeIngredient(event) {
    event.preventDefault()
    event.target.closest(".ingredient-field").remove()
  }
}

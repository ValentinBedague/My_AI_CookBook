import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submit"]

  connect() {
    this.toggleButton()
  }

  toggleButton() {
    const hasValue = this.inputTargets.some(input => input.value.trim() !== "")
    console.log(hasValue)
    this.submitTarget.disabled = !hasValue
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["unit", "result"]

  connect() {
    this.update()
  }

  update() {
    const numberInput = this.element.querySelector('input[name="preptime_number"]')
    const number = parseFloat(numberInput.value) || 0
    const unit = this.unitTarget.value

    let minutes = 0
    if (unit === "hours") {
      minutes = number * 60
    } else {
      minutes = number
    }

    this.resultTarget.value = minutes
  }
}

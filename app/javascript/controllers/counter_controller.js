import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  increment() {
    let val = parseInt(this.inputTarget.value) || 0
    this.inputTarget.value = val + 1
  }

  decrement() {
    let val = parseInt(this.inputTarget.value) || 0
    if (val > 1) { // prevent going below 1 if you want
      this.inputTarget.value = val - 1
    }
  }
}

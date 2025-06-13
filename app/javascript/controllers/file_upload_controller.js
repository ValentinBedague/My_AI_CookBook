import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="file-upload"
export default class extends Controller {
  static targets = ["input", "text"]
  connect() {
    this.inputTarget.addEventListener("change", () => {
      if (this.inputTarget.files.length > 0) {
        this.textTarget.textContent = this.inputTarget.files[0].name;
      } else {
        this.textTarget.textContent = "Upload a picture";
      }
    });
  }
}

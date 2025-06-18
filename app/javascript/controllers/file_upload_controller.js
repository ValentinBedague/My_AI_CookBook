import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "text", "submit"]

  connect() {
    this.inputTarget.addEventListener("change", () => {
      if (this.inputTarget.files.length > 0) {
        this.textTarget.textContent = this.inputTarget.files[0].name;
        this.submitTarget.disabled = false
      } else {
        this.textTarget.textContent = "Upload a picture";
        this.submitTarget.disabled = true
      }
    });
  }

  onFormSubmit(event) {
    const modal = document.getElementById('loading-modal')
    modal.classList.remove('d-none')
    gsap.to("#Herb1", { x:2, y: -10, repeat: -1, yoyo: true, duration: 0.6, ease: "power1.inOut" })
    gsap.to("#Herb2", { x:-2, y: -2, repeat: -1, yoyo: true, duration: 0.7, ease: "power1.inOut" })
    gsap.to("#Herb3", { rotation:-2, y: -4, repeat: -1, yoyo: true, duration: 0.7, ease: "power1.inOut" })
    gsap.to("#Herb4", { rotation:-10, y: -5, x: -2, repeat: -1, yoyo: true, duration: 0.6, ease: "power1.inOut" })
    gsap.to("#Green2", { rotation:25, y: 10, x: 2, repeat: -1, yoyo: true, duration: 0.6, ease: "power1.inOut" })
    gsap.to("#Green1", { rotation:-15, y: -5, x: 2, repeat: -1, yoyo: true, duration: 0.4, ease: "power1.inOut" })
    gsap.to("#Orange1", { y: -15, repeat: -1, yoyo: true, duration: 0.4, ease: "power1.inOut" })
    gsap.to("#Orange2", { y: -12, repeat: -1, yoyo: true, duration: 0.4, ease: "power1.inOut" })
    gsap.to("#Orange3", { y: -8, repeat: -1, yoyo: true, duration: 0.4, ease: "power1.inOut" })
    gsap.to("#Tomato1", { y: -2, x: -2, repeat: -1, yoyo: true, duration: 0.4, ease: "power1.inOut" })
    gsap.to("#LEFT_HAND", { rotation: 8, duration: 1, yoyo: true, repeat: -1, ease: "power1.inOut" })
    gsap.to("#RIGHT_HAND", { rotation: -2, x: -6, duration: 1, yoyo: true, repeat: -1, ease: "power1.inOut" })
  }
}

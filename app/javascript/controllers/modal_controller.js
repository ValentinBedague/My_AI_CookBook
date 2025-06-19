import { Controller } from '@hotwired/stimulus';
// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ['minusIcon', 'modalHide', 'blurred','okButton'];
  connect() {
    // this.modalHideTarget.classList.add('d-none');
    const dots = document.querySelector('.dots');
    const modal = document.querySelector('.modal-options');
    const container = document.querySelector('.container');
    const close = document.querySelector('#close');
    dots.addEventListener('click', (event) => {
      event.preventDefault();
      modal.classList.remove('d-none');
      // modal.setAttribute('style', 'position: fixed; bottom:60px;');
      modal.setAttribute('style', 'position: fixed; bottom:0px;');
      container.setAttribute('style', 'filter: blur(4px);');
      document.body.classList.add('no-scroll');
    });
    close.addEventListener('click', (event) => {
      event.preventDefault();
      modal.classList.add('d-none');
      container.setAttribute('style', 'filter: blur(0px);');
      document.body.classList.remove('no-scroll');
    });
    this.applyWiggleToAll()
  }

  applyWiggleToAll() {
    const wiggleElements = this.element.querySelectorAll(".wiggle")
    wiggleElements.forEach(el => {
      gsap.to(el, {
        rotation: 0.5,
        yoyo: true,
        repeat: -1,
        duration: 0.15,
        ease: "sine.inOut",
        transformOrigin: "50% 50%"
      })
    })
  }

  remove() {
    this.minusIconTargets.forEach((icon) => {
      icon.classList.remove('d-none');
      icon.classList.add('wiggle');
    });
    const cards = document.querySelectorAll('.recipes-in-books')
    cards.forEach((card) => {
      card.classList.add('wiggle');
    });
    this.applyWiggleToAll()
    if (this.hasOkButtonTarget) {
      this.okButtonTarget.classList.remove("d-none")
    }
    this.modalHideTarget.classList.add('d-none');
    this.blurredTarget.setAttribute('style', 'filter: blur(0px);');
    document.body.classList.remove('no-scroll');
  }

  ok() {
    this.minusIconTargets.forEach((icon) => {
      icon.classList.add('d-none');
    });
    const cards = document.querySelectorAll('.recipes-in-books')
    cards.forEach((card) => {
      card.classList.remove('wiggle');
      gsap.killTweensOf(card);
    });
    const counter = document.getElementById("counter");
    if (counter) {
      let currentValue = parseInt(counter.textContent, 10);
      if (!isNaN(currentValue) && currentValue > 0) {
        counter.textContent = currentValue - 1;
      }
    }
    if (this.hasOkButtonTarget) {
      this.okButtonTarget.classList.add("d-none")
    }
  }
}

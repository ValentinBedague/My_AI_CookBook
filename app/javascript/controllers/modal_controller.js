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
  }

  remove() {
    this.minusIconTargets.forEach((icon) => {
      icon.classList.remove('d-none');
    });
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
    if (this.hasOkButtonTarget) {
      this.okButtonTarget.classList.add("d-none")
    }
  }
}

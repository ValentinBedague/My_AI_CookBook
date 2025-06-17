import { Controller } from '@hotwired/stimulus';
// Connects to data-controller="removetag"
export default class extends Controller {
  static targets = ['tagItem'];
  connect() {}
  fetchDelete(event) {
    event.preventDefault(event);
    fetch(`${this.tagItemTarget.href}`, {
      method: 'DELETE',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')
          .content,
      },
    })
      .then((response) => response.json)
      .then((data) => {
        this.element.remove();
      });
  }
}

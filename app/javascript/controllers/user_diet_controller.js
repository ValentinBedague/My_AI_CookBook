import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    this.initializeDietTypes();
  }

  toggle(event) {
    // Find the closest .diet-type div (which is the wrapper)
    const wrapper = event.target.closest('.diet-type');
    console.log(wrapper)
    console.log("Clicked element:", event.target)
    if (!wrapper) return;

    // Find the checkbox inside this wrapper div
    const checkbox = wrapper.querySelector('input[type="checkbox"]');
    console.log(checkbox)
    if (!checkbox) return;

    checkbox.checked = !checkbox.checked
    if (checkbox.checked) {
      wrapper.classList.add('selected');
    } else {
      wrapper.classList.remove('selected');
    }
  }

  initializeDietTypes() {
    const wrappers = document.querySelectorAll('.diet-type');

    wrappers.forEach(wrapper => {
      const checkbox = wrapper.querySelector('input[type="checkbox"]');
      if (!checkbox) return;

      // Synchroniser la classe avec l'état de la checkbox au chargement
      if (checkbox.checked) {
        wrapper.classList.add('selected');
      } else {
        wrapper.classList.remove('selected');
      }
    });
  }
}

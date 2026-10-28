import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["view", "edit", "form"]

  edit() {
    this.toggle(true)
  }

  cancel() {
    this.formTarget.reset()
    this.toggle(false)
  }

  toggle(editing) {
    this.viewTargets.forEach((el) => (el.hidden = editing))
    this.editTargets.forEach((el) => (el.hidden = !editing))
  }
}

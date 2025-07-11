import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="recaptcha"
export default class extends Controller {
  connect() {
    // reCAPTCHA v3 doesn't need manual initialization like v2
    // The token is generated when the form is submitted
    console.log("reCAPTCHA v3 controller connected")
  }

  // This method can be called when form is submitted to get a fresh token
  async getToken(action = 'submit') {
    if (window.grecaptcha && window.grecaptcha.ready) {
      return new Promise((resolve) => {
        window.grecaptcha.ready(() => {
          window.grecaptcha.execute(this.getSiteKey(), { action: action }).then((token) => {
            resolve(token)
          })
        })
      })
    }
    return null
  }

  getSiteKey() {
    // Get site key from the script tag or use test key
    const scripts = document.querySelectorAll('script[src*="recaptcha"]')
    for (let script of scripts) {
      const match = script.src.match(/render=([^&]+)/)
      if (match) {
        return match[1]
      }
    }
    return '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI' // fallback test key
  }
}

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="recaptcha"
export default class extends Controller {
  connect() {
    // Initialize reCAPTCHA when the controller connects
    this.initializeRecaptcha()
    
    // Listen for Turbo events to reinitialize reCAPTCHA
    document.addEventListener("turbo:render", this.initializeRecaptcha.bind(this))
  }

  disconnect() {
    // Clean up event listener when controller disconnects
    document.removeEventListener("turbo:render", this.initializeRecaptcha.bind(this))
  }

  initializeRecaptcha() {
    // Wait a bit for the reCAPTCHA script to load
    setTimeout(() => {
      if (window.grecaptcha && window.grecaptcha.render) {
        // Find all reCAPTCHA containers that haven't been rendered yet
        const recaptchaContainers = document.querySelectorAll('.g-recaptcha:not([data-rendered])')
        
        recaptchaContainers.forEach(container => {
          const siteKey = container.getAttribute('data-sitekey')
          if (siteKey) {
            try {
              window.grecaptcha.render(container, {
                'sitekey': siteKey
              })
              container.setAttribute('data-rendered', 'true')
            } catch (error) {
              console.warn('Failed to render reCAPTCHA:', error)
            }
          }
        })
      }
    }, 100)
  }
}

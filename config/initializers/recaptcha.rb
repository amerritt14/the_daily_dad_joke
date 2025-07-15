require "recaptcha"

Recaptcha.configure do |config|
  # For development, we'll use test keys that always pass
  # In production, use Rails credentials
  if Rails.env.development?
    config.site_key   = "6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI"  # Test key
    config.secret_key = "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe"  # Test key
  elsif Rails.env.test?
    # Use test keys for test environment
    config.site_key   = "6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI"  # Test key
    config.secret_key = "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe"  # Test key
  else
    # Production - use Rails credentials if available
    if Rails.application.credentials.recaptcha
      config.site_key   = Rails.application.credentials.recaptcha[:site_key]
      config.secret_key = Rails.application.credentials.recaptcha[:secret_key]
      Rails.logger.info "reCAPTCHA configured from credentials" if Rails.env.production?
    else
      # Fallback to test keys if credentials not configured
      config.site_key   = "6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI"
      config.secret_key = "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe"
      Rails.logger.warn "reCAPTCHA using fallback test keys - credentials not found!" if Rails.env.production?
    end
  end

  # Skip verification in test environment
  config.skip_verify_env = ["test"]
  
  # Debug info (only in development)
  if Rails.env.development?
    Rails.logger.info "reCAPTCHA v3 configured with site_key: #{config.site_key[0..10]}..."
  end
end

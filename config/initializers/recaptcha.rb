require "recaptcha"

Recaptcha.configure do |config|
  # For development, we'll use test keys that always pass
  # In production, use Rails credentials
  if Rails.env.development? || Rails.env.test?
    config.site_key   = "6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI"  # Test key
    config.secret_key = "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe"  # Test key
  else
    # Production - use Rails credentials if available
    recaptcha_config = Rails.application.credentials.recaptcha rescue nil

    if recaptcha_config&.dig(:site_key).present? && recaptcha_config&.dig(:secret_key).present?
      config.site_key   = recaptcha_config[:site_key].presence || ENV["RECAPTCHA_SITE_KEY"]
      config.secret_key = recaptcha_config[:secret_key].presence || ENV["RECAPTCHA_SECRET_KEY"]
      Rails.logger.info "reCAPTCHA configured from credentials" if Rails.env.production?
    end
  end

  # Skip verification in test environment
  config.skip_verify_env = [ "test" ]

  # Debug info (only in development)
  if Rails.env.development?
    Rails.logger.info "reCAPTCHA v3 configured with site_key: #{config.site_key[0..10]}..."
  end
end

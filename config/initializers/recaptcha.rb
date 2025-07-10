require "recaptcha"

Recaptcha.configure do |config|
  # For development, we'll use test keys that always pass
  # In production, use Rails credentials
  if Rails.env.development?
    config.site_key   = "6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI"  # Test key
    config.secret_key = "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe"  # Test key
  else
    config.site_key   = Rails.application.credentials.recaptcha[:site_key]
    config.secret_key = Rails.application.credentials.recaptcha[:secret_key]
  end

  # Skip verification in test environment
  config.skip_verify_env = ["test"]
end

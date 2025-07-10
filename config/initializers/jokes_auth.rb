# Configuration for jokes authentication
Rails.application.configure do
  # Set default credentials for development
  # In production, use environment variables or Rails credentials
  if Rails.env.development?
    ENV["JOKES_USERNAME"] ||= "admin"
    ENV["JOKES_PASSWORD"] ||= "password123"
  end
end

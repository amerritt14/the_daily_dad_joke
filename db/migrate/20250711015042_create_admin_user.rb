class CreateAdminUser < ActiveRecord::Migration[8.0]
  def change
    # Create the admin user with email and password
    User.create!(
      email: Rails.application.credentials.dig(:admin_user, :email),
      password: Rails.application.credentials.dig(:admin_user, :password),
      password_confirmation: Rails.application.credentials.dig(:admin_user, :password),
    )
  end
end

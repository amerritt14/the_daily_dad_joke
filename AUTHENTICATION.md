# Jokes Authentication Setup (Devise)

This application uses Devise gem for user authentication to protect the jokes index page.

## Default Credentials (Development)
- **Email:** admin@dailydadjoke.com
- **Password:** password123

## How it Works

When users try to access the jokes index page (root path), they will be redirected to a login page if they're not already signed in.

The authentication is handled by Devise using the `authenticate_user!` method in `JokesController`.

## User Management

### Creating New Users
You can create new users through the Rails console:

```ruby
User.create!(
  email: "user@example.com",
  password: "secure_password",
  password_confirmation: "secure_password"
)
```

### In Production
For production environments, you should:
1. Change the default admin credentials
2. Disable user registration (if you only want specific users)
3. Use environment variables for any seed data

### Devise Features Available
- User sign in/sign out
- Password reset (if configured)
- User registration (can be disabled)
- Remember me functionality
- Account confirmation (if configured)

## Security Notes

- Change the default admin credentials before deploying to production
- Use strong passwords
- Consider disabling user registration for admin-only access
- The current setup protects all actions in the JokesController

## Customization

### Disable User Registration
Add to `config/routes.rb`:
```ruby
devise_for :users, skip: [:registrations]
```

### Customize Views
Devise views are located in `app/views/devise/` and can be customized as needed.

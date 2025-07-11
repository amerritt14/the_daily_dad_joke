# The Daily Dad Joke 🎭

A Rails application for collecting and moderating dad jokes with robust spam protection and admin authentication.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Quick Start](#quick-start)
- [Authentication System](#authentication-system)
- [Bot Protection](#bot-protection)
- [Database Schema](#database-schema)
- [Development Setup](#development-setup)
- [Production Deployment](#production-deployment)
- [API Documentation](#api-documentation)
- [Contributing](#contributing)

## Overview

The Daily Dad Joke is a Rails 8 application that allows:
- **Public users** to submit dad jokes through a clean, protected form
- **Administrators** to review and moderate submitted jokes
- **Robust spam protection** with multiple layers of bot detection

## Features

### 🎯 Core Functionality
- Public joke submission form (no authentication required)
- Admin dashboard for joke moderation
- Status-based joke management (pending, approved, rejected)
- Clean, responsive UI with Tailwind CSS

### 🛡️ Security & Protection
- Multi-layer bot protection (reCAPTCHA, rate limiting, honeypot)
- Devise authentication for admin access
- Strong parameter filtering
- IP-based rate limiting

### 🎨 User Experience
- Separate layouts for public and admin interfaces
- Mobile-responsive design
- Flash messages and error handling
- Intuitive status indicators

## Quick Start

```bash
# Clone and setup
git clone <repository-url>
cd the-daily-dad-joke
bundle install

# Database setup
bin/rails db:migrate
bin/rails db:seed

# Start the server
bin/rails server
```

**Admin Access:** `admin@dailydadjoke.com` / `password123`
**Public Form:** `/jokes/new`

## Authentication System

### How It Works

The application uses **Devise** for authentication with a dual-interface approach:
- **Admin Interface** (`/`): Protected by authentication, shows all jokes with moderation tools
- **Public Interface** (`/jokes/new`): No authentication required, clean submission form

### Default Credentials (Development)
- **Email:** admin@dailydadjoke.com
- **Password:** password123

### User Management

Create new admin users via Rails console:
```ruby
User.create!(
  email: "admin@example.com",
  password: "secure_password",
  password_confirmation: "secure_password"
)
```

### Production Security

1. **Change default credentials** before deploying
2. **Disable user registration** for admin-only access:
   ```ruby
   # In config/routes.rb
   devise_for :users, skip: [:registrations]
   ```
3. **Use strong passwords** and consider 2FA

### Available Features
- User sign in/sign out
- Password reset (configurable)
- Remember me functionality
- Session management

## Bot Protection

### Multi-Layer Protection System

#### 1. Google reCAPTCHA v3
- **Development:** Uses test keys (always pass)
- **Production:** Requires real keys via Rails credentials
- **Score-based:** Invisible verification with minimum score threshold (0.5)
- **Action-specific:** Uses 'submit_joke' action for better analytics

##### Setup for Production:
```bash
bin/rails credentials:edit --environment production
```
Add:
```yaml
recaptcha:
  site_key: your_site_key_here
  secret_key: your_secret_key_here
```

#### 2. Rate Limiting
- **Limit:** 3 submissions per IP per hour
- **Storage:** Rails cache (memory in development, Redis recommended for production)
- **Behavior:** Clear error message when limit exceeded

#### 3. Honeypot Field
- Hidden field that bots might fill
- Invisible to human users
- Automatic rejection if filled

#### 4. Strong Parameters
- Only permits `:question` and `:answer` fields
- Filters out malicious data automatically

### Testing Protection
All protections are active in development:
- reCAPTCHA v3 runs invisibly with test keys
- Rate limiting enforced
- Honeypot protection active
- Rate limiting enforced
- Honeypot protection active

### Monitoring Recommendations
Consider logging:
- Rate limit violations
- Honeypot field violations
- reCAPTCHA failures

## Database Schema

### Jokes Table
```ruby
create_table "jokes" do |t|
  t.string "question", null: false    # Setup/question (required)
  t.string "answer"                   # Punchline (optional)
  t.string "source"                   # Source of joke
  t.string "source_id"                # External ID
  t.string "status", default: "pending", null: false  # pending/approved/rejected
  t.timestamps
end
```

### Users Table
Standard Devise schema with email/password authentication.

### Status Workflow
1. **Pending** (default) - Newly submitted jokes
2. **Approved** - Ready for publication
3. **Rejected** - Not suitable for publication

## Development Setup

### Prerequisites
- Ruby 3.2+
- Rails 8.0+
- SQLite3 (development)
- Node.js (for asset pipeline)

### Installation
```bash
# Dependencies
bundle install

# Database
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed

# Assets (Tailwind CSS)
bin/rails tailwindcss:build

# Start development server
bin/dev  # Runs Rails + Tailwind watcher
# OR
bin/rails server  # Rails only
```

### Development Tools
- **Tailwind CSS:** Utility-first CSS framework
- **Devise:** Authentication
- **reCAPTCHA:** Spam protection
- **Foreman:** Process management (via bin/dev)

### Key Files
- `app/controllers/jokes_controller.rb` - Main logic
- `app/views/jokes/` - Public interface
- `app/views/layouts/public.html.erb` - Public layout
- `config/initializers/recaptcha.rb` - Bot protection config

## Production Deployment

### Environment Setup
1. **Rails Credentials:** Add reCAPTCHA keys
2. **Database:** Configure production database
3. **Cache:** Consider Redis for rate limiting
4. **Assets:** Precompile Tailwind CSS

### Security Checklist
- [ ] Change default admin credentials
- [ ] Set up real reCAPTCHA keys
- [ ] Configure production database
- [ ] Set up proper cache store
- [ ] Enable HTTPS
- [ ] Configure CORS if needed

### Deployment Commands
```bash
# Precompile assets
bin/rails assets:precompile

# Database setup
bin/rails db:migrate RAILS_ENV=production
bin/rails db:seed RAILS_ENV=production

# Start production server
bin/rails server -e production
```

## API Documentation

### Public Endpoints
- `GET /jokes/new` - Joke submission form
- `POST /jokes` - Submit new joke (with protection)

### Admin Endpoints (Authentication Required)
- `GET /` - Admin dashboard with all jokes
- `GET /users/sign_in` - Admin login

### Status Codes
- `200` - Success
- `302` - Redirect (auth required)
- `422` - Validation error
- `429` - Rate limited

## Deployment

### Asset Compilation

The application uses Tailwind CSS with proper compilation for production:

```bash
# Precompile assets (required before deployment)
bin/rails assets:precompile
```

The layouts automatically switch between:
- **Development:** Tailwind CSS CDN (for faster development)
- **Production:** Compiled CSS assets (for performance and offline capability)

### Kamal Deployment

This app is configured for deployment using Kamal. The deployment configuration is in `config/deploy.yml`.

#### Prerequisites
1. **Server Setup:** Configure your server IP in `deploy.yml`
2. **reCAPTCHA Keys:** Add production credentials:
   ```bash
   bin/rails credentials:edit --environment production
   ```
   Add:
   ```yaml
   recaptcha:
     site_key: your_production_site_key
     secret_key: your_production_secret_key
   ```
3. **Master Key:** Ensure `RAILS_MASTER_KEY` is available in production

#### Deployment Commands
```bash
# Setup (first time)
bin/kamal setup

# Deploy updates
bin/kamal deploy

# Check logs
bin/kamal app logs

# Console access
bin/kamal app exec --interactive --reuse "bin/rails console"
```

### Environment Variables

Required for production:
- `RAILS_MASTER_KEY` - For decrypting credentials
- reCAPTCHA credentials (via Rails credentials)

### Database Migration

For production deployments with schema changes:
```bash
# During deployment
bin/kamal app exec "bin/rails db:migrate"
```

## Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Submit a pull request

### Code Style
- Use double quotes for strings
- Follow Rails conventions
- Add comments for complex logic
- Update documentation for new features

### Testing
```bash
# Run tests (when available)
bin/rails test

# Check for security issues
bin/brakeman

# Style check
bin/rubocop
```

---

**Built with Rails 8, Tailwind CSS, and ❤️ for dad jokes everywhere!**

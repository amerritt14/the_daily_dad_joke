# The Daily Dad Joke 🎭

A Rails application for collecting and moderating dad jokes with robust spam protection and admin authentication.

## Table of Contents

- [Quick Start](#quick-start)
- [Contributing](#contributing)

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

# The Daily Dad Joke 🎭

A Rails application for collecting and moderating dad jokes with robust spam protection and admin authentication.

## Table of Contents

- [Quick Start](#quick-start)
- [Deployment](#deployment)
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

# Start development server
bin/dev  # Runs Rails
# OR
bin/rails server  # Rails only
```

## Deployment

This app is deployed using [Kamal](https://kamal-deploy.org/) to `app.thedailydadjoke.com`.

### Prerequisites
- Docker installed locally
- SSH access to the production server
- `RAILS_MASTER_KEY` available in `.kamal/secrets`

### Deploy

```bash
# First-time setup (provisions server, configures proxy, etc.)
bin/kamal setup

# Deploy a new version
bin/kamal deploy
```

### Useful Aliases

```bash
bin/kamal console   # Open a Rails console on the server
bin/kamal shell     # Open a bash shell on the server
bin/kamal logs      # Tail application logs
bin/kamal dbc       # Open a database console on the server
```

### Configuration

Deployment is configured in [config/deploy.yml](config/deploy.yml). Key settings:
- **Host:** `app.thedailydadjoke.com` (SSL enabled)
- **Registry:** `localhost:5555`
- **Storage:** Persistent volume at `/data` for SQLite and Active Storage files

---

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

**Built with Rails 8 and ❤️ for dad jokes everywhere!**

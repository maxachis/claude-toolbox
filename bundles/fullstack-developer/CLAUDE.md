# Project Rules

## Overview

Fullstack web application project.

## Architecture

- Frontend: [React/Vue/Svelte]
- Backend: [Node.js/Python/Go]
- Database: [PostgreSQL/MySQL/MongoDB]

## Code Style

### Frontend
- Use functional components
- Colocate styles with components
- Use TypeScript strict mode

### Backend
- RESTful API conventions
- Consistent error responses
- Input validation on all endpoints

### Database
- Use migrations for schema changes
- Index frequently queried columns
- Use transactions for multi-step operations

## Testing

- Unit tests for business logic
- Integration tests for API endpoints
- E2E tests for critical flows

## Git Workflow

- Feature branches from main
- Conventional commits
- PR reviews required
- CI must pass before merge

## Security

- Validate all user inputs
- Use parameterized queries
- Hash passwords with bcrypt
- HTTPS in production

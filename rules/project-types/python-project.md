# Project Rules

## Overview

This is a Python project. Follow these conventions when making changes.

## Code Style

- Follow PEP 8 for code formatting
- Use type hints for all function signatures
- Maximum line length: 88 characters (Black formatter)
- Use f-strings for string formatting
- Prefer `pathlib.Path` over `os.path`

## Project Structure

```
src/
├── package_name/     # Main package
│   ├── __init__.py
│   ├── models/       # Data models
│   ├── services/     # Business logic
│   └── api/          # API endpoints
tests/
├── conftest.py       # Shared fixtures
├── test_*.py         # Test files
```

## Testing

- Use pytest for all tests
- Name test files `test_<module>.py`
- Name test functions `test_<what_is_being_tested>`
- Use fixtures for common setup (define in `conftest.py`)
- Mock external services, don't mock internal code

## Dependencies

- Add dependencies to `pyproject.toml`
- Pin major versions: `requests>=2.28,<3`
- Use `pip-tools` or `poetry` for lock files

## Error Handling

- Use specific exception types
- Create custom exceptions in `exceptions.py`
- Log errors with context using `logging`
- Return meaningful error messages to users

## Documentation

- Docstrings for all public functions (Google style)
- Keep README.md up to date
- Document environment variables in `.env.example`

## Git

- Use conventional commits: `feat:`, `fix:`, `docs:`, etc.
- Keep commits focused on single changes
- Write descriptive commit messages

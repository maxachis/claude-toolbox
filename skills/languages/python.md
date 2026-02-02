# Python Best Practices

## Code Style

- Follow PEP 8 for code formatting
- Use type hints for function signatures and complex variables
- Prefer f-strings over `.format()` or `%` formatting
- Use meaningful variable names (avoid single letters except for iterators)
- Keep functions focused and under 20-30 lines when possible

## Project Structure

```
project/
├── src/
│   └── package_name/
│       ├── __init__.py
│       └── module.py
├── tests/
│   └── test_module.py
├── pyproject.toml
└── README.md
```

## Testing

- Use pytest as the primary test framework
- Name test files `test_*.py`
- Name test functions `test_<what_is_being_tested>`
- Use fixtures for common setup
- Aim for high coverage on business logic

## Imports

- Group imports: standard library, third-party, local
- Use absolute imports for clarity
- Avoid `from module import *`

## Error Handling

- Use specific exception types
- Don't catch bare `except:`
- Use context managers for resources
- Log exceptions with context

## Documentation

- Use docstrings for public functions and classes
- Follow Google or NumPy docstring style
- Include examples in docstrings for complex functions

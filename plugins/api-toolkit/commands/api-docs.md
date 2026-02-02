# API Documentation Generator

Generate or update API documentation.

## Arguments

- `$ARGUMENTS` - Endpoint(s) to document, or "all" for full API

## Instructions

1. **Detect documentation approach**:
   - OpenAPI/Swagger (look for openapi.yaml, swagger.json)
   - Framework auto-generation (FastAPI, Spring, etc.)
   - Markdown docs in /docs folder
   - README-based documentation
   - Ask if unclear

2. **Examine the endpoints** to understand:
   - URL and HTTP method
   - Request parameters (path, query, header, body)
   - Response structures for all status codes
   - Authentication requirements
   - Rate limits if any

3. **Generate documentation including**:

   **For each endpoint:**
   - Clear description of purpose
   - Authentication requirements
   - All parameters with types and descriptions
   - Required vs optional fields
   - Request body schema with examples
   - Response schemas for success and error cases
   - Example requests (curl or language-specific)
   - Example responses

   **For OpenAPI specifically:**
   - Proper schema definitions in components
   - Reusable response definitions
   - Security scheme definitions
   - Tags for grouping endpoints

4. **Match existing style**:
   - Same level of detail as existing docs
   - Consistent example formats
   - Same terminology

## Output

- Documentation in the appropriate format
- For OpenAPI: valid YAML/JSON that passes validation
- For markdown: well-formatted, linkable sections
- Note any undocumented behaviors discovered

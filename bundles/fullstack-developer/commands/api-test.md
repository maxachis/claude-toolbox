# API Test Generator

Generate integration tests for API endpoints.

## Arguments

- `$ARGUMENTS` - Endpoint to test (e.g., "POST /users" or "the users endpoints")

## Instructions

1. **Detect the testing setup**:
   - Supertest + Jest/Vitest (Node.js)
   - pytest + httpx/TestClient (Python FastAPI)
   - pytest + test client (Python Flask/Django)
   - net/http/httptest (Go)
   - Check existing test files for patterns

2. **Examine the endpoint** to understand:
   - Request format and required fields
   - Response structure
   - Authentication requirements
   - Business logic and validations

3. **Generate tests for**:

   **Happy paths:**
   - Valid request returns expected response
   - All response fields are correct

   **Authentication/Authorization:**
   - Unauthenticated request is rejected (401)
   - Unauthorized user is rejected (403)
   - Different user roles if applicable

   **Validation:**
   - Missing required fields (400)
   - Invalid field formats (400)
   - Invalid field values (400)

   **Edge cases:**
   - Empty strings vs null vs missing
   - Boundary values (max length, min/max numbers)
   - Special characters in strings

   **Error cases:**
   - Resource not found (404)
   - Conflict states (409)
   - Database/service failures if mockable

4. **Follow project conventions** for:
   - Test file naming and location
   - Setup/teardown patterns
   - Mocking strategies
   - Test data factories/fixtures

## Output

- Complete test file or test cases
- Any test utilities or fixtures needed
- Setup instructions if test database is required

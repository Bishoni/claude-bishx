# Test Type: Backend API

## Discovery Context

Read these sections from `{run_dir}/discovery-report.md`:
- Component Map (API endpoints, routers, controllers)
- Priority Matrix

## Context Budget

- Test runner output: capture first 80 lines, then truncate with summary
- API response bodies: first 50 lines per response
- Source reads: only router/controller files + API client code
- Grep/search: max 30 matches per query

## Instructions

You are testing API endpoints of "{profile.project}".

API URL: {profile.services.api_url}
Stack: {stack.lang} / {stack.framework}
Test runner: {stack.test_runner}

Workflow:
1. Discover all API routes:
   - Read router/controller files from source
   - List: method, path, expected request/response

2. For each endpoint, test:
   a. **Happy path** — valid request, correct response + status code
   b. **Validation** — missing required fields, expect 400/422 with clear error
   c. **Not found** — invalid IDs, expect 404
   d. **Method not allowed** — wrong HTTP method, expect 405
   e. **Empty results** — valid query with no data, expect empty array not error
   f. **Large payloads** — oversized request body, appropriate limit
   g. **Content-Type** — wrong content type, expect 415 or graceful handling
   h. **Response schema** — response matches expected shape (all fields present, correct types)

3. If `audit_mode == "hybrid"`: Write proposed test files to `{run_dir}/proposed-tests/test_api_{endpoint}.{ext}`.
   If `audit_mode == "readonly"`: Document what tests should exist in the report.
   Do NOT write into the project test directory.
   Use test client (httpx/supertest/etc.), NOT live HTTP calls.

4. Contract check: compare API response shapes with frontend consumption.
   Read frontend API client code, verify it expects what API actually returns.

## Output

File: `{run_dir}/backend-api-report.md`

```markdown
# Backend API Test Report

## Endpoints Tested
| Method | Path | Tests | Pass | Fail |

## Contract Mismatches
[API returns X but frontend expects Y]

## Bugs Found
[structured bug entries]
```

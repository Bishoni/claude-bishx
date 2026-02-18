# Test Type: Error Handling

## Discovery Context

Read these sections from `{run_dir}/discovery-report.md`:
- Component Map
- Risk Areas

## Context Budget

- Test runner output: first 80 lines, then summary
- Source reads: focus on error handlers, try/catch blocks, validation code
- Grep/search: max 30 matches per query (search for: bare except, empty catch, TODO near error handling)

## Instructions

You are testing error handling and resilience of "{profile.project}".

Stack: {stack.lang} / {stack.framework}
Source: {stack.source_dir}
Test runner: {stack.test_runner}

Goal: What happens when things go wrong? Find silent failures, crashes, data loss, and unhelpful error messages.

Workflow:
1. **Invalid input resilience:**
   For each endpoint/service that accepts input:
   - Send completely wrong types (string where number expected, object where array expected)
   - Send malformed data (broken JSON, truncated XML, corrupt binary)
   - Send extremely large input (10MB string, 100k array elements)
   - Send empty/null/undefined for every field
   - Expected: graceful error response with clear message, not crash or silent failure

2. **Dependency failures:**
   Write tests that simulate:
   - Database unavailable (mock connection to raise error)
   - External API timeout or 500 (if external calls exist)
   - File system errors (read-only, disk full, missing directory)
   - Expected: app returns meaningful error, not traceback or hang

3. **Configuration errors:**
   - Read all env vars / config values used by the app
   - Test: what happens if each required env var is missing?
   - Test: what happens if DB connection string is wrong?
   - Test: what happens if a port is already in use?
   - Expected: clear startup error with guidance, not cryptic traceback

4. **Partial failure scenarios:**
   - Import file with some valid and some invalid rows — does it import valid ones and report errors?
   - Batch operation where one item fails — does it roll back all or continue?
   - Concurrent modifications to same resource — graceful conflict or data corruption?

5. **Error response quality:**
   For each error the app can produce:
   - Is the HTTP status code correct? (400 for client error, 500 for server, not 200 with error body)
   - Is the error message helpful to the user? (not "Internal Server Error" or raw exception)
   - Does the response leak internals? (stack traces, file paths, SQL queries, versions)
   - Is the error machine-readable? (consistent format: {error: ..., detail: ...})

6. **Recovery:**
   - After an error, does the app continue working normally?
   - Does a failed request leave corrupted state in DB?
   - Does a failed import leave partial data?
   - After a crash and restart, does the app recover cleanly?

7. **Silent failure detection:**
   - Search source code for:
     - Bare except/catch blocks with no logging or re-raise
     - Functions that return null/None on error instead of throwing
     - Empty error handlers (catch(e) {})
     - TODO/FIXME/HACK comments near error handling
   - For each found: write a test that triggers that code path and verify behavior

If `audit_mode == "hybrid"`: Write proposed resilience tests to `{run_dir}/proposed-tests/test_error_{service}.{ext}`.
If `audit_mode == "readonly"`: Document error handling gaps in the report only.
Do NOT write into the project test directory. Use mocking/patching for dependency failures.

## Output

File: `{run_dir}/error-handling-report.md`

```markdown
# Error Handling Report

## Input Resilience
| Endpoint/Service | Input Type | Expected | Actual | Status |

## Dependency Failures
| Dependency | Failure Mode | Expected | Actual | Status |

## Configuration Errors
| Config Key | Missing/Invalid | Expected | Actual | Status |

## Silent Failures Found
| Location | Pattern | Risk | Description |

## Error Response Quality
| Endpoint | Status Code OK | Message Helpful | No Leaks | Format Consistent |

## Bugs Found
[structured bug entries]
```

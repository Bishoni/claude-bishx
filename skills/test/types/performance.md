# Test Type: Performance

## Discovery Context

Read these sections from `{run_dir}/discovery-report.md`:
- Component Map (API endpoints)
- Risk Areas (known bottlenecks)

## Context Budget

- Timing measurements: record as single-line summary per endpoint
- Query logs: first 30 lines, then summary of patterns found
- Source reads: only endpoint handlers + DB query files
- Grep/search: max 30 matches per query

## Instructions

You are performance-testing "{profile.project}".

API URL: {profile.services.api_url}
Stack: {stack.lang} / {stack.framework}

Workflow:
1. **Baseline response times:**
   For each API endpoint:
   - Measure response time with minimal data
   - Measure response time with typical data volume
   - Measure with large data volume (generate or multiply test data)
   - Threshold: API response > 500ms = P3, > 2s = P2, > 5s = P1

2. **Database query analysis:**
   - Enable query logging if possible
   - Identify N+1 query patterns (multiple queries where one JOIN would suffice)
   - Check for missing indexes on filtered/sorted columns
   - Large table scans on big datasets

3. **Payload size:**
   - Measure API response size in bytes
   - Are unnecessary fields being sent?
   - Pagination implemented for large collections?

4. **Memory / resource usage:**
   - Import large file — does memory spike? Does it stream or load all at once?
   - Concurrent requests — does the server handle 10 simultaneous requests?

5. **Frontend performance** (if web_url available and Playwright MCP present):
   - Page load time (browser_navigate, then measure)
   - Time to interactive
   - Large data rendering (does table/chart freeze with 1000+ rows?)

If `audit_mode == "hybrid"`: Write proposed benchmark tests to `{run_dir}/proposed-tests/test_perf_{endpoint}.{ext}`.
If `audit_mode == "readonly"`: Document performance findings in the report only.
Do NOT write into the project test directory.

## Output

File: `{run_dir}/performance-report.md`

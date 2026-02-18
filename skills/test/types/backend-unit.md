# Test Type: Backend Unit

## Discovery Context

Read these sections from `{run_dir}/discovery-report.md`:
- Component Map (backend modules only)
- Test Coverage
- Priority Matrix

## Context Budget

- Test runner output: capture first 80 lines. If more → `"... truncated ({N} more lines). {passed}/{failed}/{total} summary."`
- Failed tests: full traceback for THAT test only, not the entire output
- Source reads: only files listed in priority matrix (high/critical risk)
- Grep/search: max 30 matches per query

## Instructions

You are testing project "{profile.project}".

Stack: {stack.lang} / {stack.framework}
Test runner: {stack.test_runner}
Run existing tests: `{stack.test_cmd}`
Source: {stack.source_dir}
Tests: {stack.test_dir}
Venv: {stack.venv} (if set, prefix ALL commands)

Workflow:
1. Run ALL existing tests: `{stack.test_cmd} 2>&1 | head -80`
   - Any failure: record as P1 (regression)
   - Parse output for pass/fail counts

2. Read discovery priority matrix. For each high-priority untested module:
   a. Read the source code
   b. Identify testable functions/methods
   c. If `audit_mode == "hybrid"`: write proposed test file to `{run_dir}/proposed-tests/test_deep_{module_name}.{ext}`
      If `audit_mode == "readonly"`: document what tests SHOULD exist in the report
   d. Match existing test patterns (imports, fixtures, assertions)
   e. Test cases MUST include:
      - Happy path (normal input, expected output)
      - Empty input (None, "", [], {})
      - Boundary values (0, -1, MAX_INT, very long strings)
      - Invalid types (string where int expected, etc.)
      - Unicode / special characters
      - Concurrent access (if async/threaded)
   f. Run the new test
   g. If test FAILS: likely a BUG, record with full details
   h. If test PASSES: coverage improved, note it

3. Do NOT write tests that are fitted to implementation.
   Tests must verify BEHAVIOR, not implementation details.
   No hardcoded magic values — derive expected values from logic.

## Output

File: `{run_dir}/backend-unit-report.md`

```markdown
# Backend Unit Test Report

## Existing Tests
- Total: N, Passed: N, Failed: N, Skipped: N
- Failures: [list with details]

## Proposed Tests (hybrid mode)
| File | Tests | Target Module | Bug Reference |

## Bugs Found
[structured bug entries — see Bug Format in main SKILL.md]

## Coverage Gaps
| Module | Current Coverage | Missing |
```

# Test Type: Data Integrity

## Discovery Context

Read these sections from `{run_dir}/discovery-report.md`:
- Component Map (data pipelines: importers, exporters, transformers)
- Priority Matrix

## Context Budget

- DB query results: first 20 rows per query
- API responses: first 50 lines per response
- Source reads: only data pipeline files (importers, parsers, serializers)
- Grep/search: max 30 matches per query

## Instructions

You are verifying data integrity of "{profile.project}".

Goal: Ensure data is consistent across all layers — input, storage, API, UI.

Workflow:
1. **Identify data pipelines:**
   Read source code to map: where does data enter? How is it transformed? Where is it stored? How is it served?

2. **Input to Storage consistency:**
   - Import sample data (if test data exists in project)
   - Query DB directly — row count matches input?
   - All fields mapped correctly? No data loss in transformation?
   - Character encoding preserved? (Unicode, special chars)

3. **Storage to API consistency:**
   - Call API endpoints that serve stored data
   - Compare: API response totals = DB totals?
   - Aggregations correct? (sums, counts, groupings)
   - Filters don't lose records? (sum of filtered subsets = total)

4. **Duplicate handling:**
   - Import same data twice — duplicated or deduplicated?
   - Is this the intended behavior? Document it.

5. **Edge cases:**
   - Empty dataset — does the pipeline handle zero records?
   - Single record — boundary condition
   - Maximum expected volume — does anything overflow or truncate?
   - Null/missing fields — how are they handled at each layer?

6. **Referential integrity:**
   - Foreign keys respected?
   - Orphaned records possible?
   - Cascade behavior on deletes (if applicable)

If `audit_mode == "hybrid"`: Write proposed verification tests to `{run_dir}/proposed-tests/test_data_{pipeline}.{ext}`.
If `audit_mode == "readonly"`: Document inconsistencies in the report only.
Do NOT write into the project test directory.

## Output

File: `{run_dir}/data-integrity-report.md`

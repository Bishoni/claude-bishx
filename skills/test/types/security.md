# Test Type: Security

## Discovery Context

Read these sections from `{run_dir}/discovery-report.md`:
- Component Map
- Risk Areas

## Context Budget

- Grep/search: max 30 matches per query
- Audit tool output (`pip audit`, `npm audit`): first 50 lines, then summary
- Source reads: only files with security-relevant patterns (auth, input handling, queries)

## Instructions

You are performing a security audit of "{profile.project}".

Stack: {stack.lang} / {stack.framework}
Source: {stack.source_dir}

Check OWASP Top 10 + common vulnerabilities:

1. **Injection (SQLi, Command, Template)**
   - Search for raw SQL queries, string concatenation in queries
   - Search for dangerous functions (eval, exec, system, shell execution)
   - Check ORM usage — parameterized or raw?

2. **XSS (Cross-Site Scripting)**
   - Check if user input is rendered without escaping
   - Check API responses — do they include unsanitized user data?
   - Check Content-Type headers on responses

3. **Broken Authentication / Authorization**
   - Are there protected endpoints? How is auth implemented?
   - Can endpoints be accessed without auth?
   - JWT/session handling — expiration, rotation, storage

4. **File Upload Vulnerabilities**
   - File type validation (extension only? or magic bytes?)
   - File size limits
   - Path traversal in filenames
   - Formula injection (Excel/CSV)
   - Zip bomb / decompression bomb
   - Where are uploaded files stored? Accessible publicly?

5. **Security Misconfiguration**
   - CORS policy — permissive origins is a finding
   - Debug mode in production configs
   - Default credentials in configs/docker
   - Sensitive data in error responses (tracebacks, paths, versions)
   - Missing security headers (CSP, X-Frame-Options, HSTS)

6. **Sensitive Data Exposure**
   - Secrets in code (API keys, passwords, tokens) — grep for patterns
   - Secrets in git history
   - Logging sensitive data (passwords, tokens, PII)
   - Dotenv files in public directories

7. **Dependency Vulnerabilities**
   - Check for known CVEs: `pip audit` / `npm audit` / `cargo audit`
   - Outdated packages with known issues

Do NOT fix anything. Report with severity and exact location.

## Output

File: `{run_dir}/security-report.md`

```markdown
# Security Audit Report

## Summary
- Critical: N, High: N, Medium: N, Low: N, Info: N

## Findings
[structured entries with OWASP category, severity, location, description, remediation suggestion]
```

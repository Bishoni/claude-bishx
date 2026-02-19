---
name: init-sync
description: "Scan codebase and fill/update CLAUDE.md and AGENTS.md with real project data. Produces deep architectural documentation matching production quality."
---

# Bishx Init-Sync: Codebase Scanner & Doc Filler

You scan the current project and fill `CLAUDE.md` and `AGENTS.md` with real data from the codebase. This works both on fresh templates (with `<!-- bishx:init:xxx -->` markers) and on previously filled files (updates existing content).

The output quality must match production-grade project documentation — deep, specific, with exact file paths, counts, and lists.

**Core principle:** Document what ACTUALLY exists. Don't force the project into a predefined template. If the project has Controllers — write Controllers, not Routes. If it has Repositories — write Repositories, not DAOs. Adapt section names, structure, and depth to the real architecture. The examples below are for quality reference, not for copying verbatim.

## Prerequisites

1. `CLAUDE.md` must exist in project root. If not — tell user to run `/bishx:init` first.
2. `AGENTS.md` must exist in project root. If not — tell user to run `/bishx:init` first.

## Step 1: Detect Manifests

Search for project manifests to identify the stack:

```
package.json, pyproject.toml, requirements.txt, go.mod, Cargo.toml,
composer.json, Gemfile, pom.xml, build.gradle, mix.exs, pubspec.yaml,
tsconfig.json, vite.config.*, next.config.*, nuxt.config.*,
docker-compose.yml, Dockerfile, Makefile
```

Read each found manifest. Extract: language, framework, ALL dependencies with versions.

## Step 2: Deep Codebase Scan

This is NOT a surface scan. You must understand the codebase deeply.

### 2.1 Project Structure
Run `ls` (depth 2-3) on the project root. Map every significant directory.

### 2.2 Models / Schema
Find all model definitions:
- Python: search for `class.*Base`, SQLAlchemy models, Pydantic models, dataclasses
- TypeScript: search for interfaces, types, Prisma schema, TypeORM entities
- Go: search for structs with db/json tags

For each: note file path, count, list key model names.

### 2.3 API / Routes
Find all route/endpoint definitions:
- FastAPI: `@router.get/post/put/delete`, `APIRouter`
- Express: `router.get/post`, `app.get/post`
- Go: `mux.HandleFunc`, `gin.GET/POST`
- Next.js: `app/` or `pages/` directory structure

For each: note file paths, count, list key endpoints, identify namespaces (admin, public, internal).

### 2.4 Services / Business Logic
Find service layer files. Note: location, count, key services.

### 2.5 DAO / Repository Layer
Find data access layer. Note: base class (if any), file paths, count, examples.

### 2.6 Auth & Permissions
Find auth mechanisms: middleware, decorators, guards, permission checkers.
Note: auth method (JWT/JWE/sessions/OAuth), permission model, key files.

### 2.7 Frontend Architecture (if exists)
- **Features/Pages:** find page components, count them, list names
- **UI Components:** find shared/reusable components, count, list
- **Layout:** find layout components (header, sidebar, footer)
- **State Management:** find stores (Redux, Zustand, Pinia, Vuex)
- **Custom Hooks:** find custom hooks/composables, list with one-line descriptions
- **Routes:** extract route table (path → component → feature)

### 2.8 Response Format
Find standardized response wrappers (envelope, DTO, serializers).

### 2.9 Middleware
Find all middleware. List each with one-line description.

### 2.10 Workers / Jobs / Schedulers
Find background tasks, cron jobs, queue consumers. Note mechanism and examples.

### 2.11 Config
Find config management approach (env, runtime config, feature flags).

### 2.12 Documentation
Find existing docs (docs/, README.md, API specs, architecture docs).

### 2.13 Domain Terms
Identify domain-specific terms from model names, comments, README.

## Step 3: Fill CLAUDE.md

Read `CLAUDE.md`. Replace placeholder sections AND add new sections if they don't exist.

### Section: Project
Replace `<!-- bishx:init:project_description -->` with 1-2 sentence description.
Source: README.md, package.json description, pyproject.toml metadata.

### Section: Stack
Replace `<!-- bishx:init:stack -->` with compact bullet list:
```markdown
- Backend: Python 3.13, FastAPI, SQLAlchemy async, Alembic, Pydantic v2
- Frontend: React 19, TypeScript, Vite, Tabler (HTML→React conversion)
- DB: PostgreSQL, Redis
- Auth: LDAP/AD → JWE tokens
```
Only include categories that actually exist. Be specific with versions.

### Section: Environment (ADD if missing)
Insert AFTER Stack, BEFORE Security. Content:
- Virtual environment path and activation command
- Key directory paths with descriptions
- Links to important documentation files found in the project
- Entry points (main.py, manage.py, etc.)

Example:
```markdown
## Environment

- venv: `.venv` in project root, activate via `python3.13`
- Full codebase context: `docs/CODEBASE_CONTEXT.md`
- Architecture details: `docs/plans/v1/implementation-plan.md`
```

### Section: Architecture (ADD if missing)
Insert AFTER Environment, BEFORE Security. Brief (2-3 sentences):
- Where the source code lives
- Core architectural pattern
- What NOT to break (the foundational conventions)

Example:
```markdown
## Backend Architecture (`backend/`)

Base backend architecture in `backend/app/`. New modules follow these patterns. Architecture can evolve if justified — but don't break the foundation (DAO, DTO, ResponseEnvelope, async everywhere, session injection)
```

### Section: Security
If current content is only generic OWASP rules, enhance with project-specific security concerns detected from the codebase (encryption, compliance requirements, network restrictions, etc.).

### Section: Frontend (ADD if frontend exists)
Insert AFTER Security. Brief notes:
- UI framework and styling approach
- Key constraints

Example:
```markdown
## Frontend

- Tabler HTML → HTML→React conversion, no Tailwind
- Avoid generic AI aesthetics. Follow the framework's style.
```

## Step 4: Fill AGENTS.md

This is the DEEP documentation file. It must be thorough enough that a new agent can understand the entire codebase without reading source files.

### Header
Replace `{PROJECT_NAME}` with actual project name.
Replace `<!-- bishx:init:project_description -->` with 2-3 sentence description.

### Section: Stack
Replace `<!-- bishx:init:stack_detailed -->`.
Create subsections per layer with `**bold labels**` and exact versions:

```markdown
### Backend
- **Runtime:** Python 3.13
- **Framework:** FastAPI
- **ORM:** SQLAlchemy 2.x async
- **Migrations:** Alembic
- **Validation:** Pydantic v2
- **Cache/Messaging:** Redis 7+
- **DB:** PostgreSQL 16+

### Frontend
- **Runtime:** React 19
- **Language:** TypeScript 5
- **Bundler:** Vite 6
- **UI Framework:** Tabler (HTML→React conversion, no Tailwind)
- **Router:** React Router v7
- **State:** Zustand
- **Data Fetching:** TanStack React Query v5
- **HTTP Client:** Axios

### Auth
- **Source:** LDAP/AD bind
- **Tokens:** JWE (access 15min / refresh 30d HttpOnly)
```

Include ALL layers: Backend, Frontend, ML/AI, Auth, Monitoring, Infrastructure — whatever exists.

### Section: Architecture
Replace `<!-- bishx:init:project_structure -->` with FULL architectural breakdown.
This is NOT just a directory tree. Create subsections for EACH architectural layer found:

#### Backend Architecture (if backend exists)
Discover the actual layers the project uses. Common ones: Models, DAO/Repository, Schemas/DTOs, Routes/Controllers, Services, Auth, Response Format, Config, Middleware, Workers, Scheduler — but only document what's actually there. Skip what doesn't exist. Add layers not listed here if the project has them.

For each layer found, include: **Location**, **Count** (if countable), key names/examples.

Example for one subsection:
```markdown
### Models
- **Location:** `backend/app/main_dao/models.py`
- **Count:** ~20 models in one file
- **Key models:** User, Role, UserRole, Conference, Transcript, AudioFile, Tag, Notification, AuditLog

### DAO Layer
- **BaseDAO[T]:** `backend/app/main_dao/base.py` — Generic CRUD with cursor pagination
- **DAO files:** `backend/app/dao/` — 24 files, inherit BaseDAO
- **Examples:** UserDAO, ConferenceDAO, TranscriptDAO, TagDAO, NotificationDAO
```

#### Frontend Architecture (if frontend exists)
Discover the actual frontend structure. Common layers: Features/Pages, UI Components, Layout, State Management, Hooks/Composables, Routes — but adapt to what's actually there (Vue has composables, not hooks; Angular has modules; etc.).

For each layer found, include: **Location**, **Count**, lists.

Routes — prefer table format:
```markdown
| Path | Component | Feature |
|------|-----------|---------|
| `/` | HomePage | home |
| `/login` | LoginPage | auth |
```

### Section: Documentation
Replace with table of ALL found documentation files:
```markdown
| Document | Description |
|----------|-------------|
| [README.md](README.md) | Navigation hub |
| [docs/architecture.md](docs/architecture.md) | Services architecture |
```

### Section: Domain Terms (ADD if identifiable)
Extract domain-specific terms from models, README, comments:
```markdown
| Term | Meaning |
|------|---------|
| Conference | TrueConf video call (2-60 min) |
```
If no clear domain terms found — omit this section entirely.

### Section: Patterns
Replace `<!-- bishx:init:patterns -->`.
Per-layer list of ACTUAL patterns found in code (not recommendations):

```markdown
### Backend
- DAO pattern (not Repository, not Active Record)
- Async everywhere (asyncpg, aiohttp, aioredis)
- Pydantic v2 schemas for validation
- Cursor-based pagination (not offset)
- Soft delete (deleted_at, deleted_by)
- ResponseEnvelope for all API responses

### Frontend
- Feature-based structure (not by file type)
- Zustand for state management
- React Query for server state
```

Be specific — mention what pattern IS used and what it's NOT (like the voicer example).

## Step 5: Report

```
[bishx:init-sync] Done
- CLAUDE.md: N sections filled, M sections added
- AGENTS.md: N sections filled, M sections added
- Stack: {one-line stack summary}
- Architecture: {count} layers documented
- Patterns: {count} patterns identified
```

## Rules

1. **Facts only.** Write what IS in the codebase, not recommendations.
2. **No guessing.** Can't determine something → leave marker, tell user.
3. **Preserve user edits.** Section has custom content (no marker) → don't overwrite, only append clearly missing info.
4. **Be exhaustive in AGENTS.md.** Every architectural layer, every route, every component. A new agent should understand the project from this file alone.
5. **Be concise in CLAUDE.md.** Bullets, short paragraphs. No deep dives — that's what AGENTS.md is for.
6. **English text.** Both files use English. Technical terms (FastAPI, Zustand, JWT) stay as-is.
7. **Exact counts and paths.** Don't write "several models" — write "~20 models in `app/models.py`". Don't write "some routes" — write "20+ files in `api/v1/routes/`".
8. **List real names.** Don't write "key models" — list them: User, Role, Conference, etc.

---
description: Create CLAUDE.md and AGENTS.md templates in the project root
---

Create project instruction files `CLAUDE.md` and `AGENTS.md` in the current working directory.

## Rules

1. If `CLAUDE.md` already exists — ask the user before overwriting
2. If `AGENTS.md` already exists — ask the user before overwriting
3. Write both files with the **exact** content specified below (no modifications)
4. After writing, confirm what was created

## CLAUDE.md

```markdown
# CLAUDE.md

Инструкции для AI-агента (Claude Code) при работе с этим репозиторием.

При изменении стека, паттернов или архитектуры — актуализируй `AGENTS.md`. Только факты: стек, версии, паттерны. Без рассуждений и рекомендаций.

---

## Проект

<!-- bishx:init:project_description -->

## Стек

<!-- bishx:init:stack -->

## Безопасность

- OWASP Top 10 — обязательная проверка при каждом изменении
- Секреты только через `.env` / переменные окружения, никогда не коммитить
- Не выводить чувствительные данные в логи и ответы API
- Валидация входных данных на границах системы (API endpoints, внешние источники)

---

## Трекинг задач через bd (beads)

Проект использует `bd` для локального трекинга задач/изменений. Перед началом работы — получи задачи. После завершения — закрой задачу и синхронизируй.

### Команды

​```bash
bd onboard              # первичная инициализация
bd ready                # показать доступные задачи
bd show <id>            # детали задачи
bd update <id> --status in_progress  # взять в работу
bd close <id>           # закрыть задачу
bd sync                 # синхронизировать состояние
​```

### Workflow с bd (solo-режим)

1. `bd ready` — посмотреть доступные задачи
2. `bd update <id> --status in_progress` — взять задачу
3. Выполнить работу
4. Закоммитить и запушить (см. ниже)
5. `bd close <id>` — закрыть задачу
6. `bd sync` — синхронизировать

**В team-режиме (Agent Teams):** `bd close` и `bd sync` выполняет **Lead**, НЕ dev-агент. Dev только коммитит, пушит и уведомляет Lead.

---

## Git

### Правила

- Вся работа ведётся в `main`
- Conventional commits на русском: `<type>: <subject>`
- Types: `feat|fix|refactor|perf|docs|test|build|ci|chore|style|revert|deps|security`
- Subject: прошедшее время, без точки, до 200 символов
- Co-Authored-By в каждом коммите
- Маленькие атомарные коммиты вместо больших diff

### Коммит

​```bash
git pull --rebase origin main
git add -A
git commit -m "$(cat <<'EOF'
feat: добавлена валидация форм

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
git push origin main
# Если push rejected → git pull --rebase origin main && git push origin main
​```

### Завершение задачи (HARD GATE)

Задача НЕ считается выполненной, пока:
1. `git push origin main` — прошёл успешно
2. `git status --porcelain` — пусто (нет untracked файлов)
3. `bd close <id>` и `bd sync` — выполнены (в team-режиме — Lead делает)

Запрещено писать «готов запушить» / «можно запушить позже». Агент обязан выполнить push сам.
```

## AGENTS.md

```markdown
# {PROJECT_NAME}

<!-- bishx:init:project_description -->

## Стек

<!-- bishx:init:stack_detailed -->

## Структура проекта

<!-- bishx:init:project_structure -->

## Паттерны

<!-- bishx:init:patterns — заполняется по мере развития проекта -->
```

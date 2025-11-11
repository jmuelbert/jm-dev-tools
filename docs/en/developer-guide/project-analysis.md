# jm-dev-tools

## Overview

**jm-dev-tools** (JM Business Data Extraction) is a Python-based IT inventory
management application for tracking employees, departments, devices (computers,
printers, phones, mobiles, faxes), and accounts.

## Technology Stack

- **Language:** Python 3.11-3.13
- **UI Framework:** PySide6 (Qt for Python) with QML
- **CLI Framework:** Typer with Rich for terminal output
- **Database:** SQLite via QSqlDatabase (Qt's SQL module)
- **Data Validation:** Pydantic
- **ORM/Database:** Qt SQL
- **Logging:** structlog
- **Translation:** Babel, QTranslate
- **Configuration:** QSettings
- **Build System:** Hatchling

## Project Structure

```sql
jm-dev-tools-python/
├── src/jm_bde/
│   ├── __about__.py          # Version & app metadata
│   ├── main.py               # Main entry point
│   ├── exceptions.py         # Custom exceptions hierarchy
│   ├── cli/                  # Command-line interface
│   │   └── main_cli.py       # Typer-based CLI
│   ├── config/               # Configuration management
│   │   ├── appcontext.py     # Application context & dependency injection
│   │   ├── settings_manager.py
│   │   ├── logging_manager.py
│   │   ├── logging_bootstrap.py
│   │   ├── translation_manager.py
│   │   └── base_manager_singleton.py
│   ├── database/             # Database layer
│   │   ├── database_manager.py  # DB connection & model initialization
│   │   ├── models/           # SQLModel definitions
│   │   │   ├── department_model.py
│   │   │   ├── employee_model.py
│   │   │   └── device_model.py
│   │   └── services/         # Business logic services
│   │       ├── department_employee_manager.py
│   │       └── device_employee_manager.py
│   ├── gui/                  # Qt/QML GUI
│   │   ├── startup.py
│   │   ├── employee_widget.py
│   │   ├── resources_rc.py   # Qt resource file
│   │   ├── qml/              # QML views
│   │   └── qml_views/        # Python backends for QML
│   │       ├── dashboard_widget.py
│   │       └── department_backend.py
│   ├── models/               # Pydantic validation models
│   │   ├── device.py
│   │   ├── employee.py
│   │   └── validate-models/
│   │       └── employees_view.py
│   ├── locales/              # Translation files
│   └── resources/            # Static resources
├── tests/
│   ├── unit/                 # Unit tests (pytest)
│   ├── integration/          # Integration tests
│   └── conftest.py
├── docs/                     # MkDocs documentation
├── scripts/                  # Helper scripts
└── pyproject.toml            # Project configuration
```

## Key Components

1. **Application Context** (`bash appcontext.py`)

- Centralized dependency injection container
- Manages singleton instances:
  `python SettingsManager, TranslationManager, DatabaseManager`
- Provides logger retrieval and translation helpers

1. **Database Manager** (`bash database_manager.py`)

- Uses Qt's `QSqlDatabase` for SQLite connections
- Lazy-initializes models: `DepartmentModel, EmployeeModel, DeviceModel`
- Handles database setup, PRAGMA configuration, and table creation
- Properties: `departments, employees, devices`

1. **CLI** (`main_cli.py`)

- Typer-based command-line interface
- Initializes QCoreApplication for Qt-based settings
- Launches GUI via `start_gui()` function
- Options: `--language, --verbose, --version`

1. **Exception Hierarchy** (`exceptions.py`) Structured exceptions:

- **Base:** `BaseReportError, ApplicationError`
- **Specialized:**
  - `ExitExceptionError` (CLI)
  - `LoggerConfigurationError, InvalidLogLevelError, LogDirectoryError`
    (Logging)
  - `SettingsConfigurationError, SettingsPersistenceError` (Settings)
  - `DatabaseError, ModelError, ValidationError` (Data layer)

## Development Tools

### Configured Linters/Formatters

- **Ruff:** Linting & formatting (replaces Black, isort, Flake8)
- **Pyright:** Type checking (strict mode)
- **Taplo:** TOML formatting
- **Pre-commit:** Git hooks for quality checks
- **REUSE:** License compliance

## Testing

- **Framework:** pytest with plugins:
  - `pytest-qt` (Qt widget testing)
  - `pytest-xvfb` (headless GUI testing)
  - `pytest-sugar, pytest-timeout`
- **Coverage:** Minimum 50% target
- **Test Types:** Unit, integration, e2e (custom markers)

## Documentation

- **MkDocs** with Material theme
- **mkdocstrings:** Auto-generate API docs from docstrings
- **mike:** Version management for docs

## Build & Distribution

- **Package Name:** `jm-dev-tools`
- **Entry Point:** `jm_bde = jm_bde.main:main`
- **Build Backend:** Hatchling
- **Installer:** uv (ultrafast pip replacement)
- **Supported Platforms:** macOS, Windows, Unix/POSIX

### Hatch Environments

- `default:` Standard development
- `dev:` Linting, formatting, pre-commit
- `docs:` Documentation building
- `hatch-test:` Matrix testing (Python 3.11-3.13)

## Configuration Management

- **Settings Storage:** Uses Qt's `QSettings` (platform-aware)
- **Organizational ID:** `jmuelbert`
- **App ID:** `jm_bde`
- **Database Name:** `jm_bde`
- **Translation:** Babel-based i18n with locale files

## Architecture Patterns

1. **Singleton Managers:** Config, logging, translations
2. **Repository Pattern:** Database models encapsulate data access
3. **Service Layer:** Business logic in `services/`
4. **Dependency Injection:** Via `AppContext`
5. **Model-View Pattern:** QML views + Python backends

## Code Quality Standards

- **Type Hints:** Mandatory with `python from __future__ import annotations`
- **Docstrings:** Google-style conventions
- **Logging:** structlog with structured logging
- **Error Handling:** Custom exception hierarchy with cause chaining
- **License:** EUPL-1.2 (European Union Public License)

## Current State

- **Version:** 0.0.1 (early development/beta)
- **Status:** Active development
- **Core Features:** Database models, CLI, GUI framework, configuration system
- **In Progress:** Full GUI implementation, complete CRUD operations

## Notable Design Decisions

1. **Qt + Python:** Hybrid approach using PySide6 for both backend logic and GUI
2. **ORM:** Qt SQL (may indicate migration/compatibility layer)
3. **Pydantic Models:** Separate validation layer from database models
4. **Translation-Ready:** Babel integration for multi-language support
5. **Test-Driven:** Comprehensive test structure with markers for different test
   types

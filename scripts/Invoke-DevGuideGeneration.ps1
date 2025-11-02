# SPDX-License-Identifier: EUPL-1.2
# SPDX-FileCopyrightText: © 2025-present Jürgen Mülbert

<#
.SYNOPSIS
Comprehensive Project Analyzer and Dev Guide Generator (PowerShell version).

.DESCRIPTION
Analyzes a project directory to detect technologies, configuration files,
and task runners, then generates a set of structured Markdown developer
guide files.

.PARAMETER Directory
The project directory to analyze and generate the guide in. Defaults to '.'.

.EXAMPLE
.\devguide-generator.ps1 -Directory C:\MyProject
Generates the dev guide for C:\MyProject.

.NOTES
Requires PowerShell 5.1 or later.
#>
[CmdletBinding(DefaultParameterSetName='Run')]
param(
    [Parameter(Position=0)]
    [string]$Directory = ".",

    [Parameter(ParameterSetName='Help')]
    [Switch]$Help,

    [Parameter(ParameterSetName='Version')]
    [Switch]$Version,

    [Parameter(ParameterSetName='Debug')]
    [Switch]$Debug
)

# --- GLOBAL CONFIGURATION ---
$global:SCRIPT_NAME = "devguide-generator.ps1"
$global:SCRIPT_VERSION = "0.0.8"
$global:PROJECT_DIR = (Resolve-Path $Directory).Path

# --- NEW OUTPUT CONFIGURATION ---
$global:OUTPUT_DIR = "docs/en/developer-guide"

# Define only the file NAMES (paths are constructed dynamically)
$global:TARGET_GUIDE_NAME = "DEVGUIDE.md"
$global:TARGET_TASKFILE_NAME = "TASKFILE.md"
$global:TARGET_HATCHFILE_NAME = "HATCH.md"
$global:TARGET_POETRYFILE_NAME = "POETRY.md"
$global:TARGET_PDMFILE_NAME = "PDM.md"
$global:TARGET_PNPM_SCRIPTS_NAME = "PNPM_SCRIPTS.md"

# Variable to hold all detected types and files for the summary report
$global:PROJECT_TYPES = @()
$global:DOC_FILES = @()
$global:PLATFORM_FILES = @()
$global:AI_FILES = @()
$global:CONFIG_FILES = @()
$global:RECOMMENDATIONS = @()
$global:TEST_DIRS = @()
$global:TEST_COUNT = 0

# Set error action preference to stop script execution on non-terminating errors
$ErrorActionPreference = "Stop"

# Set debug tracing if -Debug switch is used
if ($Debug) {
    Set-PSDebug -Trace 1
}

# -----------------------------------------------------------------------------
# CLI FUNCTIONS
# -----------------------------------------------------------------------------

function Show-Error {
    param(
        [string]$Message
    )
    Write-Host "`e[1;31merror`e[0m: $Message" -ForegroundColor Red -ErrorAction Stop
    exit 1
}

function Show-Version {
    Write-Host "devguide-generator $global:SCRIPT_VERSION"
}

function Show-Usage {
    Show-Version
    @"
Generate or update the Dev Guide ($global:OUTPUT_DIR/$global:TARGET_GUIDE_NAME) based on project analysis.
The guide is formated in markdown.

USAGE:
  .\$global:SCRIPT_NAME [-Directory <path>] [OPTIONS]

DIRECTORY:
  Optional: The project directory to analyze and generate the guide in. Defaults to '.'

OPTIONS:
  -Debug      Show PowerShell debug traces (Set-PSDebug -Trace 1)
  -Help       Print help information
  -Version    Print version information
"@ | Write-Host
}

function Test-CommandExists {
    param(
        [string]$Command
    )
    return (Get-Command $Command -ErrorAction SilentlyContinue -InformationAction SilentlyContinue) -ne $null
}

# -----------------------------------------------------------------------------
# A. ANALYSIS PHASE
# -----------------------------------------------------------------------------

function Invoke-ProjectAnalysis {
    Set-Location $global:PROJECT_DIR

    # Helper function to check for file existence and add to array if found
    function CheckAndAddFile([string]$File, [ref]$Array, [string]$Entry = $File) {
        if (Test-Path -Path $File -PathType Leaf) {
            $Array.Value += $Entry
            return $true
        }
        return $false
    }

    # Helper function to check for directory existence and add to array if found
    function CheckAndAddDirectory([string]$Path, [ref]$Array, [string]$Entry = "$Path/ directory") {
        if (Test-Path -Path $Path -PathType Container) {
            $Array.Value += $Entry
            return $true
        }
        return $false
    }

    # 1. LANGUAGE AND BUILD SYSTEM DETECTION
    # -------------------------------------

    # Node.js/JS/TS
    if (CheckAndAddFile -File "package.json" -Array ([ref]$global:CONFIG_FILES)) {
        if (Test-Path -Path "tsconfig.json" -PathType Leaf) {
            $global:PROJECT_TYPES += "Node.js/TypeScript"
        } else {
            $global:PROJECT_TYPES += "Node.js/JavaScript"
        }
    }

    # Python
    if (Test-Path -Path "pyproject.toml" -PathType Leaf) { $global:PROJECT_TYPES += "Python" }
    elseif (Test-Path -Path "setup.py" -PathType Leaf) { $global:PROJECT_TYPES += "Python" }
    elseif (Test-Path -Path "requirements.txt" -PathType Leaf) { $global:PROJECT_TYPES += "Python" }

    # C/C++
    $cppFiles = Get-ChildItem -Path . -Depth 2 -Include "*.cpp", "*.cc", "*.cxx", "*.h", "*.hpp" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (Test-Path -Path "CMakeLists.txt" -PathType Leaf) {
        $global:PROJECT_TYPES += "C++/C (CMake)"
    } elseif (Test-Path -Path "Makefile" -PathType Leaf) {
        $global:PROJECT_TYPES += "C++/C (Make)"
    } elseif ($cppFiles) {
        $global:PROJECT_TYPES += "C++/C (Generic)"
    }

    # Go/Rust/Java/PowerShell
    if (Test-Path -Path "Cargo.toml" -PathType Leaf) { $global:PROJECT_TYPES += "Rust" }
    if (Test-Path -Path "go.mod" -PathType Leaf) { $global:PROJECT_TYPES += "Go" }
    if (Test-Path -Path "pom.xml" -PathType Leaf) { $global:PROJECT_TYPES += "Java" }
    elseif (Test-Path -Path "build.gradle" -PathType Leaf) { $global:PROJECT_TYPES += "Java" }

    # PowerShell file check (depth 1)
    if (Get-ChildItem -Path . -Depth 1 -Include "*.ps1", "*.psm1", "*.psd1" -ErrorAction SilentlyContinue | Select-Object -First 1) {
        $global:PROJECT_TYPES += "PowerShell"
    }


    # 2. OPEN SOURCE & DOCUMENTATION
    # -------------------------------------------------
    CheckAndAddFile -File "README.md" -Array ([ref]$global:DOC_FILES)
    CheckAndAddFile -File "CHANGELOG.md" -Array ([ref]$global:DOC_FILES)
    if (Test-Path -Path "LICENSE" -PathType Leaf) { $global:DOC_FILES += "LICENSE" }
    elseif (Test-Path -Path "LICENSE.md" -PathType Leaf) { $global:DOC_FILES += "LICENSE" }
    CheckAndAddFile -File "CONTRIBUTING.md" -Array ([ref]$global:DOC_FILES)
    CheckAndAddFile -File "CODE_OF_CONDUCT.md" -Array ([ref]$global:DOC_FILES)
    CheckAndAddFile -File "SECURITY.md" -Array ([ref]$global:DOC_FILES)
    CheckAndAddFile -File "mkdocs.yaml" -Array ([ref]$global:DOC_FILES)
    CheckAndAddFile -File ".readthedocs.yml" -Array ([ref]$global:DOC_FILES)
    CheckAndAddDirectory -Path "docs" -Array ([ref]$global:DOC_FILES)

    # Check for missing governance files
    if ($global:DOC_FILES -notcontains "CONTRIBUTING.md") { $global:RECOMMENDATIONS += "⚠️ CONTRIBUTING.md missing from root. Recommended for contributors." }
    if ($global:DOC_FILES -notcontains "CODE_OF_CONDUCT.md") { $global:RECOMMENDATIONS += "⚠️ CODE_OF_CONDUCT.md missing from root. Recommended for community governance." }


    # 3. PLATFORM & CI/CD INTEGRATION
    # -----------------------------------
    CheckAndAddFile -File ".gitlab-ci.yml" -Array ([ref]$global:PLATFORM_FILES) -Entry ".gitlab-ci.yml (GitLab CI)"
    # Check for existence of any YML file in the workflows directory
    if (Get-ChildItem -Path ".github/workflows" -Filter "*.yml" -ErrorAction SilentlyContinue | Select-Object -First 1) {
        $global:PLATFORM_FILES += "GitHub Workflows (Actions)"
    }
    CheckAndAddFile -File "azure-pipelines.yml" -Array ([ref]$global:PLATFORM_FILES) -Entry "azure-pipelines.yml (Azure)"
    CheckAndAddDirectory -Path ".github" -Array ([ref]$global:PLATFORM_FILES)

    if ($global:PLATFORM_FILES.Count -gt 0) {
        $global:RECOMMENDATIONS += "CI/CD (GitLab/GitHub) found: Use CI/CD pipeline files as the Source of Truth for Build/Test commands."
    }


    # 4. AI ASSISTANCE & CONFIGURATION (Neutralized)
    # -----------------------------------------------
    CheckAndAddFile -File $global:TARGET_GUIDE_NAME -Array ([ref]$global:AI_FILES)
    CheckAndAddFile -File "WARP.md" -Array ([ref]$global:AI_FILES) -Entry "WARP.md (Legacy)"
    CheckAndAddFile -File "CLAUDE.md" -Array ([ref]$global:AI_FILES)
    CheckAndAddFile -File ".cursorrules" -Array ([ref]$global:AI_FILES)
    CheckAndAddFile -File "gemini-config.json" -Array ([ref]$global:AI_FILES) -Entry "gemini-config.json (Gemini Config)"
    CheckAndAddFile -File "ai-system-prompt.txt" -Array ([ref]$global:AI_FILES) -Entry "ai-system-prompt.txt (AI Context)"
    # Check .env file content
    if ((Test-Path -Path ".env" -PathType Leaf) -and (Select-String -Path ".env" -Pattern "GEMINI_API_KEY" -ErrorAction SilentlyContinue)) {
        $global:AI_FILES += ".env (Gemini API Key Hint)"
    }


    # 5. CODE QUALITY & FORMATTING CONFIGS
    # -------------------------------------
    $configFiles = @(
        ".editorconfig", ".gitattributes", ".gitignore", ".dockerignore", ".python-version",
        "Dockerfile", "docker-compose.yml", ".markdown-link-check.json", ".markdownlint.json",
        ".pre-commit-config.yaml", ".prettierignore", ".prettierrc.yaml", ".taplo.toml",
        ".vale.ini", ".yamllint", "biome.json", "cspell.config.yaml", "commitlint.config.js"
    )

    foreach ($file in $configFiles) {
        if (Test-Path -Path $file) {
            $global:CONFIG_FILES += $file
        }
    }

    # Check for Task Runner priority
    if (Test-Path -Path "Taskfile.yml" -PathType Leaf) {
        $global:RECOMMENDATIONS += "Taskfile.yml found: Prioritize 'task [command]' for Build/Test/Lint sections in $global:TARGET_GUIDE_NAME."
    }

    # Check quality configs for recommendation
    $hasQualityConfig = $global:CONFIG_FILES -contains "biome.json" -or `
                        $global:CONFIG_FILES -contains ".prettierrc.yaml" -or `
                        $global:CONFIG_FILES -contains "cspell.config.yaml"

    if ($hasQualityConfig) {
        $global:RECOMMENDATIONS += "Extensive Formatting/Linting: List all quality commands (format, lint, spellcheck) in 'Code Quality' section."
    }
}

function Invoke-DetectPythonPackageManager {
    if (-not (Test-Path -Path "pyproject.toml" -PathType Leaf)) {
        return "Standard (pyproject.toml missing)"
    }

    $pyprojectContent = Get-Content -Path "pyproject.toml" -Raw -ErrorAction SilentlyContinue

    if ($pyprojectContent -match 'build-backend = "poetry\.core\.masonry\.api"') {
        return "Poetry"
    }
    if ($pyprojectContent -match 'build-backend = "hatchling\.build"') {
        return "Hatch"
    }
    if ($pyprojectContent -match 'name = "pdm"') {
        return "PDM"
    }

    return "Standard (Setuptools/Flit)"
}

# -----------------------------------------------------------------------------
# B. GENERATOR PHASE
# -----------------------------------------------------------------------------

function Invoke-GenerateTaskFileDoc {
    if (-not (Test-Path -Path "Taskfile.yml" -PathType Leaf)) {
        return
    }

    $targetPath = Join-Path -Path $global:OUTPUT_DIR -ChildPath $global:TARGET_TASKFILE_NAME
    if (Test-Path -Path $targetPath -PathType Leaf) {
        Write-Host "ℹ️  $targetPath already exists. Skipping generation."
        return
    }

    Write-Host "Generating $targetPath..."

    $content = @"
# 🛠️ Task Runner Documentation: $(Split-Path -Path (Get-Location) -Leaf)

This document details the tasks defined in **\`Taskfile.yml\`**. Use the **\`task\`** command to execute them.

### ℹ️ Command Overview (Quick Reference)

To see a list of all available tasks directly in your console, use:

```bash
task -l
```

| Task Name | Description |
| :--- | :--- |
| **\`default\`** | Lists all available tasks (runs when no task is specified). |

---

## 1. ⚙️ Setup and Environment

These tasks prepare the local development environment, manage dependencies, and clean the project.

| Task Name | Description | Command Example |
| :--- | :--- | :--- |
| **\`pnpm:install\`** | **Install Node.js dependencies** (Installs Node dependencies). | \`task pnpm:install\` |
| **\`hooks:install\`** | **Install pre-commit hooks** (Installs Git Hooks for code quality enforcement). | \`task hooks:install\` |
| \`clean\` | Clean caches, builds, and translations (Removes build artifacts and caches). | \`task clean\` |
| \`reset\` | Reset environment (Resets the entire environment: \`clean\` + environment reset). | \`task reset\` |

---

## 2. 🛡️ Quality Assurance (QA)

These tasks ensure code and documentation quality by running tests, linting, and formatting checks.

### 2.1 Testing and Coverage

| Task Name | Description | Command Example |
| :--- | :--- | :--- |
| **\`test\`** | **Run pytest** (Executes the primary test suite). | \`task test\` |
| \`coverage\` | Run tests with coverage (Runs tests and generates a coverage report). | \`task coverage\` |

### 2.2 Linting and Formatting

| Task Name | Description | Command Example |
| :--- | :--- | :--- |
| **\`format\`** | **Format code and docs** (Automatically formats code and documentation). | \`task format\` |
| **\`lint\`** | **Run all linting** (Executes all code and documentation checks). | \`task lint\` |
| \`lint-code\` | Lint code (Ruff, Taplo, PySide6). | \`task lint-code\` |
| \`lint-docs\` | Lint documentation. | \`task lint-docs\` |
| \`spell-check\` | Check spelling (Runs the project spell checker). | \`task spell-check\` |

> **Translation Note:** Many translation tasks accept the environment variable \`TARGET_LANGUAGE\`, e.g.: \`TARGET_LANGUAGE=de task compile-qt-translations\`.

---

## 3. 🌐 Localization (i18n)

These tasks manage the extraction and compilation of translations (Qt and Babel/Gettext).

| Task Name | Description | Command Example |
| :--- | :--- | :--- |
| **\`translate-all\`** | **Extract & compile all translations** (Full localization workflow). | \`task translate-all\` |
| \`extract-qt-translations\` | Extract Qt translation strings. | \`task extract-qt-translations\` |
| \`compile-qt-translations\` | Compile Qt translations. | \`task compile-qt-translations\` |
| \`extract-babel-translations\` | Extract Babel translation strings. | \`task extract-babel-translations\` |
| \`compile-babel-translations\` | Compile Babel translations. | \`task compile-babel-translations\` |

---

## 4. 📚 Documentation and Analysis

| Task Name | Description | Command Example |
| :--- | :--- | :--- |
| \`docs-build\` | **Build docs** (Creates static documentation files). | \`task docs-build\` |
| \`serve\` | **Serve docs locally** (Starts a local web server for the documentation). | \`task serve\` |
| \`devguide-generate\` | Build an devguide markdown file (Generates the \`DEVGUIDE.md\` file). | \`task devguide-generate\` |
| \`analysis\` | Analysis the project (Performs static/dynamic code analysis). | \`task analysis\` |
| \`dependencies:graph\`| Visualize dependencies. | \`task dependencies:graph\` |

---

## 5. 🔁 Maintenance and Updating

Tasks for updating project dependencies and tools.

| Task Name | Description | Command Example |
| :--- | :--- | :--- |
| **\`maintenance:update-all\`** | Update pnpm dependencies and pre-commit hooks, then run quality checks (Comprehensive maintenance run). | \`task maintenance:update-all\` |
| \`pnpm:update\` | Update Node.js dependencies. | \`task pnpm:update\` |
| \`hooks:update\` | Update pre-commit hooks. | \`task hooks:update\` |
| \`update-project-words\`| Update project words for spelling (Updates spelling dictionaries). | \`task update-project-words\` |

---
## 💡 Adding Custom Tasks

Expand this section to document any specific, project-related tasks defined in your \`Taskfile.yml\` that are not covered above.
"@

    $content | Out-File -FilePath $targetPath -Encoding UTF8
}

function Invoke-GenerateHatchFileDoc {
    $pythonPmTool = Invoke-DetectPythonPackageManager
    if ($pythonPmTool -ne "Hatch") {
        return
    }

    $targetPath = Join-Path -Path $global:OUTPUT_DIR -ChildPath $global:TARGET_HATCHFILE_NAME
    if (Test-Path -Path $targetPath -PathType Leaf) {
        Write-Host "ℹ️  $targetPath already exists. Skipping generation."
        return
    }

    Write-Host "Generating $targetPath..."

    $content = @"
# 🐍 Hatch Documentation: $(Split-Path -Path (Get-Location) -Leaf)

This document provides a deeper dive into managing the project environment and lifecycle using **Hatch**.

---

## 1. Environment and Build Management

Hatch manages virtual environments based on the configuration in \`pyproject.toml\`.

| Command | Description | Notes |
| :--- | :--- | :--- |
| **\`hatch env create\`** | **Creates** the default environment (usually named \`default\`). | Should be run first after cloning. |
| **\`hatch shell\`** | **Activates** the default development environment. | Use this to enter the environment seamlessly. |
| \`hatch env remove\` | Deletes the environment (e.g., \`default\`). | Good for cleaning up old environments. |
| \`hatch run\` | Executes commands *within* the virtual environment. | E.g., \`hatch run python -m my_app\` |
| \`hatch build\` | Creates source and wheel distributions in the \`dist/\` directory. | Standard publishing step. |
| \`hatch publish\` | Publishes the package to PyPI (requires configuration). | |

---

## 2. Development Scripts (\`[tool.hatch.envs.dev.scripts]\`)

These scripts are run using the **\`hatch run [script_name]\`** command within the development environment.

### 2.1 Code Quality and Formatting

| Script Name | Description | Command Executed |
| :--- | :--- | :--- |
| **\`format_all\`** | **Full Quality Run:** Fixes linting errors (\`ruff check --fix\`), formats Python (\`ruff format\`), and formats TOML (\`taplo format\`). **(Recommended)** | \`ruff check . --fix\`, \`ruff format .\`, \`taplo format\` |
| \`format\` | Formats Python code only using Ruff. | \`ruff format .\` |
| \`fix\` | Auto-fixes basic Ruff linting issues. | \`ruff check . --fix\` |
| \`check\` | Runs Ruff checks without fixing. | \`ruff check .\` |
| \`lint\` | Runs Ruff checks without fixing (Alias for \`check\`). | \`ruff check .\` |

### 2.2 Advanced Checks and Typing

| Script Name | Description | Command Executed |
| :--- | :--- | :--- |
| **\`lint_all\`** | **Comprehensive Quality Check:** Runs all static analysis tools. | \`ruff check .\`, \`pyright\`, \`reuse lint\`, \`pre-commit run --all-files\` |
| \`typecheck\` | Runs static type checking using **Pyright**. | \`pyright\` |
| \`typing\` | Runs Pyright, optionally passing arguments. | \`pyright {args}\` |
| \`precommit\` | Manually runs pre-commit hooks, allowing for argument passing. | \`pre-commit {args}\` |

---

## 3. Documentation Scripts (\`[tool.hatch.envs.docs.scripts]\`)

These scripts are designed for building and managing the project's documentation. To run them, you must either be in the \`docs\` environment (using \`hatch shell -e docs\`) or specify the environment: **\`hatch run -e docs [script_name]\`**.

| Script Name | Description | Command Executed |
| :--- | :--- | :--- |
| **\`build\`** | **Builds the documentation** and ensures the search index is properly formatted. | \`mkdocs build...\`, JSON formatting |
| \`serve\` | **Serves the documentation** locally for development (on \`localhost:8090\`). | \`mkdocs serve --dev-addr localhost:8090 {args}\` |
| \`qualitycheck\` | Runs documentation specific quality checks. | \`doc-quality-check\` |
"@
    $content | Out-File -FilePath $targetPath -Encoding UTF8
}

function Invoke-GeneratePoetryDoc {
    $pythonPmTool = Invoke-DetectPythonPackageManager
    if ($pythonPmTool -ne "Poetry") {
        return
    }

    $targetPath = Join-Path -Path $global:OUTPUT_DIR -ChildPath $global:TARGET_POETRYFILE_NAME
    if (Test-Path -Path $targetPath -PathType Leaf) {
        Write-Host "ℹ️  $targetPath already exists. Skipping generation."
        return
    }

    Write-Host "Generating $targetPath..."

    $content = @"
# 🐍 Poetry Documentation: $(Split-Path -Path (Get-Location) -Leaf)

This document provides a deeper dive into managing the project environment and lifecycle using **Poetry**.

---

## 1. Core Commands

| Command | Description | Notes |
| :--- | :--- | :--- |
| **\`poetry install\`** | Installs all dependencies and creates the virtual environment. | Use \`--with dev\` to include development dependencies. |
| **\`poetry shell\`** | Activates the virtual environment. | Use this to enter the environment seamlessly. |
| \`poetry run\` | Executes commands *within* the virtual environment. | E.g., \`poetry run pytest\` |
| \`poetry update\` | Updates dependencies to their latest compatible versions. | |
| \`poetry build\` | Creates source and wheel distributions. | Standard publishing step. |
| \`poetry publish\` | Publishes the package to PyPI (requires configuration). | |

---
## 2. Dependency Management

| Command | Description | Notes |
| :--- | :--- | :--- |
| \`poetry add <package>\` | Adds a new dependency to \`pyproject.toml\`. | Use \`--dev\` for development dependencies. |
| \`poetry remove <package>\` | Removes a dependency. | |
| \`poetry lock\` | Recreates the \`poetry.lock\` file based on \`pyproject.toml\`. | |
"@
    $content | Out-File -FilePath $targetPath -Encoding UTF8
}

function Invoke-GeneratePdmDoc {
    $pythonPmTool = Invoke-DetectPythonPackageManager
    if ($pythonPmTool -ne "PDM") {
        return
    }

    $targetPath = Join-Path -Path $global:OUTPUT_DIR -ChildPath $global:TARGET_PDMFILE_NAME
    if (Test-Path -Path $targetPath -PathType Leaf) {
        Write-Host "ℹ️  $targetPath already exists. Skipping generation."
        return
    }

    Write-Host "Generating $targetPath..."

    $content = @"
# 🐍 PDM Documentation: $(Split-Path -Path (Get-Location) -Leaf)

This document provides a deeper dive into managing the project environment and lifecycle using **PDM**.

---

## 1. Core Commands

| Command | Description | Notes |
| :--- | :--- | :--- |
| **\`pdm install\`** | Installs all dependencies and creates the virtual environment. | |
| **\`pdm run\`** | Executes commands *within* the virtual environment. | E.g., \`pdm run start\` |
| \`pdm update\` | Updates dependencies and locks the new versions. | |
| \`pdm build\` | Creates source and wheel distributions. | Standard publishing step. |
| \`pdm export\` | Exports dependencies to other formats (e.g., \`requirements.txt\`). | |

---
## 2. Dependency Management

| Command | Description | Notes |
| :--- | :--- | :--- |
| \`pdm add <package>\` | Adds a new dependency to \`pyproject.toml\`. | Use \`-d\` or \`--dev\` for development dependencies. |
| \`pdm remove <package>\` | Removes a dependency. | |
| \`pdm sync\` | Synchronizes dependencies between \`pdm.lock\` and the environment. | |
"@
    $content | Out-File -FilePath $targetPath -Encoding UTF8
}

function Invoke-GeneratePnpmScriptsDoc {
    $isNode = $global:PROJECT_TYPES -contains "Node.js/JavaScript" -or $global:PROJECT_TYPES -contains "Node.js/TypeScript"

    if (-not $isNode) {
        return
    }

    $targetPath = Join-Path -Path $global:OUTPUT_DIR -ChildPath $global:TARGET_PNPM_SCRIPTS_NAME
    if (Test-Path -Path $targetPath -PathType Leaf) {
        Write-Host "ℹ️  $targetPath already exists. Skipping generation."
        return
    }

    Write-Host "Generating $targetPath..."

    $content = @"
# 📦 Node.js Scripts (pnpm)

This document details the command scripts defined in the project's \`package.json\`. While most developers should use the centralized **Task** runner (\`task [command]\`), these scripts are the underlying "source of truth" for quality and formatting.

All commands below are executed via \`pnpm run [script_name]\`.

---

## 1. Full Quality Assurance Runs

These scripts combine multiple specific checks into comprehensive runs.

| Script Name | Description | Command Executed |
| :--- | :--- | :--- |
| **\`lint\`** | **Full Quality Check (Code & Docs):** Runs all linters for JavaScript/JSON, TOML, Markdown/YAML, links, spelling, and docs standards. | \`pnpm run lint:js-json && pnpm run lint:toml && pnpm run lint:prettier && pnpm run lint:markdown && pnpm run lint:links && pnpm run lint:spell && pnpm run lint:vale\` |
| **\`format\`** | **Full Formatting Run:** Executes auto-fixing formatters for JS/JSON, TOML, Markdown, and YAML. | \`pnpm run format:js-json && pnpm run format:toml && pnpm run format:prettier && pnpm run format:markdown\` |
| \`lint:docs\` | Quality check focused on documentation files only. | \`pnpm run lint:prettier && pnpm run lint:markdown && pnpm run lint:links && pnpm run lint:spell && pnpm run lint:vale\` |

---

## 2. File-Type Specific Checks (Linting & Formatting)

| Script Name | Description | Command Executed |
| :--- | :--- | :--- |
| \`lint:js-json\` | Linting for JavaScript and JSON files using Biome. | \`biome check ./\` |
| \`format:js-json\` | Formatting for JavaScript and JSON files using Biome. | \`biome format --write ./\` |
| \`lint:toml\` | Checks TOML files (\`pyproject.toml\`, etc.) using Taplo. | \`taplo check\` |
| \`format:toml\` | Formats TOML files using Taplo. | \`taplo format\` |
| \`lint:prettier\` | Checks Markdown and YAML files using Prettier. | \`prettier --check '**/*.{md,mdx,yaml}'\` |
| \`format:prettier\` | Formats Markdown and YAML files using Prettier. | \`prettier --check '**/*.{md,mdx,yaml}'\` |
| \`lint:markdown\` | Comprehensive linting for all Markdown/Asciidoc files. | \`markdownlint... --config .markdownlint.json '**/*.{md,markdown,mdx,adoc,asciidoc}'\` |
| \`format:markdown\` | Auto-fixes Markdown files where possible. | \`markdownlint... --fix --config .markdownlint.json '**/*.{md,markdown,mdx,adoc,asciidoc}'\` |

---

## 3. Documentation & Spelling Tools

| Script Name | Description | Command Executed |
| :--- | :--- | :--- |
| \`lint:links\` | Checks all links in documentation files for broken URLs. | \`markdown-link-check -q -p --config .markdown-link-check.json\` |
| \`lint:vale\` | Runs the Vale style linter against documentation content. | \`vale README.md SECURITY.md docs\` |
| \`lint:spell\` | Runs CSpell for project-wide spelling checks. | \`cspell --no-progress\` |
| \`cspell:project-words\` | Generates or updates the \`project-words.txt\` dictionary file. | \`cspell --words-only --unique | sort --ignore-case >> project-words.txt\` |
| \`cspell:suggests\` | Displays spelling suggestions with context for review. | \`cspell --no-progress --show-suggestions --show-context\` |
"@
    $content | Out-File -FilePath $targetPath -Encoding UTF8
}

function Invoke-GenerateGuide {
    $typesJoined = $global:PROJECT_TYPES -join '**, **'
    $taskRunnerFound = Test-Path -Path "Taskfile.yml" -PathType Leaf

    $isPython = $global:PROJECT_TYPES -contains "Python"
    $isNode = $global:PROJECT_TYPES -contains "Node.js/JavaScript" -or $global:PROJECT_TYPES -contains "Node.js/TypeScript"

    $pythonPmTool = Invoke-DetectPythonPackageManager

    $nodePm = "npm"
    if (Test-CommandExists "pnpm") { $nodePm = "pnpm" }
    elseif (Test-CommandExists "yarn") { $nodePm = "yarn" }

    # --- Python PM Reference Logic ---
    $pmRef = "Standard Python package management (pip/venv)"
    $pmLink = ""
    $pythonSetupCommands = ""

    if ($pythonPmTool -eq "Poetry") {
        $pmRef = "Poetry (using \`pyproject.toml\`)"
        $pmLink = "> **Poetry Note:** Refer to the dedicated [\`$global:TARGET_POETRYFILE_NAME\`](./$global:TARGET_POETRYFILE_NAME) for environment and script commands."
        $pythonSetupCommands = @"
poetry install --with dev
poetry shell # To enter the environment
"@
    }
    elseif ($pythonPmTool -eq "Hatch") {
        $pmRef = "Hatch (using \`pyproject.toml\`)"
        $pmLink = "> **Hatch Note:** Refer to the dedicated [\`$global:TARGET_HATCHFILE_NAME\`](./$global:TARGET_HATCHFILE_NAME) for all environment and script commands."
        $pythonSetupCommands = @"
hatch env create # Creates the default environment
hatch shell # To enter the environment
"@
    }
    elseif ($pythonPmTool -eq "PDM") {
        $pmRef = "PDM (using \`pyproject.toml\`)"
        $pmLink = "> **PDM Note:** Refer to the dedicated [\`$global:TARGET_PDMFILE_NAME\`](./$global:TARGET_PDMFILE_NAME) for environment and script commands."
        $pythonSetupCommands = @"
pdm install
pdm run # To run project scripts
"@
    }
    else {
        $pythonSetupCommands = @"
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
"@
    }

    # --- Dynamic Header Numbering ---
    $setupHeaderNum = 2
    $nodeHeaderNum = 0
    $pythonHeaderNum = 0

    if ($taskRunnerFound) {
        $setupHeaderNum++ # 2.1 is Task Runner
    }
    if ($isNode) {
        $nodeHeaderNum = $setupHeaderNum
        $setupHeaderNum++
    }
    if ($isPython) {
        $pythonHeaderNum = $setupHeaderNum
    }

    # --- HEADER ---
    $header = "# 🚀 Developer Guide: $(Split-Path -Path (Get-Location) -Leaf)`r`n`r`n"
    $header += "This guide provides instructions for setting up the project and running common tasks (build, test, quality checks).`r`n`r`n"
    $header += "---`r`n`r`n"

    # --- SECTION 1: OVERVIEW ---
    $overview = "## 1. Project Overview & Stack`r`n`r`n"
    $overview += "The primary technologies detected in this repository are: **$typesJoined**."
    if ($isPython -and $isNode) {
        $overview += "`r`n`r`n> ⚠️ **Polyglot Project:** This repository contains both Python and Node.js components. Ensure both environments are set up correctly."
    }
    $overview += "`r`n`r`n"

    # --- SECTION 2: SETUP ---
    $setup = "## 2. Environment Setup`r`n"
    $setup += "This section outlines the steps to prepare your local environment.`r`n`r`n"

    # 2.1 Task Runner Priority
    if ($taskRunnerFound) {
        $setup += "### 2.1 Using Task Runner (Recommended)`r`n"
        $setup += "This project uses **Task** (\`Taskfile.yml\`) to manage all common tasks. This is the simplest method for setup.`r`n`r`n"
        $setup += "```bash`r`n"
        $setup += "task setup # Installs all dependencies (Node, Python, etc.)`r`n"
        $setup += "````r`n`r`n"
        $setup += "For a detailed list and explanation of all available tasks, see the dedicated [\`$global:TARGET_TASKFILE_NAME\`](./$global:TARGET_TASKFILE_NAME) documentation.`r`n`r`n"
    }

    # 2.X Node.js Setup
    if ($isNode) {
        $setup += "### $nodeHeaderNum. Node.js Setup`r`n"
        $setup += "Install Node.js dependencies using the detected package manager, **$nodePm**.`r`n`r`n"
        $setup += "```bash`r`n"
        $setup += "$nodePm install`r`n"
        $setup += "````r`n`r`n"
    }

    # 2.Y Python Setup
    if ($isPython) {
        $setup += "### $pythonHeaderNum. Python Setup`r`n"
        $setup += "This project uses **$pmRef**."

        if ($pmLink) {
            $setup += "`r`n`r`n$pmLink"
        }

        $setup += "`r`n`r`n```bash`r`n"
        $setup += "$pythonSetupCommands"
        $setup += "````r`n`r`n"
    }

    # --- SECTION 3: BUILD / RUN ---
    $build = "## 3. Build and Run`r`n`r`n"
    if ($taskRunnerFound) {
        $build += "Most build operations are managed by Task. See [\`$global:TARGET_TASKFILE_NAME\`](./$global:TARGET_TASKFILE_NAME) for all commands.`r`n`r`n"
        $build += "```bash`r`n"
        $build += "task build # Compiles / builds the project`r`n"
        $build += "task run # Runs the application (development mode)`r`n"
        $build += "````r`n"
    }
    # Placeholder for other build systems based on detected PMs (simplified logic from Bash script)
    elseif ($isPython) {
        $build += "Use $pythonPmTool to run scripts or build the package.`r`n"
        $build += "```bash`r`n"
        if ($pythonPmTool -eq "Hatch") { $build += "# Example: hatch run my_build_script`r`nhatch build`r`n" }
        elseif ($pythonPmTool -eq "Poetry" -or $pythonPmTool -eq "PDM") { $build += "$pythonPmTool build`r`n" }
        else { $build += "python3 setup.py build`r`n" }
        $build += "````r`n"
    }
    elseif ($isNode -and (Test-Path -Path "package.json" -PathType Leaf) -and ((Get-Content "package.json" -Raw) -match '"build"')) {
        $build += "The project uses the 'build' script defined in \`package.json\`."
        $build += "`r`n`r`n```bash`r`n"
        $build += "$nodePm run build`r`n"
        $build += "````r`n"
    }
    else {
        $build += "Specific build instructions are missing. Please refer to the documentation for C/C++ build systems (CMake, Make) or native language tools.`r`n"
        if ($global:PROJECT_TYPES -contains "C++/C (CMake)") { $build += "```bash`r`ncmake . && make`r`n````r`n" }
    }
    $build += "`r`n"

    # --- SECTION 4: TESTING & QUALITY ---
    $quality = "## 4. Testing and Code Quality`r`n`r`n"

    # 4.1 Running Tests
    $quality += "### 4.1 Running Tests`r`n"
    $frameworksList = @()
    if ($isNode -and (Test-Path -Path "package.json" -PathType Leaf)) {
        $pkgContent = Get-Content "package.json" -Raw
        if ($pkgContent -match '"jest"') { $frameworksList += "Jest" }
        if ($pkgContent -match '"vitest"') { $frameworksList += "Vitest" }
    }
    if ($isPython -and ((Test-Path -Path "pytest.ini" -PathType Leaf) -or (Test-Path -Path "pyproject.toml" -PathType Leaf) -and ((Get-Content "pyproject.toml" -Raw) -match "pytest"))) {
        $frameworksList += "pytest"
    }

    if ($frameworksList.Count -gt 0) {
        $quality += "Detected Test Frameworks: **$($frameworksList -join ', ')**.`r`n"
    }

    if ($taskRunnerFound) {
        $quality += "Use the Task runner to execute tests:`r`n"
        $quality += "```bash`r`ntask test`r`n````r`n"
    }
    # Simplified Python test command generation
    elseif ($isPython) {
        $quality += "Run tests using $pythonPmTool:`r`n"
        $quality += "```bash`r`n"
        if ($pythonPmTool -eq "Hatch") { $quality += "hatch run test`r`n" }
        elseif ($pythonPmTool -eq "Poetry") { $quality += "poetry run pytest`r`n" }
        elseif ($pythonPmTool -eq "PDM") { $quality += "pdm run pytest`r`n" }
        else { $quality += "pytest`r`n" }
        $quality += "````r`n"
    }
    elseif ($isNode) {
        $quality += "Run tests using the package manager's test script:`r`n"
        $quality += "```bash`r`n$nodePm run test`r`n````r`n"
    }
    else {
        $quality += "No standard test runners detected. Please consult specific language documentation.`r`n"
    }

    # 4.2 Code Quality Checks
    $quality += "`r`n### 4.2 Code Quality Checks`r`n"
    if ($taskRunnerFound) {
        $quality += "All linting, formatting, and quality checks are consolidated under the Task runner:`r`n"
        $quality += "```bash`r`ntask lint`r`ntask format`r`n````r`n"
        $quality += "For details on individual linting commands, see [\`$global:TARGET_TASKFILE_NAME\`](./$global:TARGET_TASKFILE_NAME).`r`n`r`n"
    }
    elseif ($isNode) {
        $quality += "Code quality checks are managed via Node.js scripts. For comprehensive details on all linting and formatting commands (Biome, Prettier, etc.), see the dedicated [\`$global:TARGET_PNPM_SCRIPTS_NAME\`](./$global:TARGET_PNPM_SCRIPTS_NAME) document.`r`n`r`n"
        $quality += "```bash`r`n$nodePm run lint`r`n$nodePm run format`r`n````r`n"
    }
    elseif ($pythonPmTool -eq "Hatch" -and ((Get-Content "pyproject.toml" -Raw) -match "format_all")) {
        $quality += "Code quality checks are defined as Hatch scripts. See [\`$global:TARGET_HATCHFILE_NAME\`](./$global:TARGET_HATCHFILE_NAME).`r`n`r`n"
        $quality += "```bash`r`nhatch run format_all`r`n````r`n"
    }
    else {
        $quality += "Check for specific configuration files like \`.pre-commit-config.yaml\` or tooling like \`ruff\` / \`eslint\` to find quality commands.`r`n"
    }

    # --- SECTION 5: SUMMARY & RECOMMENDATIONS ---
    $summary = "## 5. Project Summary and Recommendations`r`n"

    $summary += "`r`n### 5.1 Detected Configuration Files`r`n"
    if ($global:CONFIG_FILES.Count -gt 0) {
        $summary += "The following general configuration and development files were detected:`r`n"
        $summary += ($global:CONFIG_FILES | ForEach-Object { "* \`$_\`" }) -join "`r`n"
        $summary += "`r`n"
    } else {
        $summary += "No specific configuration files (like \`.editorconfig\`, \`.gitignore\`, or Docker files) were detected.`r`n"
    }

    $summary += "`r`n### 5.2 Documentation and Governance Files`r`n"
    if ($global:DOC_FILES.Count -gt 0) {
        $summary += "The following documentation and governance files were detected:`r`n"
        $summary += ($global:DOC_FILES | ForEach-Object { "* \`$_\`" }) -join "`r`n"
        $summary += "`r`n"
    } else {
        $summary += "No core documentation files (e.g., README, LICENSE) were detected.`r`n"
    }

    $summary += "`r`n### 5.3 CI/CD and Platform Files`r`n"
    if ($global:PLATFORM_FILES.Count -gt 0) {
        $summary += "The project integrates with the following platforms/CI/CD systems:`r`n"
        $summary += ($global:PLATFORM_FILES | ForEach-Object { "* $_" }) -join "`r`n"
        $summary += "`r`n"
    } else {
        $summary += "No CI/CD configuration files (\`.gitlab-ci.yml\`, GitHub Actions) were found.`r`n"
    }

    $summary += "`r`n### 5.4 Generator Recommendations`r`n"
    if ($global:RECOMMENDATIONS.Count -gt 0) {
        $summary += "Based on the project analysis, here are some recommendations:`r`n"
        $summary += ($global:RECOMMENDATIONS | ForEach-Object { "* $_" }) -join "`r`n"
        $summary += "`r`n"
    } else {
        $summary += "No specific recommendations identified at this time.`r`n"
    }
    $summary += "`r`n---`r`n"
    $summary += "`r`n*Generated by $global:SCRIPT_NAME (v$global:SCRIPT_VERSION) on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss').*`r`n"


    $fullContent = $header + $overview + $setup + $build + $quality + $summary

    # Save the file
    $targetPath = Join-Path -Path $global:OUTPUT_DIR -ChildPath $global:TARGET_GUIDE_NAME
    Write-Host "Generating main guide $targetPath..."
    $fullContent | Out-File -FilePath $targetPath -Encoding UTF8
}

# -----------------------------------------------------------------------------
# MAIN EXECUTION
# -----------------------------------------------------------------------------

function Invoke-Main {
    switch ($PSCmdlet.ParameterSetName) {
        "Help" {
            Show-Usage
            exit 0
        }
        "Version" {
            Show-Version
            exit 0
        }
    }

    if (-not (Test-Path -Path $global:PROJECT_DIR -PathType Container)) {
        Show-Error "Directory '$global:PROJECT_DIR' not found."
    }

    Write-Host "Starting project analysis in: '$global:PROJECT_DIR'"
    Write-Host "Output directory: '$global:OUTPUT_DIR'"

    # 1. Ensure output directory exists
    $outputFullPath = Join-Path -Path $global:PROJECT_DIR -ChildPath $global:OUTPUT_DIR
    New-Item -Path $outputFullPath -ItemType Directory -Force | Out-Null

    # 2. Analysis
    Invoke-ProjectAnalysis

    # 3. Generate auxiliary docs
    Invoke-GenerateTaskFileDoc
    Invoke-GenerateHatchFileDoc
    Invoke-GeneratePoetryDoc
    Invoke-GeneratePdmDoc
    Invoke-GeneratePnpmScriptsDoc

    # 4. Generate main guide
    Invoke-GenerateGuide

    Write-Host "`n✅ Generation complete. Output files are in: $outputFullPath"
}

# Run the main function
Invoke-Main

# SPDX-License-Identifier: EUPL-1.2
# SPDX-FileCopyrightText: © 2025-present Jürgen Mülbert

<#
.SYNOPSIS
Comprehensive Project Analyzer and Dev Guide Generator (PowerShell version).

.DESCRIPTION
Analyzes a project directory to detect technologies, configuration files,
and task runners, then generates a structured Markdown developer guide file (DEVGUIDE.md).

.PARAMETER Directory
The project directory to analyze and generate the guide in. Defaults to '.'.

.PARAMETER Version
Displays the version information for the Invoke-DevGuideGeneration script.
This parameter is mutually exclusive with running the generation process.

.EXAMPLE
.\Invoke-DevGuideGeneration.ps1 -Directory C:\MyProject
Generates the dev guide for C:\MyProject.

.LINK
[jm-dev-tools](https://github.com/jmuelbert/jm-dev-tools)

.LINK
[jm-dev-tools README](https://github.com/jmuelbert/jm-dev-tools#readme)

.NOTES
This script is intended to be run as the function 'Invoke-DevGuideGeneration'
after dot-sourcing the file to correctly integrate with documentation tools like PlatyPS.
Requires PowerShell 5.1 or later.
#>
function Invoke-DevGuideGeneration {
    # This attribute must immediately precede the param block.
    [CmdletBinding(DefaultParameterSetName='Run')]
    param(
        [Parameter(Position=0)]
        [string]$Directory = ".",

        [Parameter(ParameterSetName='Version')]
        [Switch]$Version
    )

    # --- GLOBAL CONFIGURATION ---
    # $SCRIPT_NAME = "Invoke-DevGuideGeneration.ps1"
    $SCRIPT_VERSION = "0.0.10" # Updated version to match bash script

    # --- OUTPUT CONFIGURATION ---
    $OUTPUT_DIR = "docs/en/developer-guide"
    $TARGET_GUIDE_NAME = "DEVGUIDE.md"

    # Global state variables (must be arrays for accumulation)
    $PROJECT_TYPES = @()
    $DOC_FILES = @()
    $PLATFORM_FILES = @()
    $CONFIG_FILES = @()
    $RECOMMENDATIONS = @()

    # Set error action preference to stop script execution on non-terminating errors
    $ErrorActionPreference = "Stop"

    # Set debug tracing if -Debug switch is used
    if ($Debug) {
        Set-PSDebug -Trace 1
    }

    # -----------------------------------------------------------------------------
    # CLI / Utility FUNCTIONS
    # -----------------------------------------------------------------------------

    function Show-Error {
        param([string]$Message)
        Write-Output "`e[1;31merror`e[0m: $Message" -ForegroundColor Red -ErrorAction Stop
        exit 1
    }

    function Show-Version {
        Write-Output "devguide-generator $SCRIPT_VERSION"
    }

    function Test-CommandExist {
        param([string]$Command)
        return $null -ne (Get-Command $Command -ErrorAction SilentlyContinue -InformationAction SilentlyContinue)
    }

    # -----------------------------------------------------------------------------
    # A. ANALYSIS PHASE
    # -----------------------------------------------------------------------------

    function Invoke-ProjectAnalysis {
        # Helper function to check for file existence and add to array if found
        function CheckAndAddFile([string]$File, [ref]$Array, [string]$Entry = $File) {
            if (Test-Path -Path $File -PathType Leaf) {
                $Array.Value += $Entry
                return $true
            }
            return $false
        }

        # --- 1. LANGUAGE AND BUILD SYSTEM DETECTION (Partial implementation) ---

        # Node.js/JS/TS
        if (CheckAndAddFile -File "package.json" -Array ([ref]$CONFIG_FILES)) {
            if (Test-Path -Path "tsconfig.json" -PathType Leaf) {
                $PROJECT_TYPES += "Node.js/TypeScript"
            } else {
                $PROJECT_TYPES += "Node.js/JavaScript"
            }
        }

        # Python
        $hasPythonFiles = (Test-Path -Path "pyproject.toml" -PathType Leaf) -or `
                                  (Test-Path -Path "setup.py" -PathType Leaf) -or `
                                  (Test-Path -Path "requirements.txt" -PathType Leaf)

        if ($hasPythonFiles)
        {
            $PROJECT_TYPES += "Python"
        }

        # Rust
        if (Test-Path -Path "Cargo.toml" -PathType Leaf) { $PROJECT_TYPES += "Rust" }

        # Go
        if (Test-Path -Path "go.mod" -PathType Leaf) { $PROJECT_TYPES += "Go" }

        # C++/C
        if (Test-Path -Path "CMakeLists.txt" -PathType Leaf) {
            $PROJECT_TYPES += "C++/C (CMake)"
        } elseif (Test-Path -Path "Makefile" -PathType Leaf) {
            $PROJECT_TYPES += "C++/C (Generic)"
        }

        # --- 2. Documentation & Governance ---
        CheckAndAddFile -File "CONTRIBUTING.md" -Array ([ref]$DOC_FILES)
        CheckAndAddFile -File "CODE_OF_CONDUCT.md" -Array ([ref]$DOC_FILES)

        # Check for missing governance files
        if ($DOC_FILES -notcontains "CONTRIBUTING.md") { $RECOMMENDATIONS += "⚠️ CONTRIBUTING.md missing from root. Recommended for contributors." }
        if ($DOC_FILES -notcontains "CODE_OF_CONDUCT.md") { $RECOMMENDATIONS += "⚠️ CODE_OF_CONDUCT.md missing from root. Recommended for community governance." }

        # --- 3. CI/CD & Config ---
        if (Test-Path -Path "Taskfile.yml" -PathType Leaf) {
            $RECOMMENDATIONS += "Taskfile.yml found: Prioritize 'task [command]' for all project operations."
            $CONFIG_FILES += "Taskfile.yml"
        }

        # CI/CD Pipeline
        if (Test-Path -Path ".gitlab-ci.yml" -PathType Leaf) {
            $PLATFORM_FILES += ".gitlab-ci.yml (GitLab CI)"
        }
        if (Get-ChildItem -Path ".github/workflows" -Filter "*.yml" -ErrorAction SilentlyContinue) {
            $PLATFORM_FILES += "CI/CD Pipeline (GitHub Actions)"
        }

        # General config files
        $configFiles = @(".editorconfig", ".gitattributes", ".pre-commit-config.yaml", "cspell.config.yaml")
        foreach ($file in $configFiles) {
            if (Test-Path -Path $file) {
                $CONFIG_FILES += $file
            }
        }
    }

    function Invoke-DetectPythonPackageManager {
        if (-not (Test-Path -Path "pyproject.toml" -PathType Leaf)) {
            return "Standard (pyproject.toml missing)"
        }

        $pyprojectContent = Get-Content -Path "pyproject.toml" -Raw -ErrorAction SilentlyContinue

        if ($pyprojectContent -match 'build-backend\s*=\s*"poetry\.core\.masonry\.api"') {
            return "Poetry"
        }
        if ($pyprojectContent -match 'build-backend\s*=\s*"hatchling\.build"') {
            return "Hatch"
        }
        if ($pyprojectContent -match 'name\s*=\s*"pdm"') {
            return "PDM"
        }

        return "Standard (Setuptools/Flit)"
    }

    # -----------------------------------------------------------------------------
    # B. GENERATOR PHASE (The core logic from generate_guide in Bash)
    # -----------------------------------------------------------------------------

    function Invoke-GenerateGuide {
        $typesJoined = $PROJECT_TYPES -join '**, **'
        $taskRunnerFound = $CONFIG_FILES -contains "Taskfile.yml"

        $isPython = $PROJECT_TYPES -contains "Python"
        $isNode = $PROJECT_TYPES -contains "Node.js/JavaScript" -or $PROJECT_TYPES -contains "Node.js/TypeScript"

        $pythonPmTool = Invoke-DetectPythonPackageManager

        $nodePm = "npm"
        if (Test-CommandExist "pnpm") { $nodePm = "pnpm" }

        $output = @()

        # --- HEADER ---
        $output += "# 🚀 Developer Guide: $(Split-Path -Path (Get-Location) -Leaf)"
        $output += ""
        $output += "This guide provides instructions for setting up the project and running common tasks (build, test, quality checks)."
        $output += ""
        $output += "---"
        $output += ""

        # --- SECTION 1: OVERVIEW ---
        $output += "## 1. Project Overview & Stack"
        $output += ""
        $output += "The primary technologies detected in this repository are: **$typesJoined**."

        if ($isPython -and $isNode) {
            $output += ""
            $output += "> ⚠️ **Polyglot Project:** This repository contains both Python and Node.js components. Ensure both environments are set up correctly."
        }
        $output += ""

        # --- SECTION 2: SETUP ---
        $output += "## 2. Environment Setup"
        $output += "This section outlines the steps to prepare your local environment."
        $output += ""

        # 2.1 Task Runner Priority
        $currentHeaderNum = 2.1
        if ($taskRunnerFound) {
            $output += "### 2.1 Task Runner Setup (Recommended)"
            $output += "This project uses **Task** (\`Taskfile.yml\`) to manage all common tasks. This is the simplest method for full project setup."
            $output += ""
            $output += "To set up the entire environment (including dependencies, hooks, and venv creation):"
            $output += '```bash'
            $output += "task reset"
            $output += '```'
            $output += ""
            $currentHeaderNum = 2.2
        }

        # 2.2 Language-Specific Setup
        # Initialize $currentHeaderNum (If Taskfile was found, it starts at 2.1, otherwise 2.0)
        $currentHeaderNum = 2.0
        if ($taskRunnerFound) {
            $currentHeaderNum = 2.1
        }

        if ($isNode) {
            # Use standard float addition for simple increment
            $currentHeaderNum += 0.1

            # Format to one decimal place for the output string
            $headerString = "{0:N1}" -f $currentHeaderNum

            $output += "### $headerString. Node.js Setup"
            $output += "Install Node.js dependencies using the detected package manager, **$nodePm** (assumed for tooling)."
            $output += ""
            $output += '```bash'
            $output += "$nodePm install"
            $output += '```'
            $output += ""
        }

        if ($isPython) {
            # Continue incrementing
            $currentHeaderNum += 0.1
            $headerString = "{0:N1}" -f $currentHeaderNum

            $pmRef = "Standard Python environment"
            $installCmd = "pip install -r requirements.txt"
            $activateCmd = "source .venv/bin/activate # (If using standard venv)"

            switch ($pythonPmTool) {
                "Poetry" { $pmRef="Poetry"; $installCmd="poetry install --with dev"; $activateCmd="poetry shell # To activate the environment" }
                "Hatch" { $pmRef="Hatch"; $installCmd="hatch env create"; $activateCmd="hatch shell # To activate the environment" }
                "PDM" { $pmRef="PDM"; $installCmd="pdm install"; $activateCmd="pdm run # To activate the environment" }
            }

            $output += "### $currentHeaderNum. Python Setup"
            $output += "This project uses **$pmRef** for environment management."
            $output += ""
            $output += '```bash'
            $output += "$installCmd # Install dependencies"
            $output += $activateCmd
            $output += '```'
            $output += ""
        }

        # --- SECTION 3: CORE WORKFLOW (Build / Run / Quality) ---
        $output += "## 3. Core Workflow (Build, Run, Quality)"
        $output += ""

        if ($taskRunnerFound) {
            $output += "All core operations are managed via **Task** to maintain consistency across languages (Python, Rust, C++ templates)."
            $output += ""
            $output += "### Universal Commands (Using \`LANG\`)"
            $output += "These commands work universally across different language components in the repository:"
            $output += ""
            $output += '```bash'
            $output += "task build LANG=python   # Or LANG=rust, LANG=cpp"
            $output += "task run LANG=python     # Executes the built application"
            $output += "task clean               # Removes all build artifacts, caches, and translations"
            $output += '```'

            $output += ""
            $output += "### Quality Assurance"
            $output += "The quality commands execute all necessary linters, formatters, and tests:"
            $output += ""
            $output += '```bash'
            $output += "task format              # Automatically formats all code and documentation"
            $output += "task lint                # Runs all quality checks (Ruff, Taplo, etc.)"
            $output += "task test                # Executes the test suite (pytest/other)"
            $output += '```'
            $output += ""
            $output += "For the complete list of tasks, including documentation, translations, and maintenance, run:"
            $output += '```bash'
            $output += "task -l"
            $output += '```'
        } else {
            $output += "### Build and Run"
            if ($isPython) {
                $output += "Use your Python package manager to run the application:"
                $output += '```bash'
                switch ($pythonPmTool) {
                    "Hatch" { $output += "hatch run default: python -m project_name" }
                    "Poetry" { $output += "poetry run python -m project_name" }
                    "PDM" { $output += "pdm run start" }
                    default { $output += "python -m project_name # After activating venv" }
                }
                $output += '```'
            } else {
                $output += "Specific build instructions are not defined. Refer to language-specific tools."
            }

            $output += ""
            $output += "### Testing and Quality Checks"
            $output += "Manually run quality checks using the native tools:"
            $output += '```bash'
            $output += "# Example: Run Ruff/Pre-commit"
            $output += "pre-commit run --all-files"
            $output += "# Example: Run tests"
            $output += "pytest"
            $output += '```'
        }
        $output += ""

        # --- SECTION 4: RECOMMENDATIONS ---
        if ($RECOMMENDATIONS.Count -gt 0) {
            $output += "## 4. Recommendations"
            $output += "Based on the project analysis, here are some suggestions:"
            $output += ""
            foreach ($rec in $RECOMMENDATIONS) {
                $output += "* $rec"
            }
            $output += ""
        }

        return $output -join "`n"
    }

    # -----------------------------------------------------------------------------
    # C. MAIN EXECUTION LOGIC (Adapted from your main function)
    # -----------------------------------------------------------------------------

    # Handle simple switches first
    if ($Version) { Show-Version; return }

    try {
        # 1. Resolve and navigate to project directory
        $PROJECT_DIR = (Resolve-Path $Directory -ErrorAction Stop).Path
        Set-Location $PROJECT_DIR
        Write-Verbose "Navigating to project directory: $PROJECT_DIR"

        # 2. Create output directory if it doesn't exist
        $outputPath = Join-Path -Path $PROJECT_DIR -ChildPath $OUTPUT_DIR
        New-Item -Path $outputPath -ItemType Directory -Force | Out-Null
        Write-Verbose "Output directory ensured: $outputPath"

        # 3. Perform analysis
        Write-Verbose "Starting project analysis..."
        Invoke-ProjectAnalysis

        # 4. Generate the main guide file
        $devguidePath = Join-Path -Path $outputPath -ChildPath $TARGET_GUIDE_NAME
        Write-Verbose "Generating final guide: $devguidePath..."

        # Generate content and redirect to the target file
        Invoke-GenerateGuide | Out-File -FilePath $devguidePath -Encoding UTF8

        Write-Output "✅ Dev Guide generation complete."
    }
    catch {
        Show-Error "An error occurred during execution: $($_.Exception.Message)"
    }
}

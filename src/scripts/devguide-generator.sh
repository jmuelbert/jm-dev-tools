#!/bin/bash
# SPDX-License-Identifier: EUPL-1.2
# SPDX-FileCopyrightText: © 2025-present Jürgen Mülbert

# Comprehensive Project Analyzer and Dev Guide Generator
# Usage: ./devguide-generator.sh [directory]
# ---------------------------------------------------
# Focus: Dev Guide Content Generation based on project analysis.
# ---------------------------------------------------
#
# Exit immediately if a command exits or pipes a non-zero return code.
## \author Juergen Muelbert
## \brief Main script to generate developer guides.
## \desc This script automates documentation generation steps.
## \option -v, --verbose
## \option-desc Enable verbose output.

## \option -o, --output <DIR>
## \option-desc Specify the output directory.

set -eou pipefail

# --- GLOBAL CONFIGURATION ---
readonly SCRIPT_NAME="devguide-generator.sh"
readonly SCRIPT_VERSION="0.0.9" # Updated version
PROJECT_DIR="."

# --- OUTPUT CONFIGURATION ---
# All generated files will be placed inside this directory.
readonly OUTPUT_DIR="docs/en/developer-guide"

# Define only the name of the main guide file
readonly TARGET_GUIDE_NAME="DEVGUIDE.md"

# Variable to hold all detected types and files for the summary report
PROJECT_TYPES=()
DOC_FILES=()
PLATFORM_FILES=()
CONFIG_FILES=()
RECOMMENDATIONS=()

# ######################################
# Print error message and exit script with error code.
# ######################################
error() {
  local bold_red='\033[1;31m'
  local default='\033[0m'

  printf "${bold_red}error${default}: %s\n" "$1" >&2
  exit 1
}

# ######################################
# Print devguide-generator version string.
# ######################################
version() {
  echo "devguide-generator $SCRIPT_VERSION"
}

# ######################################
# Show CLI help information.
# ######################################
usage() {
  cat 1>&2 <<EOF
$(version)
Generate or update the Dev Guide ($OUTPUT_DIR/$TARGET_GUIDE_NAME) based on project analysis.
The guide is formated in markdown.

USAGE:
  $SCRIPT_NAME [OPTIONS] [DIRECTORY]

DIRECTORY:
  Optional: The project directory to analyze and generate the guide in. Defaults to '.'

OPTIONS:
  --debug    Show Bash debug traces (set -x)
  -h, --help Print help information
  -v, --version Print version information
EOF
}

# ######################################
# Function to check if command exists
# ######################################
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# ===============================================================
# A. ANALYSIS PHASE (Simplified for brevity)
# ===============================================================
project_analysis() {
  # --- Project Type Detection ---
  if [[ -f "package.json" ]]; then
    if [[ -f "tsconfig.json" ]]; then PROJECT_TYPES+=("Node.js/TypeScript"); else PROJECT_TYPES+=("Node.js/JavaScript"); fi
  fi
  if [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]] || [[ -f "requirements.txt" ]]; then PROJECT_TYPES+=("Python"); fi
  if [[ -f "Cargo.toml" ]]; then PROJECT_TYPES+=("Rust"); fi
  if [[ -f "go.mod" ]]; then PROJECT_TYPES+=("Go"); fi
  if [[ -f "CMakeLists.txt" ]] || [[ -f "Makefile" ]] || find . -maxdepth 2 -name "*.cpp" -o -name "*.cxx" | grep -q .; then
    if [[ -f "CMakeLists.txt" ]]; then PROJECT_TYPES+=("C++/C (CMake)"); else PROJECT_TYPES+=("C++/C (Generic)"); fi
  fi

  # --- Documentation & Governance ---
  if [[ -f "CONTRIBUTING.md" ]]; then DOC_FILES+=("CONTRIBUTING.md"); fi
  if [[ -f "CODE_OF_CONDUCT.md" ]]; then DOC_FILES+=("CODE_OF_CONDUCT.md"); fi
  if ! [[ " ${DOC_FILES[*]} " =~ CONTRIBUTING.md ]]; then RECOMMENDATIONS+=("⚠️ CONTRIBUTING.md missing from root. Recommended for contributors."); fi
  if ! [[ " ${DOC_FILES[*]} " =~ CODE_OF_CONDUCT.md ]]; then RECOMMENDATIONS+=("⚠️ CODE_OF_CONDUCT.md missing from root. Recommended for community governance."); fi

  # --- CI/CD & Config ---
  if [[ -f "Taskfile.yml" ]]; then
    RECOMMENDATIONS+=("Taskfile.yml found: Prioritize 'task [command]' for all project operations.")
    CONFIG_FILES+=("Taskfile.yml")
  fi
  if find .github/workflows -maxdepth 1 -name "*.yml" 2>/dev/null | grep -q . || [[ -f ".gitlab-ci.yml" ]]; then
    PLATFORM_FILES+=("CI/CD Pipeline")
  fi
  for file in .editorconfig .gitattributes .pre-commit-config.yaml cspell.config.yaml; do
    if [[ -f "$file" ]] || [[ -d "$file" ]]; then CONFIG_FILES+=("$file"); fi
  done
}

detect_python_pm() {
  if [[ ! -f "pyproject.toml" ]]; then
    echo "Standard (pyproject.toml missing)"
    return
  fi

  if grep -q 'build-backend = "poetry.core.masonry.api"' pyproject.toml 2>/dev/null; then
    echo "Poetry"
  elif grep -q 'build-backend = "hatchling.build"' pyproject.toml 2>/dev/null; then
    echo "Hatch"
  elif grep -q 'name = "pdm"' pyproject.toml 2>/dev/null; then
    echo "PDM"
  else
    echo "Standard (Setuptools/Flit)"
  fi
}

# ===============================================================
# C. GENERATOR PHASE
# (Removed all generate_..._doc functions for simplicity)
# ===============================================================

# ######################################
# Generates the DEV-GUIDE.md content to stdout.
# ######################################
generate_guide() {
  types_joined=$(
    IFS=', '
    echo "${PROJECT_TYPES[*]}"
  )
  local types_joined
  local task_runner_found=0
  [[ -f "Taskfile.yml" ]] && task_runner_found=1

  local is_python=0
  [[ " ${PROJECT_TYPES[*]} " =~ " Python " ]] && is_python=1
  local is_node=0
  if [[ " ${PROJECT_TYPES[*]} " =~ Node.js/JavaScript ]] || [[ " ${PROJECT_TYPES[*]} " =~ Node.js/TypeScript ]]; then
    is_node=1
  fi
  python_pm_tool=$(detect_python_pm)
  local python_pm_tool
  local node_pm="npm"
  command_exists pnpm && node_pm="pnpm"

  # --- HEADER ---
  echo "# 🚀 Developer Guide: $(basename "$(pwd)")"
  echo ""
  echo "This guide provides instructions for setting up the project and running common tasks (build, test, quality checks)."
  echo ""
  echo "---"
  echo ""

  # --- SECTION 1: OVERVIEW ---
  echo "## 1. Project Overview & Stack"
  echo ""
  echo "The primary technologies detected in this repository are: **${types_joined//, /**, **}**."

  if [[ $is_python -eq 1 && $is_node -eq 1 ]]; then
    echo ""
    echo "> ⚠️ **Polyglot Project:** This repository contains both Python and Node.js components. Ensure both environments are set up correctly."
  fi
  echo ""

  # --- SECTION 2: SETUP ---
  echo "## 2. Environment Setup"
  echo "This section outlines the steps to prepare your local environment."
  echo ""

  # 2.1 Task Runner Priority
  if [[ $task_runner_found -eq 1 ]]; then
    echo "### 2.1 Task Runner Setup (Recommended)"
    echo "This project uses **Task** (\`Taskfile.yml\`) to manage all common tasks. This is the simplest method for full project setup."
    echo ""
    echo "To set up the entire environment (including dependencies, hooks, and venv creation):"
    echo "\`\`\`bash"
    echo "task reset"
    echo "\`\`\`"
    echo ""
  fi

  # 2.2 Language-Specific Setup
  local current_header_num=$((2 + task_runner_found))

  if [[ $is_node -eq 1 ]]; then
    echo "### ${current_header_num}. Node.js Setup"
    echo "Install Node.js dependencies using the detected package manager, **$node_pm** (assumed for tooling)."
    echo ""
    echo "\`\`\`bash"
    echo "$node_pm install"
    echo "\`\`\`"
    echo ""
    current_header_num=$((current_header_num + 1))
  fi

  if [[ $is_python -eq 1 ]]; then
    local pm_ref="Standard Python environment"
    local install_cmd="pip install -r requirements.txt"

    if [[ "$python_pm_tool" == "Poetry" ]]; then
      pm_ref="Poetry"
      install_cmd="poetry install --with dev"
    fi
    if [[ "$python_pm_tool" == "Hatch" ]]; then
      pm_ref="Hatch"
      install_cmd="hatch env create"
    fi
    if [[ "$python_pm_tool" == "PDM" ]]; then
      pm_ref="PDM"
      install_cmd="pdm install"
    fi

    echo "### ${current_header_num}. Python Setup"
    echo "This project uses **$pm_ref** for environment management."
    echo ""
    echo "\`\`\`bash"
    echo "$install_cmd # Install dependencies"
    if [[ "$python_pm_tool" == "Hatch" ]]; then
      echo "hatch shell # To activate the environment"
    elif [[ "$python_pm_tool" == "Poetry" ]]; then
      echo "poetry shell # To activate the environment"
    else
      echo "source .venv/bin/activate # (If using standard venv)"
    fi
    echo "\`\`\`"
    echo ""
    current_header_num=$((current_header_num + 1))
  fi

  # --- SECTION 3: CORE WORKFLOW (Build / Run / Quality) ---
  echo "## 3. Core Workflow (Build, Run, Quality)"
  echo ""

  if [[ $task_runner_found -eq 1 ]]; then
    echo "All core operations are managed via **Task** to maintain consistency across languages (Python, Rust, C++ templates)."
    echo ""
    echo "### Universal Commands (Using \`LANG\`)"
    echo "These commands work universally across different language components in the repository:"
    echo ""
    echo "\`\`\`bash"
    echo "task build LANG=python   # Or LANG=rust, LANG=cpp"
    echo "task run LANG=python     # Executes the built application"
    echo "task clean               # Removes all build artifacts, caches, and translations"
    echo "\`\`\`"

    echo ""
    echo "### Quality Assurance"
    echo "The quality commands execute all necessary linters, formatters, and tests:"
    echo ""
    echo "\`\`\`bash"
    echo "task format              # Automatically formats all code and documentation"
    echo "task lint                # Runs all quality checks (Ruff, Taplo, etc.)"
    echo "task test                # Executes the test suite (pytest/other)"
    echo "\`\`\`"
    echo ""
    echo "For the complete list of tasks, including documentation, translations, and maintenance, run:"
    echo "\`\`\`bash"
    echo "task -l"
    echo "\`\`\`"
  else
    echo "### Build and Run"
    if [[ $is_python -eq 1 ]]; then
      echo "Use your Python package manager to run the application:"
      echo "\`\`\`bash"
      if [[ "$python_pm_tool" == "Hatch" ]]; then
        echo "hatch run default: python -m project_name"
      elif [[ "$python_pm_tool" == "Poetry" ]]; then
        echo "poetry run python -m project_name"
      elif [[ "$python_pm_tool" == "PDM" ]]; then
        echo "pdm run start"
      else echo "python -m project_name # After activating venv"; fi
      echo "\`\`\`"
    else
      echo "Specific build instructions are not defined. Refer to language-specific tools."
    fi

    echo ""
    echo "### Testing and Quality Checks"
    echo "Manually run quality checks using the native tools:"
    echo "\`\`\`bash"
    echo "# Example: Run Ruff/Pre-commit"
    echo "pre-commit run --all-files"
    echo "# Example: Run tests"
    echo "pytest"
    echo "\`\`\`"
  fi
  echo ""

  # --- SECTION 4: RECOMMENDATIONS ---
  if [[ ${#RECOMMENDATIONS[@]} -gt 0 ]]; then
    echo "## 4. Recommendations"
    echo "Based on the project analysis, here are some suggestions:"
    echo ""
    for rec in "${RECOMMENDATIONS[@]}"; do
      echo "* $rec"
    done
    echo ""
  fi
}

# ===============================================================
# D. MAIN ENTRY POINT
# ===============================================================
main() {
  # 1. Parse CLI arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
      usage
      exit 0
      ;;
    -v | --version)
      version
      exit 0
      ;;
    --debug)
      set -x
      shift
      ;;
    -*) error "Unknown option: $1. Use -h for help." ;;
    *)
      PROJECT_DIR="$1"
      shift
      ;; # Positional argument is directory
    esac
  done

  # 2. Navigate to project directory
  if [[ "$PROJECT_DIR" != "." ]]; then
    cd "$PROJECT_DIR" || error "Directory not found: $PROJECT_DIR"
    echo "Navigating to project directory: $PROJECT_DIR" >&2
  fi

  # 3. Create output directory if it doesn't exist
  mkdir -p "$OUTPUT_DIR" || error "Failed to create output directory: $OUTPUT_DIR"

  # 4. Perform analysis
  echo "Starting project analysis..." >&2
  project_analysis

  # 5. Generate the main guide file
  local devguide_path="$OUTPUT_DIR/$TARGET_GUIDE_NAME"
  echo "Generating final guide: $devguide_path..." >&2

  # Redirect stdout from generate_guide to the target file
  generate_guide >"$devguide_path"

  echo "✅ Dev Guide generation complete."
}

# Run the main function
main "$@"

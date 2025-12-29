# 🚀 Developer Guide: jm-dev-tools

This guide provides instructions for setting up the project and running common tasks (build, test, quality checks).

---

## 1. Project Overview & Stack

The primary technologies detected in this repository are: **Node.js/JavaScript,Python**.

> ⚠️ **Polyglot Project:** This repository contains both Python and Node.js components. Ensure both environments are set up correctly.

## 2. Environment Setup

This section outlines the steps to prepare your local environment.

### 2.1 Task Runner Setup (Recommended)

This project uses **Task** (`Taskfile.yml`) to manage all common tasks. This is the simplest method for full project setup.

To set up the entire environment (including dependencies, hooks, and venv creation):

```bash
task reset
```

### 3. Node.js Setup

Install Node.js dependencies using the detected package manager, **pnpm** (assumed for tooling).

```bash
pnpm install
```

### 4. Python Setup

This project uses **Standard Python environment** for environment management.

```bash
pip install -r requirements.txt # Install dependencies
source .venv/bin/activate # (If using standard venv)
```

## 3. Core Workflow (Build, Run, Quality)

All core operations are managed via **Task** to maintain consistency across languages (Python, Rust, C++ templates).

### Universal Commands (Using `LANG`)

These commands work universally across different language components in the repository:

```bash
task build LANG=python   # Or LANG=rust, LANG=cpp
task run LANG=python     # Executes the built application
task clean               # Removes all build artifacts, caches, and translations
```

### Quality Assurance

The quality commands execute all necessary linters, formatters, and tests:

```bash
task format              # Automatically formats all code and documentation
task lint                # Runs all quality checks (Ruff, Taplo, etc.)
task test                # Executes the test suite (pytest/other)
```

For the complete list of tasks, including documentation, translations, and maintenance, run:

```bash
task -l
```

## 4. Recommendations

Based on the project analysis, here are some suggestions:

- Taskfile.yml found: Prioritize 'task [command]' for all project operations.

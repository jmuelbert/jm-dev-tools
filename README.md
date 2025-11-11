# jm-dev-tools: Reusable Development & Automation Scripts 🛠️

[![Hatch][hatch-badge]][hatch]
[![pre-commit][pre-commit-badge]][pre-commit]
[![License][license-badge]][EUPL V1.2 license]

This repository contains reusable Bash (`.sh`) and PowerShell (`.ps1`) scripts designed to streamline common development, documentation, and maintenance tasks across various projects (e.g., jm-bde-python). These scripts enforce standards, automate repetitive processes, and ensure consistency.

## 📦 Project Structure

The core automation logic is housed in the `scripts/` directory:

| Script                          | Type       | Description                                                                                                                |
| :------------------------------ | :--------- | :------------------------------------------------------------------------------------------------------------------------- |
| `devguide-generator.sh`         | Bash       | **Linux/macOS:** Core script for generating technical documentation and references, potentially using tools like Shellman. |
| `Invoke-DevGuideGeneration.ps1` | PowerShell | **Windows:** The equivalent script for generating documentation references, typically leveraging PlatyPS.                  |

## ✨ Usage & Integration

Since this repository serves as a utility collection, it is not installed as a typical dependency. Instead, the scripts are called directly via command-line or integrated into a parent project's CI/CD pipelines.

### Prerequisites

1.  **Hatch & uv:** Ensure you have [Hatch] installed for environment management and [uv] configured as the installer (as defined in `pyproject.toml`).
2.  **Dependencies:** Install the project's development tools (Shellman, MkDocs, etc.) using the Hatch environment:

    ```bash
    hatch env create dev
    ```

### Running Scripts

Scripts are executed via the convenient aliases defined in `pyproject.toml` using `hatch run`:

| Action              | Command                  | Description                                                                                                             |
| :------------------ | :----------------------- | :---------------------------------------------------------------------------------------------------------------------- |
| **Generate Docs**   | `hatch run devguide:gen` | Executes the appropriate OS-specific script (`devguide-generator.sh` or equivalent) to update documentation references. |
| **Build Docs Site** | `hatch run docs:build`   | Builds the full documentation website using the installed MkDocs environment.                                           |

## 🛠️ Tooling & Quality Assurance

This project utilizes a modern toolchain to ensure code quality and script reliability:

| Tool                                          | Purpose                                                 | Status                                                                                   |
| :-------------------------------------------- | :------------------------------------------------------ | :--------------------------------------------------------------------------------------- |
| [![Hatch][hatch-badge]][hatch]                | Project & Environment Manager (using `uv` as installer) | Used for all development environments.                                                   |
| [![pre-commit][pre-commit-badge]][pre-commit] | Automated Git Hook Runner                               | Ensures all scripts, config files, and documentation are linted/formatted before commit. |
| [![Shellcheck][shellcheck-badge]][shellcheck] | Bash Static Analysis                                    | Catches bugs and warnings in the `.sh` files.                                            |
| [![cSpell][cspell-badge]][cspell]             | Spell Checker                                           | Ensures consistency in comments, documentation, and configuration files.                 |
| `PlatyPS`                                     | PowerShell Documentation Generation                     | Used for generating Markdown reference docs from `.ps1` files.                           |
| `Shellman`                                    | Bash Documentation Generation                           | Used for generating Markdown reference docs from `.sh` files.                            |

## 🚀 Development & Contribution

### Setup

Clone the repository and install the development environment:

```bash
git clone <your-repo-url>
cd jm-dev-tools
hatch env create dev
pre-commit install
```

# jm dev tools

[![MegaLinter Status][wf-megalinter-badge]][wf-megalinter][![License][License-badge]][EUPL V1.2 license]

jm-dev-tools is a powerful set of scripts that generate a deveoloper guide. This
guide provides instructions for setting up the project and running common tasks
(build, test, quality checks).

## ✨ Key Features & Value

- **Project Overview & Stack:** Detect the project language and check main
  options.
- **Task Runner Setup (Recommended):** Detect a Taskfile.yml. If that not there
  give out a recommentation.

## 🚀 Installation

Install the script(s) whereever you want.

## 💡 Quick Start & Usage

To get started, explore the command line interface options:

```bash
  # View available commands and global options
  bash devguide-generator.sh --help
```

🛠️ Development & ToolingThis project uses the following tools for quality
assurance, CI/CD, and maintainability:

| Tooling / Quality | CI / Automation |
|:------------------|:----------------|
| [![uv][uv-badge]][uv] | [![MegaLinter][wf-megalinter-badge]][wf-megalinter] |
| [![cSpell][cspell-badge]][cspell] | [![Codacy][wf-codacy-ql-badge]][wf-codacy-ql] |
| [![ESLint][eslint-badge]][eslint] | [![OpenSSF Scorecard][wf-scorecard-badge]][wf-scorecard] |
| [![Prettier][Prettier-badge]][Prettier] | [![Dependabot Auto Merge][wf-dependabot-merge-badge]][wf-dependabot-merge] |
| | [![Pull Request Automation][wf-pr-automation-badge]][wf-pr-automation] |
| | [![Repository Maintenance][wf-maintenance-badge]][wf-maintenance] |
| | [![Documentation Deployment][wf-docs-deploy-badge]][wf-docs-deploy] |

## 📘 Further Information

- **Documentation:** For a deep dive into configuration and advanced usage,
  please refer to our [documentation].
- **Contributing:** We welcome contributions! Please read our [contributing
  guidelines] for more information.
- **License:** This project is licensed under the [EUPL V1.2 license].

<!-- MARKDOWN LINKS & IMAGES -->

<!-- Workflow Badges -->

[wf-codacy-ql]:
  https://github.com/jmuelbert/jm-dev-tools/actions/workflows/codacy.yml
[wf-codacy-ql-badge]:
  https://github.com/jmuelbert/jm-dev-tools/actions/workflows/codacy.yml/badge.svg
[wf-docs-deploy]:
  https://github.com/jmuelbert/jm-dev-tools/actions/workflows/docs-deploy.yml
[wf-docs-deploy-badge]:
  https://github.com/jmuelbert/jm-dev-tools/actions/workflows/docs-deploy.yml/badge.svg
[wf-dependabot-merge]:
  https://github.com/jmuelbert/jm-dev-tools/actions/workflows/dependabot-merge.yml
[wf-dependabot-merge-badge]:
  https://github.com/jmuelbert/jm-dev-tools/actions/workflows/dependabot-merge.yml/badge.svg
[wf-megalinter]: https://github.com/jmuelbert/jm-bde-python/actions/workflows/megalinter.yml
[wf-megalinter-badge]: https://github.com/jmuelbert/jm-bde-python/actions/workflows/megalinter.yml/badge.svg
[wf-maintenance]:
  https://github.com/jmuelbert/jm-dev-tools/actions/workflows/maintenance.yml
[wf-maintenance-badge]:
  https://github.com/jmuelbert/jm-dev-tools/actions/workflows/maintenance.yml/badge.svg
[wf-pr-automation]:
  https://github.com/jmuelbert/jm-dev-tools/actions/workflows/pr-automation.yml
[wf-pr-automation-badge]:
  https://github.com/jmuelbert/jm-dev-tools/actions/workflows/pr-automation.yml/badge.svg
[wf-scorecard]:
  https://scorecard.dev/viewer/?uri=github.com/jmuelbert/jm-dev-tools
[wf-scorecard-badge]:
  https://api.scorecard.dev/projects/github.com/jmuelbert/jm-dev-tools/badge

<!-- Project Links & Badges -->

[EUPL V1.2 license]: https://github.com/jmuelbert/jm-dev-tools/blob/main/LICENSE
[license-badge]: https://img.shields.io/badge/License-EUPL%201.2-blue.svg

<!-- Tooling Badges -->

<!-- Project Docs -->

[contributing guidelines]:
  https://jmuelbert.github.io/jm-dev-tools/community/contributing
[documentation]: https://jmuelbert.github.io/jm-dev-tools/

 <!--- External -->

[cspell]: https://cspell.org/
[cspell-badge]: https://img.shields.io/badge/cSpell-checked-blue?logo=cspell
[eslint]: https://eslint.org
[eslint-badge]: https://img.shields.io/badge/ESLint-3A33D1?logo=eslint
[prettier]: https://prettier.io
[prettier-badge]:
  https://img.shields.io/badge/prettier-3.x-brightgreen?logo=prettier
[uv-badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2FOnyx-Nostalgia%2Fuv%2Frefs%2Fheads%2Ffix%2Flogo-badge%2Fassets%2Fbadge%2Fv0.json
[uv]:https://github.com/astral-sh/uv

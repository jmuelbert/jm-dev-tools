# Contributing to jm-dev-tools

First off, thank you for considering contributing to **jm-dev-tools**! 🎉

We welcome contributions of all kinds — code, documentation, testing,
translations, and ideas.

This guide will walk you through the process.

---

## 📜 Code of Conduct

This project follows the
[Contributor Covenant Code of Conduct v3.0](https://www.contributor-covenant.org/version/3/0/code_of_conduct/).
By participating, you are expected to uphold this code. Please report
unacceptable behavior to the maintainers.

---

## 🚀 Getting Started

### 1. Fork & Clone

Fork the repository via GitHub and clone your fork locally:

```bash
git clone https://github.com/your-username/jm-dev-tools.git
cd jm-dev-tools
```

### Development Environment

We use [Hatch](https://hatch.pypa.io/latest/) for environment and project
management.

Enter the development environment with:

```bash
hatch shell
```

Run the tests to verify everything works:

```bash
   hatch test
```

or

```bash
   hatch run test:test
```

### Optional: Using `Task`

If you have [`task`](https://taskfile.dev/) installed, you can simplify common
commands:

```bash
task test
task translate-source
```

### Documentation

Documentation is built with [MkDocs](https://www.mkdocs.org/). Preview locally
with:

```bash
   hatch run docs:serve
```

## ✅ How to Contribute

### Reporting Bugs 🐛

- Use the GitHub Issues page.
- Include details:
  - Steps to reproduce
  - Expected behavior
  - Actual behavior
  - Environment (OS, Python version, dependencies)

### Suggesting Features 💡

- Open a Feature Request issue.
- Explain the problem, proposed solution, and alternatives considered.

### Submitting Changes 📝

1. **Fork the repository.**

1. **Create a new branch.**

   Use a clear, descriptive name for your branch.

   ```bash
       git checkout -b feature/your-feature-name
   ```

1. **Make your changes.**

1. **Ensure all tests pass.**

   Run the test suite to confirm your changes haven't introduced any bugs.

   ```bash
     hatch test
   ```

1. **Run linting and formatting.**

   This ensures your code meets the project's quality standards.

   ```bash
     hatch lint:check-all
   ```

1. **Commit your changes.**

   This helps maintain a clean and descriptive commit history. Using
   [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

   ```sql
     feat: add new feature
     fix: fix bug or correct some handling
     docs: update documentation
   ```

1. **Push your branch and open a Pull Request.**

   Push your changes to your fork and then open a pull request against the main
   repository

## 📖 Coding Standards

- **Python 3.11+ only**
- Follow [PEP 8](https://peps.python.org/pep-0008/) with additional style
  enforced by [Ruff](https://docs.astral.sh/ruff/)
- Use [type hints](https://docs.python.org/3/library/typing.html) everywhere
- Write **docstrings** in
  [Google style](https://google.github.io/styleguide/pyguide.html#38-comments-and-docstrings)
- Keep functions small and focused
- Add or update tests for all changes

## 🧪 Testing

We use [pytest](https://docs.pytest.org/en/latest/) and
[pytest-mock](https://pypi.org/project/pytest-mock/). Run tests:

```bash
   hatch test
```

Run a specific test file:

```bash
   hatch shell test.py3.13
   hatch run pytest tests/test_my_feature.py
```

Run with coverage:

```bash
   hatch run test:coverage
```

## 🌍 Translations

jm-dev-tools supports internationalization (i18n) for both Python and Qt
components. If you’d like to contribute translations, please follow the steps
below.

### Update Babel (.po) Translations (Python)

1. **Extract and update translation strings for all languages:**

   ```bash
     task extract-translations
   ```

1. **Edit the generated `.po` files under
   `src/jm-dev-tools/locales/<lang>/LC_MESSAGES/`**

1. **Compile the translations (optional, usually handled by task):**

   ```bash
     task compile-translations
   ```

### Update Qt Translations (.ts/.qm)

1. **Update Qt .ts and .qm files for GUI components:**

   ```bash
       task extract-qt-translations
   ```

1. **Edit the generated .ts files under src/jm-dev-tools/gui/translations/.**

1. **Compile resources (handled automatically by translate-qt):**

   ```bash
       task compile-translations
   ```

## 📦 Releases (Maintainers only)

Releases are managed with Hatch.

1. **Update the version:**

   ```bash
      hatch version minor
   ```

1. **Commit with chore: `release vX.Y.Z`**

1. **Create a GitHub release and tag**

1. **Publish with:**

   ```bash
   hatch build
   hatch publish
   ```

---

## 📄 License

Contributions to this project are licensed under the
[EUPL-1.2](https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12).

---

## 🙏 Thank You

Your contributions make **jm-dev-tools** better for everyone. We truly
appreciate your time, effort, and ideas 💙

[tool.hatch.envs.dev.scripts] check = "ruff check ." fix = "ruff check . --fix"
format = "ruff format ." format_all = ["ruff check . --fix", "ruff format .",
"taplo format"] lint = "ruff check ." lint_all = [ "ruff check .", "pyright",
"reuse lint", "pre-commit run --all-files", ] precommit = ["pre-commit {args}"]
typecheck = "pyright" typing = ["pyright {args}"]

[tool.hatch.envs.docs.scripts] build = [ "mkdocs build --clean --strict {args}",
"python -m json.tool --sort-keys --no-indent ./site/search/search_index.json
./site/search/search_index.json", ] qualitycheck = "doc-quality-check" serve =
"mkdocs serve --dev-addr localhost:8090 {args}"

"scripts": { "lint:toml": "taplo check", "format:toml": "taplo format",
"lint:prettier": "prettier --check '**/\*.{md,mdx,yaml}'", "format:prettier":
"prettier --write '**/_.{md,mdx,yaml}'", "lint:spell": "cspell --no-progress",
"lint:markdown": "markdownlint --ignore node_modules --ignore .pytest_cache
--ignore .venv --dot --config .markdownlint.json
'\*\*/_.{md,markdown,mdx,adoc,asciidoc}'", "format:markdown": "markdownlint
--ignore node\*modules --ignore .pytest*cache --ignore .venv --dot --fix
--config .markdownlint.json '\*\*/*.{md,markdown,mdx,adoc,asciidoc}'",
"lint:links": "find . \\( -name '_.md' -o -name '_.markdown' -o -name '_.mdx' -o
-name '_.adoc' -o -name '\_.asciidoc' \\) -not -path './node*modules/*' -not
-path './.venv/\*' -print0 | xargs -0 -n1 markdown-link-check -q -p --config
.markdown-link-check.json", "lint:js-json": "biome check ./", "format:js-json":
"biome format --write ./", "lint:docs": "pnpm run lint:prettier && pnpm run
lint:markdown && pnpm run lint:links && pnpm run lint:spell && pnpm run
lint:vale", "lint:vale": "vale README.md SECURITY.md docs", "lint": "pnpm run
lint:js-json && pnpm run lint:toml && pnpm run lint:prettier && pnpm run
lint:markdown && pnpm run lint:links && pnpm run lint:spell && pnpm run
lint:vale", "format": "pnpm run format:js-json && pnpm run format:toml && pnpm
run format:prettier && pnpm run format:markdown", "cspell:project-words": "echo
'# New Words' >> project-words.txt && cspell --words-only --unique | sort
--ignore-case >> project-words.txt", "cspell:suggests": "cspell --no-progress
--show-suggestions --show-context" },

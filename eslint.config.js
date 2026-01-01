// eslint.config.js
import globals from 'globals'
import js from '@eslint/js'
import pluginJsxA11y from 'eslint-plugin-jsx-a11y'
import pluginImport from 'eslint-plugin-import'
import pluginPrettier from 'eslint-plugin-prettier'

export default [
	js.configs.recommended,
	{
		files: ['**/*.{js,jsx,ts,tsx}'],
		languageOptions: {
			ecmaVersion: 'latest',
			sourceType: 'module',
			globals: globals.browser,
		},
		plugins: {
			'jsx-a11y': pluginJsxA11y,
			import: pluginImport,
			prettier: pluginPrettier,
		},
		rules: {
			...pluginPrettier.configs.recommended.rules, // ✅ enable Prettier rules
		},
		settings: {
			react: { version: 'detect' },
		},
	},
	{
		ignores: ['.venv/**'],
	},
]

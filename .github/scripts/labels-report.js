// SPDX-License-Identifier: EUPL-1.2
// SPDX-FileCopyrightText: 2025-present Jürgen Mülbert <juergen.muelbert@outlook.de>

const fs = require("node:fs");
const yaml = require("yaml");

export default async ({ github, context, core }) => {
	try {
		// Load configurations
		const labelConfig = yaml.parse(
			fs.readFileSync(".github/config/labels.yml", "utf8"),
		);
		const labelerConfig = yaml.parse(
			fs.readFileSync(".github/config/labeler.yml", "utf8"),
		);

		let summary = `### 🏷️ Label Sync Report\n\n`;

		// Analyze configurations
		const labelNames = new Set(labelConfig.map((l) => l.name));
		const labelerRules = new Set(Object.keys(labelerConfig));

		// Find mismatches
		const missingLabels = [...labelerRules].filter((r) => !labelNames.has(r));
		const unusedLabels = [...labelNames].filter((l) => !labelerRules.has(l));

		// Generate statistics
		summary += `### Statistics\n`;
		summary += `- Total Labels: ${labelNames.size}\n`;
		summary += `- Total Labeler Rules: ${labelerRules.size}\n`;
		summary += `- Missing Labels: ${missingLabels.length}\n`;
		summary += `- Unused Labels: ${unusedLabels.length}\n\n`;

		if (missingLabels.length > 0) {
			summary += `### ⚠️ Missing Labels\n`;
			missingLabels.forEach((label) => {
				summary += `- \`${label}\`: Used in labeler but not defined\n`;
			});
			summary += `\n`;
		}

		if (unusedLabels.length > 0) {
			summary += `### ℹ️ Unused Labels\n`;
			unusedLabels.forEach((label) => {
				summary += `- \`${label}\`: Defined but not used in labeler\n`;
			});
			summary += `\n`;
		}

		// Create issue if there are problems
		if (missingLabels.length > 0) {
			await github.rest.issues.create({
				...context.repo,
				title: "🏷️ Label Configuration Needs Attention",
				body: summary,
				labels: ["automation", "documentation"],
			});
		}

		// Add report to workflow summary
		await core.summary.addHeading("Label Sync Results").addRaw(summary).write();
	} catch (error) {
		core.setFailed(`Label sync report failed: ${error.message}`);
		console.error(error);
	}
};

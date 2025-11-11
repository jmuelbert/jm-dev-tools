// SPDX-License-Identifier: EUPL-1.2
// SPDX-FileCopyrightText: 2025-present Jürgen Mülbert <juergen.muelbert@outlook.de>

// biome-ignore lint/correctness :noUnusedParameters
export default async ({ github, context, core }) => {
	const outputs = {
		dependencyChanges: JSON.parse(process.env.DEPENDENCY_CHANGES || "[]"),
		vulnerableChanges: JSON.parse(process.env.VULNERABLE_CHANGES || "[]"),
		licenseChanges: JSON.parse(process.env.LICENSE_CHANGES || "[]"),
		deniedChanges: JSON.parse(process.env.DENIED_CHANGES || "[]"),
	};

	let report = "## 📋 Pull Request Dependency Review Report\n\n";

	report += `### 📑 Summary\n`;
	report += `- Total Changes: ${outputs.dependencyChanges.length}\n`;
	report += `- Vulnerable Changes: ${outputs.vulnerableChanges.length}\n`;
	report += `- License Issues: ${outputs.licenseChanges.length}\n`;
	report += `- Denied Changes: ${outputs.deniedChanges.length}\n\n`;

	if (outputs.vulnerableChanges.length > 0) {
		report += "### ⚠️ Vulnerable Changes\n\n";
		outputs.vulnerableChanges.forEach((change) => {
			report += `- **${change.package.name}@${change.package.version}**: ${change.advisory.title}\n`;
			report += `  - Severity: ${change.advisory.severity}\n`;
			report += `  - Advisory: [${change.advisory.url}](${change.advisory.url})\n\n`;
		});
	} else {
		report += "### ✅ No Vulnerable Changes Found\n\n";
	}

	if (outputs.licenseChanges.length > 0) {
		report += "### 🚫 License Issues\n\n";
		outputs.licenseChanges.forEach((change) => {
			report += `- **${change.package.name}@${change.package.version}**: ${change.license}\n`;
			report += `  - Allowed Licenses: ${change.allowedLicenses.join(", ")}\n\n`;
		});
	} else {
		report += "### ✅ No License Issues Found\n\n";
	}

	if (outputs.deniedChanges.length > 0) {
		report += "### ❌ Denied Changes\n\n";
		outputs.deniedChanges.forEach((change) => {
			report += `- **${change.package.name}@${change.package.version}**: ${change.reason}\n`;
		});
	} else {
		report += "### ✅ No Denied Changes Found\n\n";
	}

	if (context.payload.pull_request) {
		try {
			await github.rest.issues.createComment({
				owner: context.repo.owner,
				repo: context.repo.repo,
				issue_number: context.payload.pull_request.number,
				body: report,
			});
		} catch (error) {
			console.error("Failed to create comment:", error);
		}
	} else {
		console.log("Not a pull request, skipping comment creation.");
	}
};

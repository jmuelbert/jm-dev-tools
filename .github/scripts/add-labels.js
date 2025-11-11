// SPDX-License-Identifier: EUPL-1.2
// SPDX-FileCopyrightText: 2025-present Jürgen Mülbert <juergen.muelbert@outlook.de>

export default async ({ github, context, core }) => {
	try {
		const dependencyType = process.env.DEPENDENCY_TYPE;
		const updateType = process.env.UPDATE_TYPE;
		const alertState = process.env.ALERT_STATE;

		const labels = [];

		// Add dependency type label
		if (dependencyType === "direct:production") {
			labels.push("production-dependency");
		} else {
			labels.push("development-dependency");
		}

		// Add update type label
		if (updateType.includes("version-update:semver-patch")) {
			labels.push("patch-update");
		} else if (updateType.includes("version-update:semver-minor")) {
			labels.push("minor-update");
		} else if (updateType.includes("version-update:semver-major")) {
			labels.push("major-update");
		}

		// Add security label if needed
		if (alertState === "fixed") {
			labels.push("security");
		}

		const pr = context.payload.pull_request;
		if (!pr) {
			throw new Error(
				"This workflow must be triggered by a pull request event.",
			);
		}

		// Add labels to PR
		await github.rest.issues.addLabels({
			owner: context.repo.owner,
			repo: context.repo.repo,
			issue_number: context.payload.pull_request.number,
			labels: labels,
		});

		console.log("Labels added successfully:", labels);
	} catch (error) {
		console.error("Failed to add labels:", error.message);
		core.setFailed(error.message);
	}
};

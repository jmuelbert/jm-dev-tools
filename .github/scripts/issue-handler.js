// SPDX-License-Identifier: EUPL-1.2
// SPDX-FileCopyrightText: 2025-present Jürgen Mülbert <juergen.muelbert@outlook.de>

import { readFile } from "node:fs/promises";
import { join } from "node:path";

const getJSONConfig = async (path, filename) => {
	const filePath = join(process.env.GITHUB_WORKSPACE || ".", path, filename);
	const content = await readFile(filePath, "utf-8");
	return JSON.parse(content);
};

export default async ({ github, context, core }) => {
	try {
		const config = await getJSONConfig("config", "issue-triage.json");

		const issue = context.payload.issue;
		if (!issue) return;

		// --- Triage Logic ---
		const labels = new Set();
		const title = issue.title.toLowerCase();
		const body = issue.body?.toLowerCase() || "";

		// Process type labels from config
		Object.entries(config.labels.types).forEach(([prefix, typeLabels]) => {
			if (title.startsWith(prefix.toLowerCase())) {
				typeLabels.forEach((label) => {
					labels.add(label);
				});
			}
		});

		// Process trigger labels
		Object.entries(config.labels.triggers).forEach(
			([trigger, triggerLabels]) => {
				if (body.includes(trigger.toLowerCase())) {
					triggerLabels.forEach((label) => {
						labels.add(label);
					});
				}
			},
		);

		// Add size label
		const length = body.length;
		if (length > config.labels.sizes.medium) {
			labels.add("size/large");
		} else if (length > config.labels.sizes.small) {
			labels.add("size/medium");
		} else {
			labels.add("size/small");
		}

		if (labels.size > 0) {
			await github.rest.issues.addLabels({
				...context.repo,
				issue_number: issue.number,
				labels: Array.from(labels),
			});
		}
	} catch (error) {
		core.setFailed(`Workflow failed: ${error.message}`);
		console.error(error);
	}
};

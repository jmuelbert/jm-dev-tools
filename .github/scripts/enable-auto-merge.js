// SPDX-License-Identifier: EUPL-1.2
// SPDX-FileCopyrightText: 2025-present Jürgen Mülbert <juergen.muelbert@outlook.de>

// This script merges a pull request with a squash method and handles the output.
export default async ({ github, context, core }) => {
	try {
		await github.rest.pulls.merge({
			owner: context.repo.owner,
			repo: context.repo.repo,
			pull_number: context.issue.number,
			merge_method: "squash",
			commit_title: `chore(deps): ${context.payload.pull_request.title}`,
			commit_message: "Auto-merged by Dependabot 🤖",
		});
		core.setOutput("merged", "true");
	} catch (error) {
		console.log(`Failed to merge: ${error.message}`);
		core.setOutput("merged", "false");
	}
};

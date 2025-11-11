// SPDX-License-Identifier: EUPL-1.2
// SPDX-FileCopyrightText: 2025-present Jürgen Mülbert <juergen.muelbert@outlook.de>

// biome-ignore lint/correctness :noUnusedParameters
export default async ({ github, context, core }) => {
	const pr = context.payload.pull_request;
	if (!pr) {
		console.log("Not a pull request event. Exiting.");
		return;
	}

	const labels = new Set(pr.labels.map((l) => l.name));
	const minCoverage = process.env.MIN_COVERAGE;

	// --- Labeling based on title and body ---
	// Enhanced title parsing with regex
	const titlePattern =
		/^(fix|feat|docs|test|chore|refactor|style|perf)(?:\(.*\))?:/;
	const match = pr.title.match(titlePattern);
	if (match) {
		labels.add(`type-${match[1]}`);
	}

	// Check PR body for specific keywords and contexts
	const body = pr.body?.toLowerCase() || "";
	const checks = {
		"security-label": [
			"security",
			"vulnerability",
			"cve",
			"auth",
			"authentication",
		],
		"performance-label": ["performance", "optimize", "speed", "perf"],
		"documentation-label": ["documentation", "docs", "readme"],
		"dependencies-label": ["dependency", "dependencies", "deps"],
		"breaking-label": ["breaking change", "breaking-change"],
		"deprecation-label": ["deprecate", "deprecated"],
	};

	Object.entries(checks).forEach(([label, keywords]) => {
		if (keywords.some((keyword) => body.includes(keyword))) {
			labels.add(label);
		}
	});

	// Add draft or ready-for-review labels
	if (pr.draft) {
		labels.add("status: work-in-progress");
		// Also remove the "ready-for-review" label if it's a draft
		labels.delete("status: ready-for-review");
	} else {
		labels.add("status: ready-for-review");
		// Also remove the "work-in-progress" label if it's not a draft
		labels.delete("status: work-in-progress");
	}

	// Apply labels
	if (labels.size > 0) {
		try {
			await github.rest.issues.setLabels({
				owner: context.repo.owner,
				repo: context.repo.repo,
				issue_number: pr.number,
				labels: Array.from(labels),
			});
		} catch (error) {
			console.error("Failed to set labels:", error);
		}
	}

	// --- Add a review checklist as a comment for new PRs ---
	if (context.payload.action === "opened") {
		const checklist = `
## PR Review Checklist

### 🎯 Prerequisites
- [ ] PR title follows [Conventional Commits](https://www.conventionalcommits.org/)
- [ ] Branch is up to date with target branch
- [ ] All automated checks are passing

### 📝 Documentation
- [ ] Documentation updated
- [ ] API changes documented
- [ ] Change log updated
- [ ] Inline comments added for complex code

### 🧪 Testing
- [ ] Unit tests added/updated
- [ ] Integration tests if needed
- [ ] All tests passing
- [ ] Coverage meets minimum threshold (${minCoverage}%)
- [ ] Edge cases tested

### 💻 Code Quality
- [ ] Code follows style guide
- [ ] No debug/commented code
- [ ] Error handling implemented
- [ ] Performance considerations addressed
- [ ] Code is modular and maintainable

### 🔒 Security
- [ ] Security best practices followed
- [ ] Dependencies are up to date
- [ ] No sensitive data exposed
- [ ] Input validation implemented
- [ ] Security implications considered

### 🚀 Deployment
- [ ] Migration scripts if needed
- [ ] Environment variables documented
- [ ] Deployment documentation updated
- [ ] Rollback plan considered
`;
		// We'll create a single comment with all the info to avoid spam
		// The "..." represents the rest of your original checklist content

		await github.rest.issues.createComment({
			owner: context.repo.owner,
			repo: context.repo.repo,
			issue_number: pr.number,
			body: checklist,
		});
	}

	// You can also add the dependency report logic here if you want to consolidate it further,
	// by getting the output from the previous steps.
	// For example, from the 'dependency-review' step.
};

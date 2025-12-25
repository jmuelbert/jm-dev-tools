// SPDX-License-Identifier: EUPL-1.2
// SPDX-FileCopyrightText: 2025-present Jürgen Mülbert <juergen.muelbert@gmail.de>

export default async ({ github, context, core, dep_type, update_type, alert_state }) => {
	try {
		const dependencyType = dep_type
		const updateType = update_type
		const alertState = alert_state

		const labels = []

		// Add dependency type label
		if (dependencyType === 'direct:production') {
			labels.push('production-dependency')
		} else {
			labels.push('development-dependency')
		}

		// Add update type label
		if (updateType.includes('version-update:semver-patch')) {
			labels.push('patch-update')
		} else if (updateType.includes('version-update:semver-minor')) {
			labels.push('minor-update')
		} else if (updateType.includes('version-update:semver-major')) {
			labels.push('major-update')
		}

		// Add security label if needed
		if (alertState === 'fixed') {
			labels.push('security')
		}

		const pr = context.payload.pull_request
		if (!pr) {
			throw new Error('This workflow must be triggered by a pull request event.')
		}

		// Add labels to PR
		await github.rest.issues.addLabels({
			owner: context.repo.owner,
			repo: context.repo.repo,
			issue_number: context.payload.pull_request.number,
			labels: labels,
		})

		console.log('Labels added successfully:', labels)
	} catch (error) {
		console.error('Failed to add labels:', error.message)
		core.setFailed(error.message)
	}
}

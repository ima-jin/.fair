# RFC-01: Commit-Based Attribution

**Status**: Draft
**Author**: Imajin Team
**Created**: 2026-03-02
**Updated**: 2026-03-02

## Abstract

This RFC proposes a mechanism for automatically generating `.fair` attribution manifests from git commit history. Pull requests serve as attribution boundaries, and contributor weights are derived from commit activity within each PR.

## Motivation

Manual creation of `.fair` manifests is error-prone and doesn't scale for large projects with many contributors. Git already contains rich attribution data in commit history. By extracting this data programmatically, we can:

1. **Automate attribution** — Reduce manual overhead
2. **Maintain accuracy** — Attribution reflects actual contribution patterns
3. **Enable versioning** — Attribution evolves with the codebase
4. **Support auditing** — Transparent, verifiable attribution chains

## Proposal

### Attribution Boundary: Pull Request

Each merged pull request generates a `.fair` manifest representing the work in that PR. This provides:

- Clear scope boundaries
- Review/approval workflow integration
- Metadata (title, description, timestamps)
- Atomic units of contribution

### Generating Contributor Objects

For each commit in a PR:

1. Extract author identity from `git log` (name, email, GPG key)
2. Map to DID if available (via `.git/fair/did-mapping.json` or similar)
3. Aggregate commit count per contributor
4. Generate role based on file patterns or manual annotation

### Example: Simple PR

**PR #42**: "Add user authentication"

**Commits**:
- 8 commits by alice@example.com
- 3 commits by bob@example.com

**Generated manifest**:
```json
{
  "id": "github:ima-jin/myproject:pr:42",
  "type": "project",
  "title": "Add user authentication",
  "version": "0.2.0",
  "contributors": [
    {
      "id": "did:imajin:alice",
      "role": "engineer",
      "weight": 0.73,
      "notes": "8 commits"
    },
    {
      "id": "did:imajin:bob",
      "role": "engineer",
      "weight": 0.27,
      "notes": "3 commits"
    }
  ],
  "context": {
    "source": "git",
    "sourceId": "pr-42",
    "derivedFrom": [
      {
        "type": "github-pr",
        "id": "https://github.com/ima-jin/myproject/pull/42",
        "timestamp": "2026-02-15T10:30:00Z"
      }
    ]
  },
  "metadata": {
    "repository": "github:ima-jin/myproject",
    "branch": "main",
    "commits": 11,
    "linesAdded": 450,
    "linesDeleted": 120
  }
}
```

## The Weight Problem (UNSOLVED)

**Commit count is a naive heuristic.** It doesn't account for:

- **Code quality** — 10 commits fixing bugs vs. 1 commit with a breakthrough insight
- **Review effort** — Code reviewers contribute value but don't commit
- **Non-code work** — Documentation, design, testing, infrastructure
- **Seniority/mentorship** — Experienced developers guiding junior contributors
- **Time-to-value** — Delayed impact of foundational work

### Potential Approaches (None Standardized)

1. **Lines of code** — Weighted by additions/deletions (still naive)
2. **File-based weighting** — Critical files (e.g., core logic) weighted higher
3. **Manual adjustment** — Contributors negotiate splits per PR
4. **Algorithmic blend** — Combine multiple signals (commits, LOC, review comments, time-in-PR)
5. **Reputation-weighted** — Trust graph scores influence base weights
6. **ML-based** — Train model on historical contribution patterns (requires labeled data)

**Current status**: This is an **unsolved research problem**. Implementations should:
- Default to simple heuristics (commit count)
- Allow manual override
- Document weighting methodology in manifest metadata
- Iterate based on community feedback

## Implementation Workflow

### 1. PR Merge Trigger

When a PR is merged:

```bash
# Git hook or CI action
git fair generate --pr 42 --output .fair/pr-42.fair.json
```

### 2. DID Mapping

Maintain a mapping file:

```json
{
  "alice@example.com": "did:imajin:alice",
  "bob@example.com": "did:imajin:bob"
}
```

Or use GPG key fingerprints:

```json
{
  "gpg:1234ABCD": "did:key:z6Mk...",
  "gpg:5678EFGH": "did:imajin:bob"
}
```

### 3. Aggregation Across PRs

Project-level manifests aggregate across all PRs:

```bash
git fair aggregate --since v1.0.0 --output .fair/project.fair.json
```

This sums weights across all PRs in the range.

### 4. Review and Approval

Generated manifests should be:
- Committed to the repo (`.fair/` directory)
- Reviewed by contributors before merge
- Versioned alongside code

## Metadata Fields

PR-based manifests should include:

```json
{
  "metadata": {
    "repository": "github:owner/repo",
    "pr": {
      "number": 42,
      "url": "https://github.com/owner/repo/pull/42",
      "title": "Add user authentication",
      "author": "did:imajin:alice",
      "reviewers": ["did:imajin:bob", "did:imajin:carol"],
      "mergedAt": "2026-02-15T10:30:00Z",
      "mergedBy": "did:imajin:carol"
    },
    "git": {
      "commits": 11,
      "baseCommit": "abc123",
      "headCommit": "def456",
      "linesAdded": 450,
      "linesDeleted": 120,
      "filesChanged": 12
    }
  }
}
```

## Open Questions

1. **Review Attribution**
   - Should code reviewers receive attribution weight?
   - How much weight relative to commit authors?
   - Track review comments/suggestions as contributions?

2. **Cross-Repo Dependencies**
   - How to attribute work that depends on external libraries?
   - Should upstream dependencies receive attribution in downstream projects?

3. **Commit Squashing**
   - Many teams squash commits before merge — how to preserve fine-grained attribution?
   - Parse commit message trailers (`Co-authored-by`)?

4. **Forked Contributions**
   - How to attribute work from forks or external contributors?
   - DID mapping for one-time contributors?

5. **Time Decay**
   - Should older contributions decay in weight over time?
   - How to handle refactors that obsolete previous work?

## Prior Art

- **SPDX** — Software Package Data Exchange (licensing focus, not compensation)
- **GitHub Contributors API** — Commit-based contribution stats
- **GitCoin** — Bounty-based contribution tracking
- **SourceCred** — Graph-based contribution analysis (discontinued)
- **Tea Protocol** — Package-level attribution and rewards

## Security Considerations

- **Identity Spoofing** — Enforce GPG-signed commits for verified attribution
- **Commit Inflation** — Detect and penalize artificially inflated commit counts
- **Fork Manipulation** — Prevent attribution theft through repo forks
- **Historical Rewriting** — Detect `git rebase`/`amend` after manifest generation

## Migration Path

For existing projects without `.fair` manifests:

1. Generate retroactive manifests for past releases
2. Tag with `"context": {"source": "retroactive"}`
3. Invite contributors to review and adjust weights
4. Publish final manifests in repo

## Implementation Status

- [ ] CLI tool for manifest generation (`git fair`)
- [ ] GitHub Action for automated generation
- [ ] DID mapping service
- [ ] Weight adjustment UI
- [ ] Aggregation across release history

## References

- [.fair Specification v0.3](../spec/SPEC.md)
- [GitHub API: List commits on a pull request](https://docs.github.com/en/rest/pulls/pulls#list-commits-on-a-pull-request)
- [Git trailers for co-authorship](https://git-scm.com/docs/git-interpret-trailers)

## Changelog

- **2026-03-02**: Initial draft

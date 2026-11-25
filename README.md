# stats

Usage stats for Precogly repositories. A daily workflow collects them and commits the results here, so the numbers build up over time.

## What is tracked

For each repository in [`tracked-repos.txt`](tracked-repos.txt), files are saved under `data/<owner>/<name>/`:

| File | What it holds |
|---|---|
| `clones.json` | Total clones and unique cloners, plus one record per day |
| `views.json` | Total page views and unique visitors, plus one record per day |
| `repo.json` | Current stars, forks, watchers and release file downloads |

Example: [`data/precogly/precogly/clones.json`](data/precogly/precogly/clones.json)

## Things to know

- **Counting starts on the first run.** GitHub keeps only the last 14 days of clones and views, so anything older than that is gone.
- **Unique counts run high.** GitHub only gives unique visitors per day, so someone who clones on two different days counts twice.
- **Today is partial.** The current day's numbers are corrected on the next run.

## Badges

Add these to a tracked repo's README (shown for `precogly/precogly`):

```markdown
[![Clones](https://img.shields.io/badge/dynamic/json?label=Clones&query=%24.count&url=https%3A%2F%2Fraw.githubusercontent.com%2Fprecogly%2Fstats%2Fmain%2Fdata%2Fprecogly%2Fprecogly%2Fclones.json&logo=github&color=success)](https://github.com/precogly/stats)
[![Unique Cloners](https://img.shields.io/badge/dynamic/json?label=Unique%20Cloners&query=%24.uniques&url=https%3A%2F%2Fraw.githubusercontent.com%2Fprecogly%2Fstats%2Fmain%2Fdata%2Fprecogly%2Fprecogly%2Fclones.json&logo=github&color=success)](https://github.com/precogly/stats)
```

## Setup

1. Create a fine-grained token at https://github.com/settings/personal-access-tokens/new
   - Resource owner: **precogly**
   - Repository access: **Only select repositories**, pick every repo in `tracked-repos.txt`
   - Repository permissions: **Administration: Read-only**
2. Save it in this repo under **Settings → Secrets and variables → Actions** as `CLONE_TRAFFIC_TOKEN`.
3. Run **Actions → Collect stats → Run workflow** once.

## Adding a repository

1. Add its `owner/name` to `tracked-repos.txt`.
2. Add the repo to the token's repository access (edit the token, no need to create a new one).

## Running locally

With the GitHub CLI logged in as a repo admin:

```bash
GH_TOKEN=$(gh auth token) bash scripts/collect.sh
```

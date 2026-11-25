#!/usr/bin/env bash
# Collects stats for every repository in tracked-repos.txt and writes them
# under data/<owner>/<name>/:
#   clones.json  running total of clones, one record per day
#   views.json   running total of page views, one record per day
#   repo.json    current stars, forks, watchers and release asset downloads
#
# Requires GH_TOKEN with "Administration: Read-only" on each tracked repo
# (GitHub only shows traffic data to repo admins).

set -euo pipefail

if [ -z "${GH_TOKEN:-}" ]; then
  echo "::error::GH_TOKEN is empty. Add the CLONE_TRAFFIC_TOKEN secret (see README)."
  exit 1
fi

script_directory="$(cd "$(dirname "$0")" && pwd)"
repository_root="$(dirname "$script_directory")"
temporary_directory="${RUNNER_TEMP:-$(mktemp -d)}"

cd "$repository_root"

grep -vE '^\s*(#|$)' tracked-repos.txt | while read -r repository; do
  echo "== $repository"
  output_directory="data/$repository"
  mkdir -p "$output_directory"

  for traffic_kind in clones views; do
    stored_file="$output_directory/$traffic_kind.json"
    [ -f "$stored_file" ] || echo '{}' > "$stored_file"

    gh api "repos/$repository/traffic/$traffic_kind" > "$temporary_directory/recent.json"

    jq -n \
      --slurpfile stored "$stored_file" \
      --slurpfile recent "$temporary_directory/recent.json" \
      --arg kind "$traffic_kind" \
      --from-file scripts/merge_daily.jq > "$temporary_directory/merged.json"
    mv "$temporary_directory/merged.json" "$stored_file"

    jq -c --arg kind "$traffic_kind" '{($kind): .count, uniques, days: (.days | length)}' "$stored_file"
  done

  release_downloads=$(
    gh api --paginate "repos/$repository/releases" --jq '[.[].assets[].download_count] | add // 0' \
      | jq -s 'add // 0'
  )

  gh api "repos/$repository" \
    | jq --argjson release_downloads "$release_downloads" '{
        stars: .stargazers_count,
        forks: .forks_count,
        watchers: .subscribers_count,
        release_downloads: $release_downloads
      }' > "$output_directory/repo.json"

  jq -c . "$output_directory/repo.json"
done

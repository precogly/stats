# Merges GitHub's last-14-days traffic (clones or views) into the stored
# per-day record and recomputes the totals.
#
# Inputs (passed with --slurpfile / --arg):
#   $stored  the existing file, e.g. data/precogly/precogly/clones.json
#   $recent  the API response from /repos/{owner}/{repo}/traffic/{kind}
#   $kind    "clones" or "views", the array name in the API response
#
# A day from the API overwrites the stored day with the same date, so a
# partial "today" is corrected on the next run and re-reading the 14-day
# window never double counts.

(($stored[0] // {}).days // []) as $stored_days
| ($recent[0][$kind] // []) as $recent_days
| (reduce ($stored_days + $recent_days)[] as $day ({};
    .[$day.timestamp] = {timestamp: $day.timestamp, count: $day.count, uniques: $day.uniques}
  )) as $days_by_date
| ($days_by_date | [.[]] | sort_by(.timestamp)) as $merged_days
| {
    count: ($merged_days | map(.count) | add // 0),
    uniques: ($merged_days | map(.uniques) | add // 0),
    days: $merged_days
  }

# Homebrew tap release maintenance.
#
# cargo-dist normally auto-bumps Formula/qn.rb from the cli release pipeline.
# These recipes are a manual recovery path for when the auto-bump fails or
# you need to retro-bump the formula against an existing cli release.

# Rewrite Formula/qn.rb against an existing cli release on a fresh
# release/vX.Y.Z branch. Downloads the four release artifacts, computes
# sha256s, and replaces the version + url/sha256 stanzas.
# Usage: just bump-formula 0.2.0
bump-formula version:
  #!/usr/bin/env bash
  set -euo pipefail
  raw_version="{{version}}"
  if [[ "$raw_version" =~ ^v ]]; then
    echo "Error: version '$raw_version' must not start with 'v'. The 'v' prefix is added automatically when referencing the cli tag. Try: just bump-formula ${raw_version#v}" >&2
    exit 1
  fi
  if [[ ! "$raw_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$ ]]; then
    echo "Error: version '$raw_version' is not valid semver (expected X.Y.Z or X.Y.Z-rc.N)." >&2
    exit 1
  fi
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  if [[ "$current_branch" != "main" ]]; then
    echo "Error: must be on main to start a bump (currently on '$current_branch')." >&2
    exit 1
  fi
  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "Error: working tree is not clean. Commit or stash changes before bumping." >&2
    exit 1
  fi
  current_version=$(sed -nE 's/^  version "(.+)"/\1/p' Formula/qn.rb | head -1)
  if [[ "$current_version" == "$raw_version" ]]; then
    echo "Formula/qn.rb is already at $raw_version. No bump needed." >&2
    exit 0
  fi

  base_url="https://github.com/quicknode/cli/releases/download/v${raw_version}"
  triples=(
    "aarch64-apple-darwin"
    "x86_64-apple-darwin"
    "aarch64-unknown-linux-gnu"
    "x86_64-unknown-linux-gnu"
  )
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  # Parallel arrays keyed by index — macOS bash 3.2 has no associative arrays.
  shas=()
  for triple in "${triples[@]}"; do
    artifact="quicknode-cli-${triple}.tar.xz"
    url="${base_url}/${artifact}"
    echo "Fetching ${artifact}..."
    if ! curl --fail --location --silent --show-error --output "${tmp}/${artifact}" "$url"; then
      echo "Error: failed to download ${url}. Is the cli release v${raw_version} published with all four artifacts attached?" >&2
      exit 1
    fi
    sha=$(shasum -a 256 "${tmp}/${artifact}" | awk '{print $1}')
    shas+=("$sha")
    echo "  sha256: ${sha}"
  done

  git checkout -b "release/v${raw_version}"

  # Rewrite the version literal.
  sed -i.bak -E 's|^  version "[^"]+"|  version "'"$raw_version"'"|' Formula/qn.rb

  # Rewrite each url + sha256 pair by triple. The url line is matched on its
  # triple suffix; the following sha256 line is replaced unconditionally via
  # sed's "next line" pattern.
  for i in "${!triples[@]}"; do
    triple=${triples[$i]}
    sha=${shas[$i]}
    url="${base_url}/quicknode-cli-${triple}.tar.xz"
    sed -i.bak -E '\|quicknode-cli-'"$triple"'\.tar\.xz|{
      s|url ".*"|url "'"$url"'"|
      n
      s|sha256 "[^"]+"|sha256 "'"$sha"'"|
    }' Formula/qn.rb
  done
  rm -f Formula/qn.rb.bak

  git add Formula/qn.rb
  git commit -m "Bump qn formula to v${raw_version}"
  echo "Committed bump on branch release/v${raw_version}. Next: just bump-open-pr ${raw_version}"

# Push the release branch and open a PR for the bump commit.
bump-open-pr version:
  #!/usr/bin/env bash
  set -euo pipefail
  git push -u origin "release/v{{version}}"
  gh pr create \
    --base main \
    --head "release/v{{version}}" \
    --title "Bump qn formula to v{{version}}" \
    --body "Manual formula bump for cli v{{version}}. Merging this PR makes \`brew install quicknode/tap/qn\` resolve to v{{version}}."

# Squash-merge the bump PR (with confirmation) and poll until MERGED.
bump-merge-pr version:
  #!/usr/bin/env bash
  set -euo pipefail
  pr_state=$(gh pr view "release/v{{version}}" --json state -q .state)
  if [[ "$pr_state" == "MERGED" ]]; then
    echo "PR for release/v{{version}} already merged."
    exit 0
  fi
  read -r -p "Merge bump PR for v{{version}} now via 'gh pr merge --squash --delete-branch'? [y/N] " response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    gh pr merge "release/v{{version}}" --squash --delete-branch
  else
    echo "Aborted. Merge the PR manually in GitHub, then re-run: just bump-release {{version}}" >&2
    exit 1
  fi
  for attempt in $(seq 1 20); do
    pr_state=$(gh pr view "release/v{{version}}" --json state -q .state)
    if [[ "$pr_state" == "MERGED" ]]; then
      echo "PR merged."
      exit 0
    fi
    sleep 3
  done
  echo "Error: PR for release/v{{version}} did not reach MERGED state." >&2
  exit 1

# Orchestrates the bump with two confirmation checkpoints: one before
# pushing the bump branch, one before squash-merging the PR.
# Pass yes=1 to skip prompts (for automation).
# Usage: just bump-release 0.2.0
bump-release version yes="0":
  #!/usr/bin/env bash
  set -euo pipefail
  if [[ "{{yes}}" != "1" ]]; then
    echo "About to bump qn formula to v{{version}}:"
    echo "  1. Fetch cli release artifacts and compute sha256s"
    echo "  2. Rewrite Formula/qn.rb on branch release/v{{version}}"
    echo "  --- review diff and confirm before push ---"
    echo "  3. Push branch + open PR (review checkpoint)"
    echo "  4. Merge PR via 'gh pr merge --squash --delete-branch'"
    echo
    read -r -p "Continue? [y/N] " response
    [[ "$response" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
  fi
  just bump-formula {{version}}
  echo
  echo "=== Bump commit (HEAD) ==="
  git --no-pager show --stat HEAD
  echo
  echo "=== Diff vs main ==="
  git --no-pager diff main...HEAD -- Formula/qn.rb
  echo
  if [[ "{{yes}}" != "1" ]]; then
    echo "Review the bump above. Pushing will open a PR for review."
    read -r -p "Push branch release/v{{version}} and open PR? [y/N] " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      echo "Aborted before push. The bump commit exists locally on release/v{{version}} — undo with:"
      echo "  git checkout main && git branch -D release/v{{version}}"
      exit 1
    fi
  fi
  just bump-open-pr {{version}}
  just bump-merge-pr {{version}}
  echo
  echo "Done. Formula at https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/blob/main/Formula/qn.rb"

#!/bin/bash

# Copyright 2019 Google
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Checks that the current state of the tree is sane and optionally auto-fixes
# errors automatically. Meant for interactive use.

function usage() {
  cat <<EOF
USAGE: scripts/check.sh [--commit] [<revision>]

Runs auto-formatting scripts, source-tree checks, and linters on any files that
have changed since master.

By default, any changes are left as uncommited changes in the working tree. You
can review them with git diff. Pass --commit to automatically commit any changes.

Pass an alternate revision to use as the basis for checking changes.

EXAMPLES:

  check.sh
    Runs automated checks and formatters on all changed files since master.
    Check for changes with git diff.

  check.sh --commit
    Runs automated checks and formatters on all changed files since master and
    commits the results.

  check.sh --commit HEAD
    Runs automated checks and formatters on all changed files since the last
    commit.

EOF
}

set -euo pipefail
unset CDPATH

# Change to the top-directory of the working tree
top_dir=$(git rev-parse --show-toplevel)
cd "$top_dir"

commit=false
start="master"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --)
      # Do nothing: explicitly allow this, but ignore it
      ;;

    -h | --help)
      usage
      exit 1
      ;;

    --commit)
      commit=true
      ;;

    *)
      if git rev-parse "$1" >& /dev/null; then
        start="$1"
        break
      fi
      ;;
  esac
  shift
done

# Record actual start
start_sha=$(git rev-parse "$start")

# Restyle and commit any changes
scripts/style.sh "$start_sha" || :
if ! git diff --quiet; then
  if [[ $commit == true ]]; then
    echo "Style generated changes"
    git commit -a --fixup=HEAD
  fi
fi

scripts/sync_project.rb
if ! git diff --quiet; then
  if [[ $commit == true ]]; then
    echo "Sync Xcode project"
    git commit -a --fixup=HEAD
  fi
fi

# Check lint errors
(
  scripts/lint.sh "$start_sha"
  scripts/check_copyright.sh
  scripts/check_no_module_imports.sh
  scripts/check_test_inclusion.py
  scripts/check_whitespace.sh
) 2>&1 | sed "s,^Firestore,$top_dir/Firestore,"

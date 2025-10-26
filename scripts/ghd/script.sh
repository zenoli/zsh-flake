#!/bin/bash

issue=$( \
  gh issue list --json number,title \
  | jq '.[] | { number, title } | join(" ")' \
  | sed 's/"//g' \
  | fzf
)
number="$(echo "$issue" | cut -d ' ' -f1)"
title="$(echo "$issue" | cut -d ' ' -f2-)"
branch_name="$number-$title"
base_branch_name=$(git rev-parse --abbrev-ref HEAD)
if git ls-remote --heads origin "$branch_name" | grep -q .; then
  echo "Branch '$branch_name' exists on origin. Switching..."
  git switch "$branch_name"
else
  echo "Creating new branch: $branch_name"
  gh issue develop "$number" \
      --name "$branch_name" \
      --base "$base_branch_name" \
      --checkout
fi

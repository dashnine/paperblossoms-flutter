#!/usr/bin/env bash
# Staple a notarization ticket to an app or DMG, retrying on transient
# failures. Right after a submission is accepted, Apple's CloudKit
# ticket-delivery endpoint sometimes drops the connection ("The network
# connection was lost", stapler error 68) even though the ticket exists;
# a short wait and a retry almost always succeeds.
set -euo pipefail

target="$1"
attempts="${2:-5}"
delay="${3:-30}"

for ((attempt = 1; attempt <= attempts; attempt++)); do
  if xcrun stapler staple "$target"; then
    exit 0
  fi
  if ((attempt == attempts)); then
    echo "::error::Stapling $target failed after $attempts attempts"
    exit 1
  fi
  echo "Staple attempt $attempt failed (ticket may not be served yet); retrying in ${delay}s..."
  sleep "$delay"
done

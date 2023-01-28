#!/bin/sh

set -e

if [ -n "$1" ]; then
  DERIVATION="$1"
  shift
else
  echo "Must provide an output path to test against"
  echo "Usage: $0 ./result/"
  exit 1
fi

assertVersion() {
  program="$1"
  command="$DERIVATION/bin/$2"
  version="$3"
  output="$(mktemp)"

  $command > $output

  if grep -q "$version" "$output"; then
    printf "."
  else
    echo "$program did not match $version. Full output"
    echo
    echo "    $(cat "$output")"
    echo
    exit 1
  fi
}

assertVersion "ruby" "ruby --version" "3.1.2"
assertVersion "psql" "psql --version" "13.4"
assertVersion "redis" "redis-cli --version" "7.0.5"

echo
exit 0

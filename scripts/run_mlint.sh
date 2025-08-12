#!/usr/bin/env bash
# Lint all MATLAB files using checkcode (mlint).
# Exits with non-zero status if any issues are found.
set -euo pipefail

find . -name '*.m' -print0 | (
  status=0
  while IFS= read -r -d '' file; do
    echo "Linting ${file}"
    matlab -batch "issues = checkcode('${file}', '-id'); if ~isempty(issues); disp(issues); exit(1); end" || status=1
  done
  exit $status
)

exit $?

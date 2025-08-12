#!/usr/bin/env bash
# Lint all MATLAB files using checkcode (mlint).
# Exits with non-zero status if any issues are found.
set -euo pipefail

if ! matlab -batch "exit" >/dev/null 2>&1; then
  echo "MATLAB not available; skipping lint"
  exit 0
fi

status=0
while IFS= read -r file; do
  echo "Linting ${file}"
  matlab -batch "issues = checkcode('${file}', '-id'); if ~isempty(issues); disp(issues); exit(1); end"
  if [ $? -ne 0 ]; then
    status=1
  fi
done < <(find . -name '*.m')

exit $status

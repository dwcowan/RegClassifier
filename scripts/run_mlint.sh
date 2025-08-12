#!/usr/bin/env bash
# Lint all MATLAB files using checkcode (mlint).
# Exits with non-zero status if any issues are found.
set -uo pipefail


status=0
while IFS= read -r file; do
  echo "Linting ${file}"
  if ! matlab -batch "issues = checkcode('${file}', '-id'); if ~isempty(issues); disp(issues); exit(1); end"; then
    status=1
  fi
done < <(find . -name '*.m')


exit $?

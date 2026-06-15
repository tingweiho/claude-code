#!/bin/bash
# Run from repo root: bash src/build.sh
set -e
cd "$(dirname "$0")"
cat _base.html modules/*.html _footer.html > ../index.html
echo "Built index.html — open it in your browser."

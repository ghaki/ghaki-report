export GK_PROJECT_IDEPS=( \
  "$(pwd)/../ghaki-core/lib" \
  "$(pwd)/../ghaki-logger/lib" \
  "$(pwd)/../ghaki-stats/lib" \
  )
export GK_PROJECT_GO_DIRS=( \
  "lib:${GK_PROJECT_DIR}/lib/ghaki/report" \
  "spec:${GK_PROJECT_DIR}/spec/ghaki/report" \
  )
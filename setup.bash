export GK_PROJECT_IDEPS=( \
  "${GK_PROJECT_DIR}/../ghaki-app/lib" \
  "${GK_PROJECT_DIR}/../ghaki-ext-file/lib" \
  "${GK_PROJECT_DIR}/../ghaki-logger/lib" \
  "${GK_PROJECT_DIR}/../ghaki-match/lib" \
  "${GK_PROJECT_DIR}/../ghaki-stats/lib" \
  )

export GK_PROJECT_GO_DIRS=( \
  "lib:${GK_PROJECT_DIR}/lib/ghaki/report" \
  "spec:${GK_PROJECT_DIR}/spec/ghaki/report" \
  )

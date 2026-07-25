---
description: Chạy test (output đã lọc, tiết kiệm token)
argument-hint: "[Target/Class hoặc để trống = full suite]"
allowed-tools: Bash("${CLAUDE_PLUGIN_ROOT}"/scripts/test.sh:*)
---

Chạy test: $ARGUMENTS

- Có arguments → chạy khoanh vùng: `"${CLAUDE_PLUGIN_ROOT}"/scripts/test.sh -only-testing:$1`
- Không có → giao cho agent `test-runner` chạy full suite và tổng hợp báo cáo.
- Báo lại: passed/failed, nguyên nhân từng fail, log path.

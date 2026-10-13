## Requirements

### REQ-12 Opens song files in versions 3–5; older versions get a clear message
Source: SPEC §4.3
Levels: acceptance, unit · Split: acceptance the main flows, unit each format version
- acceptance open-file: opens a v4 file; rejects a v2 file with a message.
- unit: reads v3 header; reads v5 header.

### REQ-13 Lists recent files
Source: SPEC §4.4

## Slices

1. REQ-12
2. REQ-13

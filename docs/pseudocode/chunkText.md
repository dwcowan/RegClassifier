# Pseudocode: `reg.chunkText`

## Purpose
Split a documents table into overlapping token chunks for downstream processing.

## Expected Table Schema
- **Input `docsTbl`**: table with variables `docId` (string) and `text` (string).
- **Output `chunksTbl`**: table with variables `chunkId` (double), `docId` (string), `text` (string), `startIndex` (double), `endIndex` (double).

## Variable Naming Conventions
- Tables use the `Tbl` suffix (e.g., `docsTbl`, `chunksTbl`).
- Token index variables end with `Idx` (e.g., `startIdx`, `endIdx`).
- Name-value parameters use lowerCamelCase (e.g., `chunkSizeTokens`, `chunkOverlap`).

## Algorithm
1. Create an empty `chunksTbl`.
2. For each row in `docsTbl`:
   - Extract `docId` and `text`.
   - Convert `text` into a list of `tokens`.
   - Set `startIdx` to 1.
   - While `startIdx` is less than or equal to the number of `tokens`:
     - Let `endIdx` be the lesser of `startIdx + chunkSizeTokens - 1` and the total number of `tokens`.
     - Combine tokens from `startIdx` to `endIdx` into `chunkText`.
     - Form `chunkId` as a unique numeric identifier (e.g., using `startIdx`).
     - Append a row `{chunkId, docId, chunkText, startIdx, endIdx}` to `chunksTbl`.
     - Increment `startIdx` by `chunkSizeTokens - chunkOverlap`.
3. Return `chunksTbl`.

- `tokenizeText` and `joinTokens` are placeholders for tokenization utilities.
- The iteration advances by `chunkSizeTokens - chunkOverlap`, producing overlapping windows.

# ingestPdfs Pseudocode

Algorithm outline for [ingestPdfs](../identifier_registry.md#functions).

1. Initialize empty table [docsTbl](../identifier_registry.md#variables) with columns [`docId`](../identifier_registry.md#document) and [`text`](../identifier_registry.md#document).
2. For each PDF file in the input directory:
   1. Derive `docId` from the file name.
   2. Attempt to retrieve textual content directly from the file.
   3. If no text is retrieved:
      1. For each page in the file, apply OCR to obtain text.
      2. Concatenate the page text into a single string.
   4. Append a row to `docsTbl` with `docId` and the collected text.
3. Return `docsTbl`.

The function uses OCR as a fallback for image-only pages and outputs a table containing the document identifier and raw text fields.
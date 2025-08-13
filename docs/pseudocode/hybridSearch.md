# Hybrid Search Score Fusion Pseudocode

Combines lexical and vector search results into a single ranked list.
Assumes two retrieval systems: BM25 for term matching and an embedding index
for semantic similarity. Each returns top `K` documents with scores.

```
HYBRID_SEARCH(query, K, weightLexical, weightVector):
    bm25Table ← BM25_SEARCH(query, K)        // docId, bm25Score
    vectorTable ← VECTOR_SEARCH(query, K)    // docId, vectorScore

    normalize bm25Table.bm25Score to range [0,1]
    normalize vectorTable.vectorScore to range [0,1]

    mergedTable ← outer join bm25Table and vectorTable on docId
    replace missing bm25Score or vectorScore with 0

    mergedTable.combinedScore ←
        weightLexical * bm25Score + weightVector * vectorScore

    sort mergedTable by combinedScore in descending order
    return mergedTable
```

**Outputs**

- Results table containing `docId`, individual scores, and `combinedScore`.
- Final ranking is determined by `combinedScore` in descending order.
- Ties retain the relative order from the lexical results.

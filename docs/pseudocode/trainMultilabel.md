# Multilabel Classifier Training Pseudocode

This pseudocode outlines how to train a multilabel classifier over chunked text.
The dataset contains `N` examples and `L` possible labels.

```
TRAIN_MULTILABEL(trainTable):
    labelMatrix ← encode labels in trainTable as multi-hot vectors of length L
    model ← initialize classifier with final sigmoid layer of size L

    repeat for each epoch:
        for each (text, labelVector) in trainTable:
            features ← embed(text)
            logits ← forward(model, features)
            loss ← binary cross-entropy(sigmoid(logits), labelVector)
            update model parameters using loss and learning rate

    classifierHandle(text):
        features ← embed(text)
        logits ← forward(model, features)
        probVector ← sigmoid(logits)        // length L
        return probVector

    return classifierHandle
```

**Outputs**

- `classifierHandle`: maps text input to a probability vector of length `L`.
- During evaluation, collect results for a batch of `N` texts:

```
probMatrix ← classifierHandle(batchText)    // N × L
labelMatrix ← elementwise comparison (probMatrix > threshold)
```

- Metrics such as micro/macro F1 or label-wise AUC use the original column
  ordering of labels.

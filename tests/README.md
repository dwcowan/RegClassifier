# Tests

## Gold regression fixtures

`GoldPackModelTest` exercises a deterministic labelled dataset to ensure that
model evaluation metrics do not regress. The test loads the fixture model and,
when fully implemented, will compare metrics produced during evaluation with
gold labels.

Gold fixtures live under [`tests/+reg/+fixture`](+reg/+fixture) and store
reference data used for regression checks. When the expected evaluation output
changes intentionally, regenerate the gold data (for example by running the
full evaluation pipeline) and update the fixtures in that folder before
committing.

# Knobs and Seed Control Interfaces

This document outlines expected behaviours for several configuration
helpers. Each function currently ships as a stub and must be
re-implemented by consumers of this repository.

## `reg.load_knobs(jsonPath)`
Reads a JSON file describing tunable parameters and returns a struct `K`.
Typical sections include:
- `BERT` – fields like `MiniBatchSize`, `MaxSeqLength`.
- `Projection` – `ProjDim`, `Epochs`, `BatchSize`, `LR`, `Margin`, `UseGPU`.
- `FineTune` – `Loss`, `BatchSize`, `MaxSeqLength`, `UnfreezeTopLayers`, `Epochs`, `EncoderLR`, `HeadLR`.
- `Chunk` – `SizeTokens`, `Overlap`.

**Input:** optional path to the JSON file.

**Output:** MATLAB struct containing knob values or empty struct when
unavailable.

## `reg.validate_knobs(K)`
Examines knob values and warns or errors when they fall outside supported
ranges (e.g. negative batch sizes or unsupported sequence lengths).
Implementation is environment-specific and may raise errors or emit
warnings.

**Input:** struct `K` produced by `load_knobs`.

**Output:** none. Should raise on invalid input.

## `reg.print_active_knobs(C)`
Pretty-prints the contents of `C.knobs` to aid debugging. Common
implementations call `validate_knobs` and then display each section and
its values.

**Input:** configuration struct `C` containing field `knobs`.

**Output:** none. Should render human-readable summary.

## `reg.set_seeds(seed)`
Sets random number generator seeds for reproducible experiments.
Implementations may also seed parallel or GPU generators and return the
applied seeds for logging.

**Input:** numeric seed value.

**Output:** struct describing seeds applied (e.g. `rng`).

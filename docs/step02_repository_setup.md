# Step 2: Repository Setup

**Goal:** Acquire the project and confirm configuration wiring.

**Depends on:** [Step 1: Environment & Tooling](step01_environment_tooling.md).

## Instructions
Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

1. Clone or unzip the project repository.
2. In MATLAB, navigate to the project root and add all folders to the path:
   ```matlab
   addpath(genpath(pwd));
   savepath
   ```
3. Review configuration files and adjust paths or parameters as needed:
   - `pipeline.json` – data locations and database settings.
   - `knobs.json` – chunking sizes, batch sizes, learning rates.
   - `params.json` – optional fine-tuning overrides.
4. Run the configuration script to display current settings:
   ```matlab
   config
   ```

## Function Interface
### addpath / savepath
- **Parameters:** root directory (string) typically `pwd`.
- **Returns:** none.
- **Side Effects:** modifies the MATLAB search path and persists it for future sessions.
- **Usage Example:**
  ```matlab
  addpath(genpath(pwd)); savepath
  ```

### config
- **Parameters:** none.
- **Returns:** struct `configStruct` with fields derived from `pipeline.json`, `knobs.json`, and `params.json` overrides.
- **Side Effects:** reads configuration files from disk.
- **Usage Example:**
  ```matlab
  configStruct = config;
  ```

Data structures referenced in later modules are detailed in [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts).

## Verification
- `config` prints the contents of the JSON files without errors.
- MATLAB can locate project functions such as `regPipeline`.

## Next Steps
Continue to [Step 3: Data Ingestion](step03_data_ingestion.md).

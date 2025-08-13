# Step 3: MVC Scaffolding & Persistence

**Goal:** Establish the base MVC structure and storage layer.

**Depends on:** [Step 2: Repository Setup](step02_repository_setup.md).

## Instructions
Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

Consult `README_NAMING.md` and update `docs/identifier_registry.md` for any new identifiers introduced in this step.

1. Create `+model`, `+view`, and `+controller` directories to organize core classes.
2. Implement base classes such as `model.Document` and `controller.IngestionController`.
3. Establish a persistence layer (repositories or DAOs) for storing model state.

Continue to [Step 4: Data Ingestion](step04_data_ingestion.md).

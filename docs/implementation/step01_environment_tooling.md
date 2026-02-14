# Step 1: Environment & Tooling

**Goal:** Prepare a reproducible MATLAB workspace.

**Depends on:** None.

## Instructions
1. Install **MATLAB R2025b** on your workstation.
2. During installation, add these toolboxes:
   - Text Analytics
   - Deep Learning
   - Statistics and Machine Learning
   - Database
   - Parallel Computing
   - Report Generator (optional: Computer Vision)
3. From the MATLAB Add-On Explorer, install *Deep Learning Toolbox Model for BERT-Base, English*.
4. Launch MATLAB and verify GPU access:
   ```matlab
   gpuDevice
   ```
   The command should list your CUDA-enabled GPU (e.g., RTX 4060 Ti).
5. Save a snapshot of installed products for future reference:
   ```matlab
   ver
   ```

## Verification
- `gpuDevice` reports a supported GPU and its memory.
- `ver` lists all required toolboxes and the BERT add-on.

## Next Steps
Continue to [Step 2: Repository Setup](step02_repository_setup.md).

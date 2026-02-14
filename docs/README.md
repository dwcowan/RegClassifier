# RegClassifier Documentation

Complete documentation for the RegClassifier system, organized by category.

## 📚 Directory Structure

### `/guides/` - User & Methodology Guides
Comprehensive guides for using and understanding the validation methodologies:
- **ANNOTATION_PROTOCOL.md** - Ground-truth annotation protocol ($42-91K budget)
- **HYBRID_VALIDATION_STRATEGY.md** - Active learning + RLHF ($2-8K budget)
- **PDF_EXTRACTION_GUIDE.md** - Two-column PDF extraction setup
- **RL_HUMAN_FEEDBACK_GUIDE.md** - RLHF system documentation
- **VALIDATION_DECISION_GUIDE.md** - Choose your validation approach
- **ZERO_BUDGET_VALIDATION.md** - Split-rule validation ($0 budget)

### `/implementation/` - Step-by-Step Implementation
12-step development roadmap with detailed implementation guides:
- **step01** - Environment & tooling setup
- **step02** - Repository setup
- **step03** - Data ingestion
- **step04** - Text chunking
- **step05** - Weak labeling
- **step06** - Embedding generation
- **step07** - Baseline classifier
- **step08** - Projection head
- **step09** - Encoder fine-tuning
- **step10** - Evaluation & reporting
- **step11** - Data acquisition & diffs
- **step12** - Continuous testing

### `/reference/` - Reference Documentation
Technical reference and coding standards:
- **Matlab_Style_Guide.md** - MATLAB coding conventions
- **README_NAMING.md** - Naming conventions
- **SYSTEM_BUILD_PLAN.md** - System architecture & build plan
- **identifier_registry.md** - Identifier registry
- **knobs_interface.md** - Hyperparameter configuration

### `/development/` - Development Workflow
Development and contribution guidelines:
- **github_workflow.md** - GitHub workflow & PR process
- **creating_issues.md** - Issue creation manual
- **ci_cd_setup.md** - CI/CD configuration

### `/demo/` - Demo Materials
Demo and presentation materials:
- **README.md** - Demo instructions

## 🚀 Quick Start

New to RegClassifier? Start here:
1. Read [../README.md](../README.md) - Main project README
2. Review [../QUICKSTART.md](../QUICKSTART.md) - 15-minute quick start
3. Follow [../INSTALL_GUIDE.md](../INSTALL_GUIDE.md) - Installation guide
4. Explore [guides/](guides/) - Choose your validation strategy

## 📖 Core Documentation (in root)

Essential documentation kept in the project root:
- **README.md** - Main project README
- **CLAUDE.md** - AI assistant guide
- **QUICKSTART.md** - Quick start guide
- **CLASS_ARCHITECTURE.md** - System architecture
- **PROJECT_CONTEXT.md** - Complete project context
- **EXPERIMENT_CHEATSHEET.md** - Quick reference
- **INSTALL_GUIDE.md** - Installation guide
- **METHODOLOGY_OVERVIEW.md** - Methodology overview
- **METHODOLOGICAL_ISSUES.md** - Identified issues & fixes

## 🔍 Finding Documentation

**By Task:**
- **Setting up** → [../INSTALL_GUIDE.md](../INSTALL_GUIDE.md)
- **First run** → [../QUICKSTART.md](../QUICKSTART.md)
- **Validation approach** → [guides/VALIDATION_DECISION_GUIDE.md](guides/VALIDATION_DECISION_GUIDE.md)
- **PDF extraction** → [guides/PDF_EXTRACTION_GUIDE.md](guides/PDF_EXTRACTION_GUIDE.md)
- **Development** → [development/](development/)
- **Code style** → [reference/Matlab_Style_Guide.md](reference/Matlab_Style_Guide.md)

**By Budget:**
- **$0** → [guides/ZERO_BUDGET_VALIDATION.md](guides/ZERO_BUDGET_VALIDATION.md)
- **$2-8K** → [guides/HYBRID_VALIDATION_STRATEGY.md](guides/HYBRID_VALIDATION_STRATEGY.md)
- **$42-91K** → [guides/ANNOTATION_PROTOCOL.md](guides/ANNOTATION_PROTOCOL.md)

**By Role:**
- **Researcher** → [guides/](guides/), [../METHODOLOGY_OVERVIEW.md](../METHODOLOGY_OVERVIEW.md)
- **Developer** → [development/](development/), [reference/](reference/)
- **AI Assistant** → [../CLAUDE.md](../CLAUDE.md)
- **User** → [../README.md](../README.md), [../QUICKSTART.md](../QUICKSTART.md)

---

**Last Updated:** February 2026
**Organization:** Reorganized for clarity and ease of navigation

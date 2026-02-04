# RegClassifier Installation Guide

**Complete installation instructions for all environments**

---

## Table of Contents

1. [System Requirements](#requirements)
2. [MATLAB Installation](#matlab)
3. [GPU Setup](#gpu)
4. [Python Setup (Optional)](#python)
5. [Database Setup (Optional)](#database)
6. [Verification](#verification)
7. [Troubleshooting](#troubleshooting)

---

## 1. System Requirements <a name="requirements"></a>

### Minimum Requirements

| Component | Requirement |
|-----------|-------------|
| **OS** | Windows 10/11, macOS 11+, Ubuntu 20.04+ |
| **MATLAB** | R2024a or later |
| **RAM** | 16GB (32GB recommended) |
| **Disk Space** | 20GB free |
| **GPU** | 8GB VRAM (RTX 3060 Ti or better) |
| **Internet** | For initial model downloads |

### Recommended Specifications

| Component | Recommendation |
|-----------|----------------|
| **CPU** | Intel i7/i9 or AMD Ryzen 7/9 |
| **RAM** | 32GB+ |
| **GPU** | RTX 4060 Ti 16GB or RTX 4090 |
| **Storage** | NVMe SSD |

---

## 2. MATLAB Installation <a name="matlab"></a>

### Install MATLAB

1. **Download MATLAB R2024a or later**
   - Academic: https://www.mathworks.com/academia.html
   - Commercial: https://www.mathworks.com/products/matlab.html

2. **Run installer**
   - Follow MathWorks installation wizard
   - Recommended installation directory:
     - Windows: `C:\Program Files\MATLAB\R2024a`
     - Mac: `/Applications/MATLAB_R2024a.app`
     - Linux: `/usr/local/MATLAB/R2024a`

### Required Toolboxes

Install these toolboxes during MATLAB installation or via Add-On Explorer:

1. **Text Analytics Toolbox** - Text processing and NLP
2. **Deep Learning Toolbox** - BERT embeddings, neural networks
3. **Statistics and Machine Learning Toolbox** - Classification algorithms
4. **Database Toolbox** - SQLite/PostgreSQL connectivity
5. **Parallel Computing Toolbox** - GPU acceleration
6. **MATLAB Report Generator** - PDF report generation
7. **Computer Vision Toolbox** - OCR for PDF extraction

### Install Toolboxes via Add-On Explorer

```matlab
% In MATLAB:
matlab.addons.install  % Opens Add-On Explorer

% Or command-line (requires toolbox file):
matlab.addons.install('TextAnalytics.mltbx')
```

### Verify Toolbox Installation

```matlab
% Check all required toolboxes
required = {
    'Text Analytics Toolbox'
    'Deep Learning Toolbox'
    'Statistics and Machine Learning Toolbox'
    'Database Toolbox'
    'Parallel Computing Toolbox'
    'MATLAB Report Generator'
    'Computer Vision Toolbox'
};

fprintf('Checking toolboxes...\n\n');
for i = 1:numel(required)
    name = required{i};
    installed = license('test', strrep(name, ' ', '_'));

    if installed
        fprintf('✓ %s\n', name);
    else
        fprintf('✗ %s (INSTALL REQUIRED)\n', name);
    end
end
```

---

## 3. GPU Setup <a name="gpu"></a>

### NVIDIA GPU Requirements

**Supported GPUs:**
- RTX 30 series: 3060 Ti (8GB), 3070 (8GB), 3080 (10GB), 3090 (24GB)
- RTX 40 series: 4060 Ti (16GB), 4070 (12GB), 4080 (16GB), 4090 (24GB)
- Tesla/Quadro: T4, V100, A100

### Install CUDA and cuDNN

MATLAB R2024a supports CUDA 11.2 - 12.x.

**Windows:**
1. Download CUDA Toolkit: https://developer.nvidia.com/cuda-downloads
2. Install CUDA (default settings)
3. Download cuDNN: https://developer.nvidia.com/cudnn
4. Extract cuDNN and copy files to CUDA directory:
   ```
   Copy cudnn*/bin/* to C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.x\bin\
   Copy cudnn*/include/* to C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.x\include\
   Copy cudnn*/lib/* to C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.x\lib\
   ```

**Linux:**
```bash
# Ubuntu/Debian
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
sudo apt update
sudo apt install cuda

# cuDNN
sudo apt install libcudnn8 libcudnn8-dev
```

**Mac (Apple Silicon):**
No NVIDIA GPU support. Use CPU-only mode (slower).

### Verify GPU in MATLAB

```matlab
% Check GPU availability
gpuDevice()

% Should show:
%   Name: 'NVIDIA GeForce RTX 4060 Ti'
%   ComputeCapability: '8.9'
%   TotalMemory: 17179869184 (16 GB)

% Test GPU computation
A = gpuArray(rand(1000));
B = A * A;
wait(gpuDevice);
fprintf('GPU computation successful!\n');
```

### Troubleshooting GPU

**Issue:** `gpuDevice()` returns error

**Solutions:**
1. Update NVIDIA drivers: https://www.nvidia.com/Download/index.aspx
2. Verify CUDA version compatibility with MATLAB
3. Check environment variables:
   ```matlab
   getenv('CUDA_PATH')  % Should point to CUDA installation
   ```

---

## 4. Python Setup (Optional but Recommended) <a name="python"></a>

Python is **optional** but **strongly recommended** for:
- Best PDF extraction (two-column layouts, formulas)
- 10x faster than MATLAB OCR
- 99% accuracy on complex documents

### Install Python

**Windows:**
1. Download Python 3.12: https://www.python.org/downloads/
2. Run installer
3. ✓ **CHECK "Add Python to PATH"** (CRITICAL!)
4. Click "Install Now"
5. Wait 2-3 minutes

**Mac:**
```bash
# Check if already installed
python3 --version

# If not installed:
# Download from https://www.python.org/downloads/macos/
# Or use Homebrew:
brew install python@3.12
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3 python3-pip

# CentOS/RHEL
sudo yum install python3 python3-pip

# Arch
sudo pacman -S python python-pip
```

### Install Required Packages

```bash
# In Command Prompt / Terminal:
pip install pdfplumber pymupdf pillow

# Or if pip not found:
python -m pip install pdfplumber pymupdf pillow

# Mac/Linux may need pip3:
pip3 install pdfplumber pymupdf pillow
```

### Verify Python Setup

```matlab
% In MATLAB:
reg.check_python_setup()

% Should show:
% ========================================
%   Python Setup Checker for PDF Extraction
% ========================================
%
% [1/4] Checking for Python executable... ✓ FOUND
% [2/4] Checking Python version... ✓ OK (Python 3.12)
% [3/4] Checking required packages...
%    - pdfplumber: ✓ installed
%    - pymupdf: ✓ installed
%    - pillow: ✓ installed
% [4/4] Testing PDF extraction... ✓ SUCCESS
%
% ========================================
%   ✓ PYTHON SETUP COMPLETE!
% ========================================
```

### Python Virtual Environment (Advanced)

For isolation from system Python:

**Windows:**
```cmd
cd C:\path\to\RegClassifier
python -m venv venv
venv\Scripts\activate
pip install pdfplumber pymupdf pillow
```

**Mac/Linux:**
```bash
cd /path/to/RegClassifier
python3 -m venv venv
source venv/bin/activate
pip install pdfplumber pymupdf pillow
```

**Use in MATLAB:**
```matlab
[text, meta] = reg.ingest_pdf_python('doc.pdf', ...
    'PythonExe', 'C:\path\to\RegClassifier\venv\Scripts\python.exe');  % Windows
% Or
[text, meta] = reg.ingest_pdf_python('doc.pdf', ...
    'PythonExe', '/path/to/RegClassifier/venv/bin/python');  % Mac/Linux
```

---

## 5. Database Setup (Optional) <a name="database"></a>

Database is **optional**. RegClassifier works without it (in-memory only).

Use database for:
- Persistent storage across sessions
- Large-scale document collections (>10,000 documents)
- Production deployments

### Option A: SQLite (Recommended for Development)

**No installation required!** SQLite is built into MATLAB's Database Toolbox.

**Configuration:**
```json
// In pipeline.json:
{
  "db": {
    "enable": true,
    "vendor": "sqlite",
    "sqlite_path": "regclassifier.db"
  }
}
```

**Test:**
```matlab
C = config();
conn = reg.ensure_db(C);
fprintf('SQLite connected: %s\n', C.db.sqlite_path);
close(conn);
```

### Option B: PostgreSQL (Recommended for Production)

**Install PostgreSQL:**

**Windows:**
1. Download PostgreSQL 15: https://www.postgresql.org/download/windows/
2. Run installer (remember password!)
3. Default port: 5432

**Mac:**
```bash
brew install postgresql@15
brew services start postgresql@15
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql

# CentOS/RHEL
sudo yum install postgresql-server postgresql-contrib
sudo postgresql-setup --initdb
sudo systemctl start postgresql
```

**Create Database:**
```sql
-- In psql or pgAdmin:
CREATE DATABASE regclassifier;
CREATE USER reguser WITH ENCRYPTED PASSWORD 'your_password_here';
GRANT ALL PRIVILEGES ON DATABASE regclassifier TO reguser;
```

**Configuration:**
```json
// In pipeline.json:
{
  "db": {
    "enable": true,
    "vendor": "postgres",
    "dbname": "regclassifier",
    "user": "reguser",
    "password": "your_password_here",
    "server": "localhost",
    "port": 5432
  }
}
```

**Test:**
```matlab
C = config();
conn = reg.ensure_db(C);
fprintf('PostgreSQL connected!\n');
close(conn);
```

---

## 6. Verification <a name="verification"></a>

### Complete Installation Checklist

```matlab
fprintf('=== RegClassifier Installation Verification ===\n\n');

% 1. MATLAB Version
v = ver('MATLAB');
fprintf('[1/6] MATLAB Version: %s', v.Release);
if str2double(v.Release(3:6)) >= 2024
    fprintf(' ✓\n');
else
    fprintf(' ✗ (Need R2024a+)\n');
end

% 2. Toolboxes
required_toolboxes = 7;
installed_toolboxes = 0;
toolboxes = {'Text_Analytics_Toolbox', 'Deep_Learning_Toolbox', ...
             'Statistics_and_Machine_Learning_Toolbox', 'Database_Toolbox', ...
             'Parallel_Computing_Toolbox', 'MATLAB_Report_Generator', ...
             'Computer_Vision_Toolbox'};
for i = 1:numel(toolboxes)
    if license('test', toolboxes{i})
        installed_toolboxes = installed_toolboxes + 1;
    end
end
fprintf('[2/6] Toolboxes: %d/%d', installed_toolboxes, required_toolboxes);
if installed_toolboxes == required_toolboxes
    fprintf(' ✓\n');
else
    fprintf(' ✗\n');
end

% 3. GPU
try
    gpu = gpuDevice();
    fprintf('[3/6] GPU: %s (%.1f GB) ✓\n', gpu.Name, gpu.TotalMemory/1e9);
catch
    fprintf('[3/6] GPU: Not available or not configured ✗\n');
end

% 4. Python
try
    status = reg.check_python_setup();
    if status
        fprintf('[4/6] Python: Available ✓\n');
    else
        fprintf('[4/6] Python: Not configured ⚠\n');
    end
catch
    fprintf('[4/6] Python: Not configured ⚠ (Optional)\n');
end

% 5. Database
try
    C = config();
    if C.db.enable
        conn = reg.ensure_db(C);
        close(conn);
        fprintf('[5/6] Database: Connected (%s) ✓\n', C.db.vendor);
    else
        fprintf('[5/6] Database: Disabled (Optional)\n');
    end
catch
    fprintf('[5/6] Database: Not configured (Optional)\n');
end

% 6. Tests
results = runtests("tests", "IncludeSubfolders", true, "UseParallel", false, ...
    "OutputDetail", "None");
passed = sum([results.Passed]);
total = numel(results);
fprintf('[6/6] Tests: %d/%d passing', passed, total);
if passed == total
    fprintf(' ✓\n');
else
    fprintf(' ✗\n');
end

fprintf('\n=== Installation ');
if installed_toolboxes == required_toolboxes && passed == total
    fprintf('COMPLETE ✓ ===\n');
else
    fprintf('INCOMPLETE ✗ ===\n');
    fprintf('See troubleshooting below.\n');
end
```

---

## 7. Troubleshooting <a name="troubleshooting"></a>

### MATLAB License Issues

**Symptom:** "License checkout failed"

**Solutions:**
1. Check license status:
   ```matlab
   license('inuse')
   ```
2. Contact MathWorks support
3. Verify network license server (if applicable)

### GPU Not Detected

**Symptom:** `gpuDevice()` fails

**Solutions:**
1. **Update NVIDIA drivers:**
   - Windows: Device Manager → Display Adapters → Update Driver
   - Linux: `sudo ubuntu-drivers autoinstall`

2. **Check CUDA installation:**
   ```matlab
   [~, cuda_path] = system('where nvcc');  % Windows
   [~, cuda_path] = system('which nvcc');  % Linux/Mac
   fprintf('CUDA: %s\n', cuda_path);
   ```

3. **Verify GPU visibility:**
   ```bash
   nvidia-smi  # Should show your GPU
   ```

4. **Reinstall Parallel Computing Toolbox**

### Out of Memory Errors

**Symptom:** "Out of memory" during embeddings/training

**Solutions:**
1. **Reduce batch size:**
   ```json
   // In knobs.json:
   {
     "BERT": {
       "MiniBatchSize": 48  // Down from 96
     }
   }
   ```

2. **Close other applications**

3. **Use smaller chunks:**
   ```json
   {
     "Chunk": {
       "SizeTokens": 200  // Down from 300
     }
   }
   ```

4. **Upgrade GPU (16GB+ recommended for large datasets)**

### Python Package Installation Fails

**Symptom:** `pip install` errors

**Solutions:**
1. **Upgrade pip:**
   ```bash
   python -m pip install --upgrade pip
   ```

2. **Use --user flag:**
   ```bash
   pip install --user pdfplumber pymupdf pillow
   ```

3. **Install from wheel files:**
   - Download .whl files from https://pypi.org/
   - Install: `pip install package.whl`

4. **Check firewall/proxy settings**

### Database Connection Fails

**Symptom:** Cannot connect to PostgreSQL

**Solutions:**
1. **Check PostgreSQL service:**
   ```bash
   # Linux
   sudo systemctl status postgresql

   # Windows
   services.msc  # Check PostgreSQL service
   ```

2. **Verify credentials:**
   ```matlab
   C = config();
   fprintf('Database: %s@%s:%d/%s\n', ...
       C.db.user, C.db.server, C.db.port, C.db.dbname);
   ```

3. **Check pg_hba.conf:** Allow local connections

4. **Test connection:**
   ```bash
   psql -h localhost -U reguser -d regclassifier
   ```

### Tests Fail

**Symptom:** Some tests fail

**Common Issues:**
1. **Missing fixtures:**
   - Ensure `tests/fixtures/` contains sample PDFs

2. **Network issues:**
   - Some tests may require internet for model downloads

3. **Toolbox issues:**
   - Verify all toolboxes installed

4. **GPU memory:**
   - Some tests may fail if GPU too small

**Debug:**
```matlab
% Run single test with details
results = runtests('tests/TestPDFIngest.m', 'OutputDetail', 'Verbose');
```

---

## Post-Installation

### Download Pre-trained Models

First run will download BERT models (~400MB):

```matlab
% This triggers model download
C = config();
sample_text = "This is a test.";
emb = reg.doc_embeddings_bert_gpu({sample_text}, C);

% Models cached at:
% Windows: C:\Users\<user>\.matlab\SupportPackages\
% Mac: ~/Library/Application Support/MathWorks/MATLAB/
% Linux: ~/.matlab/SupportPackages/
```

### Configure for Your Hardware

**Edit knobs.json based on your GPU:**

```json
{
  "BERT": {
    "MiniBatchSize": 64,   // 8GB GPU
    // "MiniBatchSize": 96,   // 12GB GPU (default)
    // "MiniBatchSize": 128,  // 16GB+ GPU
    "MaxSeqLength": 256
  },
  "Projection": {
    "BatchSize": 512,   // 8GB GPU
    // "BatchSize": 768,   // 12GB GPU (default)
    // "BatchSize": 1024,  // 16GB+ GPU
  }
}
```

### Set Up Python Path (if needed)

If MATLAB can't find Python automatically:

```matlab
% Add to startup.m or set permanently:
setenv('PYTHON_EXECUTABLE', 'C:\Python312\python.exe');  % Windows
% Or
setenv('PYTHON_EXECUTABLE', '/usr/bin/python3');  % Linux/Mac
```

---

## Summary

**Required:**
- ✅ MATLAB R2024a+ with 7 toolboxes
- ✅ NVIDIA GPU with CUDA
- ✅ 20GB+ disk space

**Optional but Recommended:**
- ⭐ Python 3.7+ with pdfplumber, pymupdf, pillow
- ⭐ PostgreSQL (for production)

**Next Steps:**
1. Run verification script above
2. Proceed to [QUICKSTART.md](QUICKSTART.md)
3. Configure for your domain

---

*Last Updated: February 2026*

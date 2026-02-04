function status = check_python_setup()
%CHECK_PYTHON_SETUP Verify Python and required packages are installed.
%   status = CHECK_PYTHON_SETUP()
%   checks if Python and required PDF processing packages are correctly
%   installed and accessible from MATLAB.
%
%   OUTPUTS:
%       status - true if setup is complete, false otherwise
%
%   CHECKS PERFORMED:
%       1. Python executable found
%       2. Python version >= 3.7
%       3. Required packages installed (pdfplumber, pymupdf, pillow)
%       4. Test extraction on sample PDF
%
%   DISPLAYS:
%       - ✓ for passed checks
%       - ✗ for failed checks
%       - Installation instructions if setup incomplete
%
%   EXAMPLE:
%       if reg.check_python_setup()
%           fprintf('Ready to extract PDFs!\n');
%       else
%           fprintf('Please complete Python setup first.\n');
%       end
%
%   SEE ALSO: reg.ingest_pdf_python, docs/PDF_EXTRACTION_GUIDE.md

fprintf('\n========================================\n');
fprintf('  Python Setup Checker for PDF Extraction\n');
fprintf('========================================\n\n');

status = true;

%% Check 1: Python Executable

fprintf('[1/4] Checking for Python executable... ');

python_exe = find_python();

if isempty(python_exe)
    fprintf('✗ FAILED\n');
    fprintf('   Python not found on system PATH.\n\n');
    print_install_instructions();
    status = false;
    return;
else
    fprintf('✓ FOUND\n');
    fprintf('   Location: %s\n', python_exe);
end

%% Check 2: Python Version

fprintf('[2/4] Checking Python version... ');

cmd = sprintf('%s --version', python_exe);
[exit_code, output] = system(cmd);

if exit_code ~= 0
    fprintf('✗ FAILED\n');
    fprintf('   Could not determine Python version.\n\n');
    status = false;
    return;
end

% Parse version
version_match = regexp(output, 'Python (\d+)\.(\d+)\.(\d+)', 'tokens');

if isempty(version_match)
    fprintf('✗ FAILED\n');
    fprintf('   Could not parse Python version from: %s\n', output);
    status = false;
    return;
end

major = str2double(version_match{1}{1});
minor = str2double(version_match{1}{2});

if major < 3 || (major == 3 && minor < 7)
    fprintf('✗ FAILED\n');
    fprintf('   Python %d.%d found, but 3.7+ required.\n', major, minor);
    fprintf('   Please upgrade Python: https://www.python.org/downloads/\n\n');
    status = false;
    return;
else
    fprintf('✓ OK (Python %d.%d)\n', major, minor);
end

%% Check 3: Required Packages

fprintf('[3/4] Checking required packages... \n');

required = struct(...
    'pdfplumber', 'pdfplumber', ...
    'pymupdf', 'fitz', ...
    'pillow', 'PIL');

package_names = fieldnames(required);
missing = {};

for i = 1:numel(package_names)
    pkg_name = package_names{i};
    import_name = required.(pkg_name);

    fprintf('   - %s: ', pkg_name);

    cmd = sprintf('%s -c "import %s"', python_exe, import_name);
    [exit_code, ~] = system(cmd);

    if exit_code == 0
        fprintf('✓ installed\n');
    else
        fprintf('✗ missing\n');
        missing{end+1} = pkg_name;
    end
end

if ~isempty(missing)
    fprintf('\n   Missing packages: %s\n', strjoin(missing, ', '));
    fprintf('\n   Install with:\n');
    fprintf('   pip install %s\n\n', strjoin(missing, ' '));
    status = false;
    return;
end

%% Check 4: Test Extraction

fprintf('[4/4] Testing PDF extraction... ');

% Create a minimal test PDF programmatically
test_pdf = create_test_pdf();

if isempty(test_pdf)
    fprintf('⚠ SKIPPED\n');
    fprintf('   Could not create test PDF (reportgen required).\n');
else
    % Try to extract it
    try
        script_path = fullfile(fileparts(mfilename('fullpath')), '..', 'python', 'extract_regulatory_pdf.py');

        if ~isfile(script_path)
            fprintf('✗ FAILED\n');
            fprintf('   Extraction script not found: %s\n', script_path);
            status = false;
            return;
        end

        temp_output = [tempname '.txt'];

        if ispc
            cmd = sprintf('"%s" "%s" "%s" --output "%s" --quiet', ...
                python_exe, script_path, test_pdf, temp_output);
        else
            cmd = sprintf('%s %s %s --output %s --quiet', ...
                python_exe, script_path, test_pdf, temp_output);
        end

        [exit_code, ~] = system(cmd);

        if exit_code == 0 && isfile(temp_output)
            fprintf('✓ SUCCESS\n');

            % Cleanup
            delete(temp_output);
            delete(test_pdf);
        else
            fprintf('✗ FAILED\n');
            fprintf('   Extraction script returned error code %d\n', exit_code);
            status = false;
            return;
        end

    catch ME
        fprintf('✗ FAILED\n');
        fprintf('   Error: %s\n', ME.message);
        status = false;
        return;
    end
end

%% Summary

fprintf('\n========================================\n');

if status
    fprintf('  ✓ PYTHON SETUP COMPLETE!\n');
    fprintf('========================================\n\n');
    fprintf('You can now use: reg.ingest_pdf_python()\n\n');
else
    fprintf('  ✗ SETUP INCOMPLETE\n');
    fprintf('========================================\n\n');
    fprintf('Please follow installation instructions above.\n');
    fprintf('Full guide: docs/PDF_EXTRACTION_GUIDE.md\n\n');
end

end

%% Helper Functions

function python_exe = find_python()
% Find Python executable

python_exe = '';

% Try common names
python_names = {'python3', 'python', 'python.exe', 'python3.exe'};

for i = 1:numel(python_names)
    [status, ~] = system(sprintf('%s --version 2>&1', python_names{i}));
    if status == 0
        python_exe = python_names{i};
        return;
    end
end
end

function print_install_instructions()
% Print installation instructions

fprintf('\n=== INSTALLATION INSTRUCTIONS ===\n\n');

if ispc
    fprintf('WINDOWS:\n');
    fprintf('1. Go to: https://www.python.org/downloads/\n');
    fprintf('2. Click "Download Python 3.12" (big yellow button)\n');
    fprintf('3. Run installer\n');
    fprintf('4. ✓ CHECK "Add Python to PATH" (CRITICAL!)\n');
    fprintf('5. Click "Install Now"\n');
    fprintf('6. After install, open Command Prompt and run:\n');
    fprintf('   pip install pdfplumber pymupdf pillow\n');
elseif ismac
    fprintf('MAC:\n');
    fprintf('1. Open Terminal (Cmd+Space, type "terminal")\n');
    fprintf('2. Check if Python is installed: python3 --version\n');
    fprintf('3. If not installed, go to: https://www.python.org/downloads/macos/\n');
    fprintf('4. Download and install Python 3.12\n');
    fprintf('5. In Terminal, run:\n');
    fprintf('   pip3 install pdfplumber pymupdf pillow\n');
else
    fprintf('LINUX:\n');
    fprintf('1. Open terminal\n');
    fprintf('2. Install Python:\n');
    fprintf('   sudo apt install python3 python3-pip  # Ubuntu/Debian\n');
    fprintf('   sudo yum install python3 python3-pip  # CentOS/RHEL\n');
    fprintf('3. Install packages:\n');
    fprintf('   pip3 install pdfplumber pymupdf pillow\n');
end

fprintf('\nFull guide: docs/PDF_EXTRACTION_GUIDE.md\n\n');
end

function test_pdf = create_test_pdf()
% Create minimal test PDF

test_pdf = '';

% Check if Report Generator is available
if ~license('test', 'MATLAB_Report_Generator')
    return;
end

try
    % Create temporary PDF with simple content
    test_pdf = [tempname '.pdf'];

    import mlreportgen.dom.*;
    doc = Document(test_pdf, 'pdf');

    append(doc, Paragraph('Test Document'));
    append(doc, Paragraph('This is a test PDF for extraction validation.'));

    close(doc);

    if ~isfile(test_pdf)
        test_pdf = '';
    end

catch
    test_pdf = '';
end
end

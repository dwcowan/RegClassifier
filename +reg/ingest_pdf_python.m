function [textStr, metadata] = ingest_pdf_python(pdfPath, varargin)
%INGEST_PDF_PYTHON Extract text from PDF using Python (handles multi-column).
%   [textStr, metadata] = INGEST_PDF_PYTHON(pdfPath, ...)
%   extracts text from a PDF file using a Python-based extractor that properly
%   handles two-column layouts, mathematical formulas, and complex document
%   structures that MATLAB's built-in PDF reader struggles with.
%
%   INPUTS:
%       pdfPath - Path to PDF file
%
%   NAME-VALUE ARGUMENTS:
%       'Format'        - Output format: 'text' (default) or 'json'
%       'IncludeFormulas' - Extract formulas (default: true)
%       'PythonExe'     - Path to Python executable (auto-detected)
%       'Verbose'       - Display progress (default: true)
%       'CleanupTemp'   - Delete temporary files (default: true)
%
%   OUTPUTS:
%       textStr  - Extracted text as string
%       metadata - Struct with extraction metadata (pages, columns, formulas)
%
%   REQUIREMENTS:
%       - Python 3.7+ with packages: pdfplumber, pymupdf, pillow
%       - See docs/PYTHON_PDF_SETUP.md for installation instructions
%
%   AUTOMATIC SETUP CHECK:
%       This function automatically checks if Python and required packages
%       are installed. If not, it displays installation instructions.
%
%   EXAMPLE 1: Basic extraction
%       [text, meta] = reg.ingest_pdf_python('CRR_regulation.pdf');
%       fprintf('Extracted %d characters from %d pages\n', ...
%           strlength(text), meta.total_pages);
%
%   EXAMPLE 2: Batch processing
%       pdf_files = dir('data/pdfs/*.pdf');
%       for i = 1:numel(pdf_files)
%           [text, meta] = reg.ingest_pdf_python(...
%               fullfile(pdf_files(i).folder, pdf_files(i).name));
%           % Process text...
%       end
%
%   EXAMPLE 3: Use specific Python environment
%       [text, meta] = reg.ingest_pdf_python('document.pdf', ...
%           'PythonExe', 'C:\Anaconda3\envs\regclassifier\python.exe');
%
%   TROUBLESHOOTING:
%       If this function fails, run: reg.check_python_setup()
%       This will diagnose issues and provide fix instructions.
%
%   SEE ALSO: reg.check_python_setup, reg.ingest_pdfs, extractFileText

% Parse arguments
p = inputParser;
addRequired(p, 'pdfPath', @(x) ischar(x) || isstring(x) || isStringScalar(x));
addParameter(p, 'Format', 'text', @(x) ismember(x, {'text', 'json'}));
addParameter(p, 'IncludeFormulas', true, @islogical);
addParameter(p, 'PythonExe', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'Verbose', true, @islogical);
addParameter(p, 'CleanupTemp', true, @islogical);
parse(p, pdfPath, varargin{:});

format_type = p.Results.Format;
include_formulas = p.Results.IncludeFormulas;
python_exe = p.Results.PythonExe;
verbose = p.Results.Verbose;
cleanup_temp = p.Results.CleanupTemp;

% Convert to absolute path
pdfPath = char(pdfPath);
if ~isfile(pdfPath)
    error('reg:ingest_pdf_python:FileNotFound', 'PDF file not found: %s', pdfPath);
end
[~, fname, ext] = fileparts(pdfPath);
pdfPath = GetFullPath(pdfPath);  % Use absolute path

%% Find Python executable

if isempty(python_exe)
    python_exe = find_python_executable();
    if isempty(python_exe)
        error('reg:ingest_pdf_python:PythonNotFound', ...
            ['Python not found. Please install Python 3.7+ or specify path:\n', ...
             '  ingest_pdf_python(..., ''PythonExe'', ''path/to/python'')\n\n', ...
             'Installation guide: docs/PYTHON_PDF_SETUP.md']);
    end
end

if verbose
    fprintf('Using Python: %s\n', python_exe);
end

%% Check if required packages are installed

missing_packages = check_python_packages(python_exe);
if ~isempty(missing_packages)
    error('reg:ingest_pdf_python:MissingPackages', ...
        ['Missing Python packages: %s\n\n', ...
         'Install with: pip install %s\n\n', ...
         'Full setup guide: docs/PYTHON_PDF_SETUP.md'], ...
        strjoin(missing_packages, ', '), strjoin(missing_packages, ' '));
end

%% Find extraction script

script_path = fullfile(fileparts(mfilename('fullpath')), '..', 'python', 'extract_regulatory_pdf.py');
if ~isfile(script_path)
    error('reg:ingest_pdf_python:ScriptNotFound', ...
        'Python extraction script not found: %s', script_path);
end
script_path = GetFullPath(script_path);

%% Create temporary output file

temp_dir = tempdir;
if strcmp(format_type, 'json')
    temp_output = fullfile(temp_dir, sprintf('pdf_extract_%s_%s.json', fname, datestr(now, 'yyyymmdd_HHMMSS')));
else
    temp_output = fullfile(temp_dir, sprintf('pdf_extract_%s_%s.txt', fname, datestr(now, 'yyyymmdd_HHMMSS')));
end

%% Build command

cmd_args = {python_exe, script_path, pdfPath, '--output', temp_output, '--format', format_type};

if ~include_formulas
    cmd_args{end+1} = '--no-formulas';
end

if ~verbose
    cmd_args{end+1} = '--quiet';
end

% Join command
if ispc
    % Windows: use double quotes
    cmd_str = strjoin(cellfun(@(x) sprintf('"%s"', x), cmd_args, 'UniformOutput', false), ' ');
else
    % Unix: use single quotes for paths with spaces
    cmd_str = strjoin(cmd_args, ' ');
end

%% Execute Python script

if verbose
    fprintf('Extracting PDF: %s\n', fname);
    fprintf('Command: %s\n', cmd_str);
end

[status, output] = system(cmd_str);

if status ~= 0
    % Cleanup temp file if it exists
    if isfile(temp_output) && cleanup_temp
        delete(temp_output);
    end

    error('reg:ingest_pdf_python:ExtractionFailed', ...
        'Python extraction failed with status %d.\n\nOutput:\n%s\n\nCommand:\n%s', ...
        status, output, cmd_str);
end

if verbose && ~isempty(output)
    fprintf('%s\n', output);
end

%% Read extracted content

if ~isfile(temp_output)
    error('reg:ingest_pdf_python:OutputNotFound', ...
        'Python script did not create output file: %s', temp_output);
end

try
    if strcmp(format_type, 'json')
        % Read JSON
        fid = fopen(temp_output, 'r', 'n', 'UTF-8');
        json_text = fread(fid, '*char')';
        fclose(fid);

        data = jsondecode(json_text);

        textStr = string(data.full_text);

        % Build metadata struct
        metadata = struct();
        metadata.filename = data.filename;
        metadata.total_pages = data.total_pages;
        metadata.two_column_pages = data.metadata.two_column_pages;
        metadata.single_column_pages = data.metadata.single_column_pages;
        metadata.total_tables = data.metadata.total_tables;
        metadata.total_formulas = data.metadata.total_formulas;
        metadata.pages = data.pages;
        metadata.formulas = data.formulas;

    else
        % Read plain text
        fid = fopen(temp_output, 'r', 'n', 'UTF-8');
        textStr = string(fread(fid, '*char')');
        fclose(fid);

        % Minimal metadata
        metadata = struct();
        metadata.filename = [fname ext];
        metadata.char_count = strlength(textStr);
    end

    if verbose
        fprintf('Successfully extracted %d characters\n', strlength(textStr));
        if isfield(metadata, 'total_pages')
            fprintf('  Pages: %d\n', metadata.total_pages);
            fprintf('  Two-column: %d\n', metadata.two_column_pages);
            fprintf('  Tables: %d\n', metadata.total_tables);
            fprintf('  Formulas: %d\n', metadata.total_formulas);
        end
    end

catch ME
    % Cleanup temp file
    if isfile(temp_output) && cleanup_temp
        delete(temp_output);
    end
    rethrow(ME);
end

%% Cleanup temporary file

if cleanup_temp
    delete(temp_output);
end

end

%% Helper Functions

function python_exe = find_python_executable()
% Find Python executable on system

python_exe = '';

% Try common names
python_names = {'python3', 'python', 'python.exe', 'python3.exe'};

for i = 1:numel(python_names)
    [status, ~] = system(sprintf('%s --version', python_names{i}));
    if status == 0
        python_exe = python_names{i};
        return;
    end
end

% Try common installation paths
if ispc
    % Windows
    common_paths = {
        'C:\Python39\python.exe'
        'C:\Python310\python.exe'
        'C:\Python311\python.exe'
        'C:\Python312\python.exe'
        'C:\Program Files\Python39\python.exe'
        'C:\Program Files\Python310\python.exe'
        'C:\Program Files\Python311\python.exe'
        'C:\Program Files\Python312\python.exe'
        fullfile(getenv('LOCALAPPDATA'), 'Programs\Python\Python39\python.exe')
        fullfile(getenv('LOCALAPPDATA'), 'Programs\Python\Python310\python.exe')
        fullfile(getenv('LOCALAPPDATA'), 'Programs\Python\Python311\python.exe')
        fullfile(getenv('LOCALAPPDATA'), 'Programs\Python\Python312\python.exe')
        'C:\ProgramData\Anaconda3\python.exe'
        fullfile(getenv('USERPROFILE'), 'Anaconda3\python.exe')
        fullfile(getenv('USERPROFILE'), 'Miniconda3\python.exe')
    };
else
    % Unix/Mac
    common_paths = {
        '/usr/bin/python3'
        '/usr/local/bin/python3'
        '/opt/anaconda3/bin/python'
        '/opt/miniconda3/bin/python'
        fullfile(getenv('HOME'), 'anaconda3/bin/python')
        fullfile(getenv('HOME'), 'miniconda3/bin/python')
    };
end

for i = 1:numel(common_paths)
    if isfile(common_paths{i})
        python_exe = common_paths{i};
        return;
    end
end
end

function missing = check_python_packages(python_exe)
% Check if required Python packages are installed

required_packages = {'pdfplumber', 'fitz', 'PIL'};  % fitz=pymupdf, PIL=pillow
missing = {};

for i = 1:numel(required_packages)
    pkg = required_packages{i};
    cmd = sprintf('%s -c "import %s"', python_exe, pkg);

    [status, ~] = system(cmd);

    if status ~= 0
        % Map import names to package names
        if strcmp(pkg, 'fitz')
            missing{end+1} = 'pymupdf';
        elseif strcmp(pkg, 'PIL')
            missing{end+1} = 'pillow';
        else
            missing{end+1} = pkg;
        end
    end
end
end

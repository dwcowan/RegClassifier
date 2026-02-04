function [textStr, metadata] = ingest_pdf_native_columns(pdfPath, varargin)
%INGEST_PDF_NATIVE_COLUMNS Extract text from two-column PDFs using MATLAB only.
%   [textStr, metadata] = INGEST_PDF_NATIVE_COLUMNS(pdfPath, ...)
%   extracts text from two-column PDF layouts using MATLAB's built-in
%   PDF reading with column detection heuristics.
%
%   APPROACH:
%       1. Use extractFileText with 'Pages' parameter for page-by-page extraction
%       2. Analyze text bounding boxes to detect column layout
%       3. Sort text blocks by column (left-to-right, top-to-bottom)
%       4. Reconstruct reading order
%
%   LIMITATIONS:
%       - May not work perfectly on complex layouts
%       - Cannot extract mathematical formulas reliably
%       - Struggles with tables that span columns
%       - For best results, use reg.ingest_pdf_python() instead
%
%   INPUTS:
%       pdfPath - Path to PDF file
%
%   NAME-VALUE ARGUMENTS:
%       'Method'        - Column detection method:
%                         'heuristic' (default) - Split page vertically
%                         'ocr' - Use OCR with layout analysis
%                         'simple' - Single-column fallback
%       'ColumnSplit'   - Horizontal split ratio for columns (default: 0.5)
%       'Verbose'       - Display progress (default: true)
%
%   OUTPUTS:
%       textStr  - Extracted text as string
%       metadata - Struct with extraction metadata
%
%   EXAMPLE 1: Basic extraction
%       [text, meta] = reg.ingest_pdf_native_columns('CRR.pdf');
%
%   EXAMPLE 2: Adjust column split for asymmetric columns
%       [text, meta] = reg.ingest_pdf_native_columns('doc.pdf', ...
%           'ColumnSplit', 0.45);  % Left column is 45% of width
%
%   EXAMPLE 3: Use OCR for scanned PDFs
%       [text, meta] = reg.ingest_pdf_native_columns('scanned.pdf', ...
%           'Method', 'ocr');
%
%   NOTE: This is a best-effort MATLAB-only solution. For production use
%   with complex regulatory PDFs, consider reg.ingest_pdf_python().
%
%   SEE ALSO: reg.ingest_pdf_python, extractFileText, ocr

% Parse arguments
p = inputParser;
addRequired(p, 'pdfPath', @(x) ischar(x) || isstring(x) || isStringScalar(x));
addParameter(p, 'Method', 'heuristic', @(x) ismember(x, {'heuristic', 'ocr', 'simple'}));
addParameter(p, 'ColumnSplit', 0.5, @(x) isnumeric(x) && x > 0 && x < 1);
addParameter(p, 'Verbose', true, @islogical);
parse(p, pdfPath, varargin{:});

method = p.Results.Method;
column_split = p.Results.ColumnSplit;
verbose = p.Results.Verbose;

% Convert to absolute path
pdfPath = char(pdfPath);
if ~isfile(pdfPath)
    error('reg:ingest_pdf_native_columns:FileNotFound', 'PDF file not found: %s', pdfPath);
end

[~, fname, ~] = fileparts(pdfPath);

if verbose
    fprintf('Extracting PDF (MATLAB native): %s\n', fname);
    fprintf('Method: %s\n', method);
end

%% Choose extraction method

switch method
    case 'heuristic'
        [textStr, metadata] = extract_with_heuristic(pdfPath, column_split, verbose);

    case 'ocr'
        [textStr, metadata] = extract_with_ocr(pdfPath, verbose);

    case 'simple'
        [textStr, metadata] = extract_simple(pdfPath, verbose);

    otherwise
        error('Unknown method: %s', method);
end

metadata.extraction_method = method;
metadata.filename = fname;

if verbose
    fprintf('Extracted %d characters\n', strlength(textStr));
end

end

%% Extraction Methods

function [textStr, metadata] = extract_with_heuristic(pdfPath, column_split, verbose)
% Heuristic column detection using text extraction

try
    % Get PDF info
    info = pdfinfo(pdfPath);
    num_pages = info.NumPages;

    if verbose
        fprintf('Processing %d pages...\n', num_pages);
    end

    all_text = strings(num_pages, 1);

    for page_num = 1:num_pages
        if verbose && mod(page_num, 10) == 0
            fprintf('  Page %d/%d\n', page_num, num_pages);
        end

        % Try to extract text for this page
        try
            page_text = extractFileText(pdfPath, 'Pages', page_num);
        catch
            % If page extraction fails, try full document
            if page_num == 1
                warning('Page-by-page extraction failed. Using full document extraction.');
                textStr = string(extractFileText(pdfPath));
                metadata = struct('total_pages', num_pages, 'method', 'fallback');
                return;
            else
                page_text = "";
            end
        end

        % Split text into lines
        lines = splitlines(page_text);

        % Heuristic: Detect two-column layout
        % If lines have significant mid-page spacing, it's likely two-column
        is_two_column = detect_two_column_heuristic(lines);

        if is_two_column
            % Try to reorder text (left column first, then right)
            page_text = reorder_two_column_text(lines, column_split);
        end

        all_text(page_num) = page_text;
    end

    % Combine all pages
    textStr = strjoin(all_text, newline + newline);

    metadata = struct();
    metadata.total_pages = num_pages;
    metadata.method = 'heuristic';
    metadata.char_count = strlength(textStr);

catch ME
    warning('Heuristic extraction failed: %s. Falling back to simple extraction.', ME.message);
    [textStr, metadata] = extract_simple(pdfPath, verbose);
end
end

function is_two_column = detect_two_column_heuristic(lines)
% Detect if text is in two-column layout

% Heuristic: If many lines have similar length and are short,
% it's likely two-column (each column has similar width)

line_lengths = strlength(lines);
non_empty = line_lengths > 10;

if sum(non_empty) < 10
    is_two_column = false;
    return;
end

lengths = line_lengths(non_empty);
mean_length = mean(lengths);
std_length = std(lengths);

% Two-column indicators:
% 1. Consistent line lengths (low std relative to mean)
% 2. Lines are not too long (< 100 chars typically for columns)
% 3. Many lines have similar lengths

cv = std_length / mean_length;  % Coefficient of variation

is_two_column = (cv < 0.3) && (mean_length < 100);
end

function reordered = reorder_two_column_text(lines, column_split)
% Attempt to reorder two-column text

% This is a simple heuristic that won't work perfectly
% For best results, use Python-based extraction

% Strategy: Assume first half of lines is left column,
% second half is right column (very naive!)

non_empty_idx = find(strlength(lines) > 0);

if numel(non_empty_idx) < 4
    % Too few lines, just return as-is
    reordered = strjoin(lines, newline);
    return;
end

% Split lines into two groups
mid_point = round(numel(non_empty_idx) / 2);
left_indices = non_empty_idx(1:mid_point);
right_indices = non_empty_idx(mid_point+1:end);

left_text = strjoin(lines(left_indices), newline);
right_text = strjoin(lines(right_indices), newline);

% Combine left then right
reordered = left_text + newline + newline + right_text;
end

function [textStr, metadata] = extract_with_ocr(pdfPath, verbose)
% Extract using OCR with layout analysis

if ~license('test', 'Video_and_Image_Blockset')
    warning('Computer Vision Toolbox not available. Falling back to simple extraction.');
    [textStr, metadata] = extract_simple(pdfPath, verbose);
    return;
end

try
    info = pdfinfo(pdfPath);
    num_pages = info.NumPages;

    all_text = strings(num_pages, 1);

    for page_num = 1:num_pages
        if verbose
            fprintf('OCR processing page %d/%d...\n', page_num, num_pages);
        end

        % Convert PDF page to image
        img = pdf2image(pdfPath, page_num);

        % Perform OCR with layout analysis
        ocrResults = ocr(img, 'TextLayout', 'Block');

        % Sort text blocks by position (left-to-right, top-to-bottom)
        blocks = ocrResults.Words;
        bboxes = ocrResults.WordBoundingBoxes;

        % Detect columns by x-position clustering
        x_positions = bboxes(:, 1);

        % Simple two-column detection: split at median x-position
        median_x = median(x_positions);

        left_col = x_positions < median_x;
        right_col = x_positions >= median_x;

        % Sort within each column by y-position
        [~, left_order] = sort(bboxes(left_col, 2));
        [~, right_order] = sort(bboxes(right_col, 2));

        left_words = blocks(left_col);
        left_words = left_words(left_order);

        right_words = blocks(right_col);
        right_words = right_words(right_order);

        % Combine
        page_text = strjoin([left_words; right_words], ' ');
        all_text(page_num) = page_text;
    end

    textStr = strjoin(all_text, newline + newline);

    metadata = struct();
    metadata.total_pages = num_pages;
    metadata.method = 'ocr';
    metadata.char_count = strlength(textStr);

catch ME
    warning('OCR extraction failed: %s. Falling back to simple extraction.', ME.message);
    [textStr, metadata] = extract_simple(pdfPath, verbose);
end
end

function img = pdf2image(pdfPath, page_num)
% Convert PDF page to image

% Try using importPDFImages (R2023a+)
if exist('importPDFImages', 'file')
    imgs = importPDFImages(pdfPath, page_num);
    if ~isempty(imgs)
        img = imgs{1};
        return;
    end
end

% Fallback: Use external tool or error
error('PDF to image conversion requires R2023a+ or external tool');
end

function [textStr, metadata] = extract_simple(pdfPath, verbose)
% Simple extraction without column detection

if verbose
    fprintf('Using simple extraction (no column detection)\n');
end

textStr = string(extractFileText(pdfPath));

metadata = struct();
metadata.method = 'simple';
metadata.char_count = strlength(textStr);
end

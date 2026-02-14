function regenerate_fixture_pdfs()
%REGENERATE_FIXTURE_PDFS Create test fixture PDFs with expected content.
%   Creates sim_text.pdf (text-based) and sim_image_only.pdf (image-based)
%   in the tests/+fixtures directory.

import mlreportgen.report.*
import mlreportgen.dom.*

% Get the directory where this script lives
scriptDir = fileparts(mfilename('fullpath'));

%% Generate sim_text.pdf - Text-based PDF
fprintf('Generating sim_text.pdf...\n');
textPdfPath = fullfile(scriptDir, 'sim_text');
r1 = Report(textPdfPath, 'pdf');

% Add title
append(r1, TitlePage('Title', 'Simulated Regulatory Document'));

% Add regulatory content that tests expect
sec1 = Section('Internal Ratings Based (IRB) Approach');
para1 = Paragraph(['The Internal Ratings Based (IRB) approach introduces ' ...
    'Probability of Default (PD), Loss Given Default (LGD), and Exposure at Default (EAD). ' ...
    'Banks using the IRB approach must meet minimum requirements for rating systems, ' ...
    'risk quantification, and corporate governance.']);
append(sec1, para1);
append(r1, sec1);

sec2 = Section('Liquidity Coverage Ratio (LCR)');
para2 = Paragraph(['The Liquidity Coverage Ratio requires institutions to hold ' ...
    'sufficient High-Quality Liquid Assets (HQLA) to cover net cash outflows ' ...
    'over a 30-day stress period.']);
append(sec2, para2);
append(r1, sec2);

sec3 = Section('AML/KYC Requirements');
para3 = Paragraph(['Anti-Money Laundering (AML) and Know Your Customer (KYC) ' ...
    'controls require customer due diligence, ongoing monitoring, and ' ...
    'suspicious activity reporting.']);
append(sec3, para3);
append(r1, sec3);

% Generate the report
close(r1);
fprintf('Created: %s\n', [textPdfPath '.pdf']);

%% Generate sim_image_only.pdf - Image-based PDF
fprintf('Generating sim_image_only.pdf...\n');
imagePdfPath = fullfile(scriptDir, 'sim_image_only');
r2 = Report(imagePdfPath, 'pdf');

% Create an image with text (will require OCR to extract)
% We'll create a simple figure with text and save it as an image
fig = figure('Visible', 'off', 'Position', [100 100 800 600]);
axis off;
text(0.5, 0.7, 'Regulatory Text Document', ...
    'FontSize', 24, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center');
text(0.5, 0.5, 'Internal Ratings Based approach', ...
    'FontSize', 16, 'HorizontalAlignment', 'center');
text(0.5, 0.3, 'Liquidity Coverage Ratio requirements', ...
    'FontSize', 16, 'HorizontalAlignment', 'center');
xlim([0 1]);
ylim([0 1]);

% Save as image
imgPath = fullfile(tempdir, 'fixture_image.png');
saveas(fig, imgPath);
close(fig);

% Add image to PDF
append(r2, TitlePage('Title', 'Image-Based Regulatory Document'));
img = Image(imgPath);
img.Width = '6in';
img.Height = '4.5in';
append(r2, img);

% Generate the report
close(r2);
fprintf('Created: %s\n', [imagePdfPath '.pdf']);

% Clean up temp image
delete(imgPath);

fprintf('Fixture PDFs regenerated successfully!\n');
end

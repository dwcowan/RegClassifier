%RUN_DEMO Quick launcher for methodology fixes demo.
%
%   This script runs the comprehensive demonstration of all 16 methodology
%   fixes implemented in the methodological review.
%
%   USAGE:
%       RUN_DEMO
%
%   RUNTIME: 10-15 minutes
%
%   OUTPUT:
%       - Console output showing all features
%       - Figures showing validation results
%       - Performance metrics for each component
%
%   SEE ALSO: demo_all_methodology_fixes

clear all; close all; clc;

fprintf('\n');
fprintf('Starting comprehensive methodology fixes demo...\n');
fprintf('Expected runtime: 10-15 minutes\n');
fprintf('\n');
fprintf('Press any key to continue...\n');
pause;

% Run the demo
demo_all_methodology_fixes;

fprintf('\nDemo complete!\n');
fprintf('\nTo run the full production pipeline with real PDFs:\n');
fprintf('  1. Place PDF files in data/pdfs/\n');
fprintf('  2. Run: reg_pipeline\n');
fprintf('\n');

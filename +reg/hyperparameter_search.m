function [best_config, results] = hyperparameter_search(objective_fn, param_space, varargin)
%HYPERPARAMETER_SEARCH Systematic hyperparameter optimization.
%   [best_config, results] = HYPERPARAMETER_SEARCH(objective_fn, param_space)
%   performs systematic hyperparameter search using grid search, random search,
%   or Bayesian optimization.
%
%   INPUTS:
%       objective_fn  - Function handle: @(config) -> score (higher is better)
%       param_space   - Struct defining parameter ranges
%                       Each field: [min, max] for continuous
%                                   [val1, val2, ...] for discrete
%
%   NAME-VALUE ARGUMENTS:
%       'Method'       - Search method: 'grid', 'random', 'bayes' (default: 'random')
%       'MaxEvals'     - Maximum evaluations (default: 50)
%       'Verbose'      - Display progress (default: true)
%       'SaveProgress' - Save intermediate results (default: true)
%       'OutputFile'   - Filename for results (default: 'hyperparam_search_results.mat')
%       'Parallel'     - Use parallel evaluation (default: false)
%
%   OUTPUTS:
%       best_config - Struct with best hyperparameter configuration
%       results     - Struct with all configurations and scores:
%                     .configs      - Cell array of all configs
%                     .scores       - Vector of all scores
%                     .best_idx     - Index of best configuration
%                     .best_score   - Best score achieved
%                     .method       - Search method used
%                     .elapsed_time - Total search time
%
%   EXAMPLE 1: Random search for fine-tuning hyperparameters
%       param_space = struct(...
%           'EncoderLR', [1e-6, 1e-4], ...     % Log-uniform
%           'HeadLR', [1e-4, 1e-2], ...
%           'Margin', [0.1, 1.0], ...
%           'UnfreezeTopLayers', [2, 8]);      % Integer
%
%       objective = @(config) evaluate_config_zero_budget(config);
%       [best, results] = reg.hyperparameter_search(objective, param_space, ...
%           'Method', 'random', 'MaxEvals', 50);
%
%   EXAMPLE 2: Grid search (exhaustive, smaller space)
%       param_space = struct(...
%           'Alpha', [0.1, 0.3, 0.5, 0.7], ...  % Discrete values
%           'K', [5, 10, 20]);
%
%       objective = @(config) evaluate_hybrid_search(config);
%       [best, results] = reg.hyperparameter_search(objective, param_space, ...
%           'Method', 'grid');
%
%   EXAMPLE 3: Bayesian optimization (most efficient)
%       param_space = struct(...
%           'LR', [1e-5, 1e-2], ...
%           'BatchSize', [16, 128], ...
%           'Dropout', [0.0, 0.5]);
%
%       objective = @(config) train_and_validate(config);
%       [best, results] = reg.hyperparameter_search(objective, param_space, ...
%           'Method', 'bayes', 'MaxEvals', 100);
%
%   EXAMPLE 4: With zero-budget validation
%       % Use split-rule F1 as objective
%       objective = @(config) zero_budget_f1(config);
%       [best, results] = reg.hyperparameter_search(objective, param_space);
%
%   PARAMETER SAMPLING:
%       - Learning rates: Log-uniform sampling (better coverage)
%       - Other continuous: Uniform sampling
%       - Integer parameters: Rounded to nearest integer
%       - Discrete: Random selection from provided values
%
%   METHODOLOGICAL ISSUE ADDRESSED:
%       Issue #8 (MEDIUM): Hyperparameter tuning
%       Original approach: Manual, heuristic parameter choices
%       This fix: Systematic search with validation-based tuning
%       Expected: 3-5% improvement from proper tuning
%
%   SEE ALSO: bayesopt, optimizableVariable

% Parse arguments
p = inputParser;
addParameter(p, 'Method', 'random', @(x) ismember(x, {'grid', 'random', 'bayes'}));
addParameter(p, 'MaxEvals', 50, @(x) isnumeric(x) && x > 0);
addParameter(p, 'Verbose', true, @islogical);
addParameter(p, 'SaveProgress', true, @islogical);
addParameter(p, 'OutputFile', 'hyperparam_search_results.mat', @ischar);
addParameter(p, 'Parallel', false, @islogical);
parse(p, varargin{:});

method = p.Results.Method;
max_evals = p.Results.MaxEvals;
verbose = p.Results.Verbose;
save_progress = p.Results.SaveProgress;
output_file = p.Results.OutputFile;
use_parallel = p.Results.Parallel;

% Validate inputs
if ~isa(objective_fn, 'function_handle')
    error('reg:hyperparameter_search:InvalidObjective', ...
        'objective_fn must be a function handle');
end

if ~isstruct(param_space)
    error('reg:hyperparameter_search:InvalidParamSpace', ...
        'param_space must be a struct');
end

% Start timer
tic;

if verbose
    fprintf('\n=== Hyperparameter Search ===\n');
    fprintf('Method: %s\n', method);
    fprintf('Max evaluations: %d\n', max_evals);
    fprintf('Parallel: %s\n', mat2str(use_parallel));
    fprintf('\nParameter space:\n');
    param_names = fieldnames(param_space);
    for i = 1:numel(param_names)
        name = param_names{i};
        range = param_space.(name);
        if numel(range) == 2
            fprintf('  %s: [%.2e, %.2e]\n', name, range(1), range(2));
        else
            fprintf('  %s: %s\n', name, mat2str(range));
        end
    end
    fprintf('\n');
end

% Dispatch to appropriate search method
switch method
    case 'grid'
        [best_config, results] = grid_search(objective_fn, param_space, max_evals, verbose, use_parallel);
    case 'random'
        [best_config, results] = random_search(objective_fn, param_space, max_evals, verbose, use_parallel);
    case 'bayes'
        [best_config, results] = bayesian_search(objective_fn, param_space, max_evals, verbose);
end

% Add metadata
results.method = method;
results.elapsed_time = toc;
results.param_space = param_space;

% Save results
if save_progress
    save(output_file, 'best_config', 'results');
    if verbose
        fprintf('\nResults saved to: %s\n', output_file);
    end
end

if verbose
    fprintf('\n=== Search Complete ===\n');
    fprintf('Total time: %.1f seconds\n', results.elapsed_time);
    fprintf('Best score: %.4f\n', results.best_score);
    fprintf('\nBest configuration:\n');
    disp(best_config);
end

end

% =========================================================================
% RANDOM SEARCH
% =========================================================================
function [best_config, results] = random_search(objective_fn, param_space, max_evals, verbose, use_parallel)
%RANDOM_SEARCH Sample parameters randomly from distributions.

param_names = fieldnames(param_space);
num_params = numel(param_names);

configs = cell(max_evals, 1);
scores = zeros(max_evals, 1);

if verbose
    fprintf('Starting random search (%d evaluations)...\n', max_evals);
end

% Generate all configurations first (for parallel evaluation)
for trial = 1:max_evals
    configs{trial} = sample_config(param_space, param_names);
end

% Evaluate configurations
if use_parallel
    % Parallel evaluation
    parfor trial = 1:max_evals
        try
            scores(trial) = objective_fn(configs{trial});
        catch ME
            warning('Trial %d failed: %s', trial, ME.message);
            scores(trial) = -inf;
        end
    end

    % Display results after parallel execution
    if verbose
        for trial = 1:max_evals
            fprintf('[%3d/%3d] Score: %.4f\n', trial, max_evals, scores(trial));
        end
    end
else
    % Sequential evaluation with progress display
    for trial = 1:max_evals
        try
            scores(trial) = objective_fn(configs{trial});

            if verbose
                fprintf('[%3d/%3d] Score: %.4f | ', trial, max_evals, scores(trial));
                % Show first 3 params
                for i = 1:min(3, num_params)
                    name = param_names{i};
                    val = configs{trial}.(name);
                    if val < 0.01
                        fprintf('%s=%.2e ', name, val);
                    else
                        fprintf('%s=%.3f ', name, val);
                    end
                end
                fprintf('\n');
            end
        catch ME
            warning('Trial %d failed: %s', trial, ME.message);
            scores(trial) = -inf;
        end
    end
end

% Find best
[best_score, best_idx] = max(scores);
best_config = configs{best_idx};

results = struct();
results.configs = configs;
results.scores = scores;
results.best_idx = best_idx;
results.best_score = best_score;

end

% =========================================================================
% GRID SEARCH
% =========================================================================
function [best_config, results] = grid_search(objective_fn, param_space, max_evals, verbose, use_parallel)
%GRID_SEARCH Exhaustive search over discrete grid.

param_names = fieldnames(param_space);
num_params = numel(param_names);

% Build grid
grid_values = cell(num_params, 1);
for i = 1:num_params
    vals = param_space.(param_names{i});
    if numel(vals) == 2 && vals(1) < vals(2)
        % Continuous range: create discrete grid
        num_points = max(3, round(max_evals^(1/num_params)));
        grid_values{i} = linspace(vals(1), vals(2), num_points);
    else
        % Already discrete
        grid_values{i} = vals;
    end
end

% Generate all combinations
grid_combos = cell(1, num_params);
[grid_combos{:}] = ndgrid(grid_values{:});

% Flatten
total_configs = numel(grid_combos{1});
if total_configs > max_evals
    warning('Grid has %d points, limiting to %d (random subset)', ...
        total_configs, max_evals);
    sample_idx = randperm(total_configs, max_evals);
else
    sample_idx = 1:total_configs;
end

configs = cell(numel(sample_idx), 1);
for i = 1:numel(sample_idx)
    idx = sample_idx(i);
    config = struct();
    for j = 1:num_params
        config.(param_names{j}) = grid_combos{j}(idx);
    end
    configs{i} = config;
end

if verbose
    fprintf('Grid search: %d configurations\n', numel(configs));
end

% Evaluate (reuse random_search evaluation logic)
scores = zeros(numel(configs), 1);

if use_parallel
    parfor i = 1:numel(configs)
        try
            scores(i) = objective_fn(configs{i});
        catch ME
            warning('Config %d failed: %s', i, ME.message);
            scores(i) = -inf;
        end
    end

    if verbose
        for i = 1:numel(configs)
            fprintf('[%3d/%3d] Score: %.4f\n', i, numel(configs), scores(i));
        end
    end
else
    for i = 1:numel(configs)
        try
            scores(i) = objective_fn(configs{i});
            if verbose
                fprintf('[%3d/%3d] Score: %.4f\n', i, numel(configs), scores(i));
            end
        catch ME
            warning('Config %d failed: %s', i, ME.message);
            scores(i) = -inf;
        end
    end
end

[best_score, best_idx] = max(scores);
best_config = configs{best_idx};

results = struct();
results.configs = configs;
results.scores = scores;
results.best_idx = best_idx;
results.best_score = best_score;

end

% =========================================================================
% BAYESIAN OPTIMIZATION
% =========================================================================
function [best_config, results] = bayesian_search(objective_fn, param_space, max_evals, verbose)
%BAYESIAN_SEARCH Use MATLAB's bayesopt for efficient search.

param_names = fieldnames(param_space);
optimizable_vars = [];

for i = 1:numel(param_names)
    name = param_names{i};
    range = param_space.(name);

    if numel(range) == 2
        % Continuous range
        if contains(name, 'LR', 'IgnoreCase', true) || contains(name, 'Rate', 'IgnoreCase', true)
            % Log-scale for learning rates
            var = optimizableVariable(name, range, 'Transform', 'log');
        elseif contains(name, 'Layers', 'IgnoreCase', true) || ...
               contains(name, 'Epochs', 'IgnoreCase', true) || ...
               contains(name, 'Size', 'IgnoreCase', true) || ...
               contains(name, 'Batch', 'IgnoreCase', true)
            % Integer for counts
            var = optimizableVariable(name, round(range), 'Type', 'integer');
        else
            % Continuous for others
            var = optimizableVariable(name, range);
        end
    else
        % Categorical
        var = optimizableVariable(name, range, 'Type', 'categorical');
    end

    optimizable_vars = [optimizable_vars; var];
end

% Wrap objective to minimize (bayesopt minimizes)
objective_wrapper = @(params) -objective_fn(table2struct(params));

% Run Bayesian optimization
bayes_results = bayesopt(objective_wrapper, optimizable_vars, ...
    'MaxObjectiveEvaluations', max_evals, ...
    'IsObjectiveDeterministic', false, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'Verbose', double(verbose), ...
    'PlotFcn', []);

best_config = table2struct(bayes_results.XAtMinObjective);

results = struct();
results.bayes_results = bayes_results;
results.best_score = -bayes_results.MinObjective;
results.best_config = best_config;
results.configs = cell(bayes_results.NumObjectiveEvaluations, 1);
results.scores = -bayes_results.ObjectiveTrace;

% Extract all evaluated configs
for i = 1:bayes_results.NumObjectiveEvaluations
    results.configs{i} = table2struct(bayes_results.XTrace(i,:));
end

results.best_idx = find(results.scores == max(results.scores), 1);

end

% =========================================================================
% HELPER: Sample Configuration
% =========================================================================
function config = sample_config(param_space, param_names)
%SAMPLE_CONFIG Sample a random configuration from param_space.

config = struct();
for i = 1:numel(param_names)
    name = param_names{i};
    range = param_space.(name);

    if numel(range) == 2 && isnumeric(range)
        % Continuous range
        if contains(name, 'LR', 'IgnoreCase', true) || contains(name, 'Rate', 'IgnoreCase', true)
            % Log-uniform for learning rates
            log_min = log10(range(1));
            log_max = log10(range(2));
            config.(name) = 10^(unifrnd(log_min, log_max));
        else
            % Uniform for others
            config.(name) = unifrnd(range(1), range(2));
        end

        % Round if parameter suggests integer
        if contains(name, 'Layers', 'IgnoreCase', true) || ...
           contains(name, 'Epochs', 'IgnoreCase', true) || ...
           contains(name, 'Size', 'IgnoreCase', true) || ...
           contains(name, 'Batch', 'IgnoreCase', true) || ...
           contains(name, 'Dim', 'IgnoreCase', true)
            config.(name) = round(config.(name));
        end
    else
        % Discrete: random selection
        config.(name) = range(randi(numel(range)));
    end
end

end

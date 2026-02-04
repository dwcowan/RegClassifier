function [reward_model, stats] = train_reward_model(features, human_feedback, varargin)
%TRAIN_REWARD_MODEL Train reward model from human feedback (RLHF-style).
%   [model, stats] = TRAIN_REWARD_MODEL(features, human_feedback, ...)
%   trains a neural network to predict human preference/quality scores,
%   enabling RLHF-style reinforcement learning from human feedback.
%
%   INPUTS:
%       features       - Feature matrix (N x D) for annotated chunks
%       human_feedback - Human quality scores (N x 1) in range [0, 1]
%                        OR binary preferences (N x 1) with values 0 or 1
%
%   NAME-VALUE ARGUMENTS:
%       'ModelType'    - Network architecture:
%                        'regression' (default) - Predict continuous quality
%                        'binary' - Predict binary preference
%       'HiddenSizes'  - Hidden layer sizes (default: [256, 128, 64])
%       'Epochs'       - Training epochs (default: 100)
%       'MiniBatchSize' - Batch size (default: 32)
%       'ValidationFraction' - Fraction for validation (default: 0.2)
%       'Verbose'      - Display training progress (default: true)
%
%   OUTPUTS:
%       reward_model - Trained network for reward prediction
%       stats        - Training statistics struct
%
%   USE CASES:
%
%   1. Quality Scoring:
%      Human annotators rate chunks on quality (0-1 scale)
%      Model learns to predict quality from features
%
%   2. Preference Learning:
%      Human chooses between pairs of chunks (binary preference)
%      Model learns which chunks are more valuable to annotate
%
%   3. Agreement Scoring:
%      Compute agreement between model and human labels
%      Model learns to predict when it will agree with humans
%
%   EXAMPLE 1: Train from quality ratings
%       % Humans rate 100 chunks on quality (0=poor, 1=excellent)
%       quality_scores = [0.3; 0.8; 0.6; ...];  % Human ratings
%
%       [reward_model, stats] = reg.rl.train_reward_model(...
%           features(annotated_idx,:), quality_scores, 'ModelType', 'regression');
%
%       % Use model to score all chunks
%       predicted_quality = predict(reward_model, features);
%
%       % Annotate lowest quality chunks first
%       [~, priority_order] = sort(predicted_quality);
%
%   EXAMPLE 2: Train from binary preferences
%       % Human prefers chunk A over B (1) or not (0)
%       preferences = [1; 0; 1; ...];  % Binary preferences
%
%       [reward_model, stats] = reg.rl.train_reward_model(...
%           features(annotated_idx,:), preferences, 'ModelType', 'binary');
%
%   EXAMPLE 3: Train from agreement scores
%       % Compute agreement between model predictions and human labels
%       agreement = sum(predictions(annotated_idx,:) == Ytrue, 2) / numel(labels);
%
%       [reward_model, stats] = reg.rl.train_reward_model(...
%           features(annotated_idx,:), agreement);
%
%       % Predict which chunks will have low agreement (high value to annotate)
%       predicted_agreement = predict(reward_model, features);
%       [~, to_annotate] = sort(predicted_agreement);  % Low agreement first
%
%   INTEGRATION WITH RL:
%       Use reward model to provide shaped rewards for RL agent:
%
%       % Train reward model from initial annotations
%       [reward_model, ~] = reg.rl.train_reward_model(features(annotated,:), quality);
%
%       % Use in RL environment to predict rewards before getting human feedback
%       predicted_reward = predict(reward_model, features(candidate_chunk,:));
%
%   REFERENCES:
%       Christiano et al. 2017 - Deep RL from Human Preferences
%       Ouyang et al. 2022 - Training language models to follow instructions
%                            with human feedback (InstructGPT)
%
%   SEE ALSO: reg.rl.train_annotation_agent, reg.rl.AnnotationEnvironment

% Parse arguments
p = inputParser;
addParameter(p, 'ModelType', 'regression', @(x) ismember(x, {'regression', 'binary'}));
addParameter(p, 'HiddenSizes', [256, 128, 64], @(x) isnumeric(x) && all(x > 0));
addParameter(p, 'Epochs', 100, @(x) x > 0);
addParameter(p, 'MiniBatchSize', 32, @(x) x > 0);
addParameter(p, 'ValidationFraction', 0.2, @(x) x >= 0 && x < 1);
addParameter(p, 'Verbose', true, @islogical);
parse(p, varargin{:});

model_type = p.Results.ModelType;
hidden_sizes = p.Results.HiddenSizes;
epochs = p.Results.Epochs;
minibatch_size = p.Results.MiniBatchSize;
val_fraction = p.Results.ValidationFraction;
verbose = p.Results.Verbose;

% Validate inputs
N = size(features, 1);
D = size(features, 2);

if numel(human_feedback) ~= N
    error('reg:rl:train_reward_model:SizeMismatch', ...
        'human_feedback must have same length as features (N=%d)', N);
end

human_feedback = human_feedback(:);  % Column vector

if verbose
    fprintf('\n=== Training Reward Model from Human Feedback ===\n');
    fprintf('Model Type:    %s\n', model_type);
    fprintf('Samples:       %d\n', N);
    fprintf('Features:      %d dimensions\n', D);
    fprintf('Hidden Layers: [%s]\n', num2str(hidden_sizes));
    fprintf('Epochs:        %d\n', epochs);
    fprintf('\n');
end

%% Build Network Architecture

layers = [featureInputLayer(D, 'Name', 'input')];

for i = 1:numel(hidden_sizes)
    layers = [layers
        fullyConnectedLayer(hidden_sizes(i), 'Name', sprintf('fc%d', i))
        reluLayer('Name', sprintf('relu%d', i))
        dropoutLayer(0.2, 'Name', sprintf('dropout%d', i))
    ];
end

% Output layer depends on model type
if strcmp(model_type, 'regression')
    % Regression: predict continuous quality score [0,1]
    layers = [layers
        fullyConnectedLayer(1, 'Name', 'output')
        sigmoidLayer('Name', 'sigmoid')  % Constrain to [0,1]
    ];
else
    % Binary classification: predict preference (0 or 1)
    layers = [layers
        fullyConnectedLayer(2, 'Name', 'output')
        softmaxLayer('Name', 'softmax')
    ];
end

if strcmp(model_type, 'binary')
    layers = [layers
        classificationLayer('Name', 'classification')
    ];
else
    layers = [layers
        regressionLayer('Name', 'regression')
    ];
end

%% Training Options

if strcmp(model_type, 'regression')
    options = trainingOptions('adam', ...
        'MaxEpochs', epochs, ...
        'MiniBatchSize', minibatch_size, ...
        'ValidationFrequency', 10, ...
        'ValidationData', {}, ...  % Will add below
        'Shuffle', 'every-epoch', ...
        'Verbose', verbose, ...
        'Plots', 'training-progress', ...
        'InitialLearnRate', 1e-3, ...
        'LearnRateSchedule', 'piecewise', ...
        'LearnRateDropFactor', 0.5, ...
        'LearnRateDropPeriod', 30);
else
    options = trainingOptions('adam', ...
        'MaxEpochs', epochs, ...
        'MiniBatchSize', minibatch_size, ...
        'ValidationFrequency', 10, ...
        'ValidationData', {}, ...
        'Shuffle', 'every-epoch', ...
        'Verbose', verbose, ...
        'Plots', 'training-progress', ...
        'InitialLearnRate', 1e-3, ...
        'LearnRateSchedule', 'piecewise', ...
        'LearnRateDropFactor', 0.5, ...
        'LearnRateDropPeriod', 30, ...
        'Metrics', 'accuracy');
end

if ~verbose
    options.Plots = 'none';
    options.Verbose = false;
end

%% Split Training/Validation

if val_fraction > 0
    cv = cvpartition(N, 'HoldOut', val_fraction);
    train_idx = training(cv);
    val_idx = test(cv);

    X_train = features(train_idx, :);
    y_train = human_feedback(train_idx);
    X_val = features(val_idx, :);
    y_val = human_feedback(val_idx);

    if strcmp(model_type, 'binary')
        % Convert to categorical
        y_train_cat = categorical(y_train);
        y_val_cat = categorical(y_val);
        options.ValidationData = {X_val, y_val_cat};
    else
        options.ValidationData = {X_val, y_val};
    end
else
    X_train = features;
    y_train = human_feedback;
end

%% Train Model

if verbose
    fprintf('Training reward model...\n');
end

if strcmp(model_type, 'binary')
    y_train_cat = categorical(y_train);
    reward_model = trainNetwork(X_train, y_train_cat, layers, options);
else
    reward_model = trainNetwork(X_train, y_train, layers, options);
end

if verbose
    fprintf('Training complete!\n\n');
end

%% Evaluate Model

if val_fraction > 0
    if strcmp(model_type, 'regression')
        % Regression metrics
        y_pred = predict(reward_model, X_val);

        mse = mean((y_pred - y_val).^2);
        mae = mean(abs(y_pred - y_val));
        r2 = 1 - sum((y_val - y_pred).^2) / sum((y_val - mean(y_val)).^2);

        stats.mse = mse;
        stats.mae = mae;
        stats.r2 = r2;

        if verbose
            fprintf('=== Validation Performance ===\n');
            fprintf('MSE:  %.4f\n', mse);
            fprintf('MAE:  %.4f\n', mae);
            fprintf('R²:   %.4f\n\n', r2);
        end
    else
        % Classification metrics
        y_pred_class = classify(reward_model, X_val);
        accuracy = sum(y_pred_class == categorical(y_val)) / numel(y_val);

        stats.accuracy = accuracy;

        if verbose
            fprintf('=== Validation Performance ===\n');
            fprintf('Accuracy: %.2f%%\n\n', accuracy * 100);
        end
    end
else
    stats = struct();
end

stats.model_type = model_type;
stats.num_samples = N;
stats.num_features = D;
stats.hidden_sizes = hidden_sizes;

end

function [reward_model, stats] = train_reward_model(features_preferred, features_rejected, varargin)
%TRAIN_REWARD_MODEL Train reward model from pairwise human preferences (RLHF).
%   [model, stats] = TRAIN_REWARD_MODEL(features_preferred, features_rejected, ...)
%   trains a neural network reward model using the Bradley-Terry pairwise
%   preference framework, the standard approach for RLHF.
%
%   INPUTS:
%       features_preferred - Feature matrix (N x D) for preferred samples
%       features_rejected  - Feature matrix (N x D) for rejected samples
%                            Each row i forms a pair: preferred(i) > rejected(i)
%
%   NAME-VALUE ARGUMENTS:
%       'HiddenSizes'  - Hidden layer sizes (default: [256, 128, 64])
%       'Epochs'       - Training epochs (default: 100)
%       'MiniBatchSize' - Batch size (default: 32)
%       'ValidationFraction' - Fraction for validation (default: 0.2)
%       'ValidationPatience' - Early stopping patience (default: 10)
%       'Verbose'      - Display training progress (default: true)
%
%   OUTPUTS:
%       reward_model - Trained dlnetwork that outputs a scalar reward
%       stats        - Training statistics struct
%
%   PAIRWISE PREFERENCE FRAMEWORK (Bradley-Terry):
%       Given pairs (x_preferred, x_rejected), the model learns a reward
%       function r(x) such that r(x_preferred) > r(x_rejected).
%
%       Loss = -mean(log(sigmoid(r(x_preferred) - r(x_rejected))))
%
%       This is more reliable than pointwise scoring because:
%       - Humans are more consistent at comparisons than absolute ratings
%       - No need to calibrate scores across annotators
%       - Standard in RLHF (Christiano et al. 2017, Ouyang et al. 2022)
%
%   EXAMPLE 1: Train from pairwise preferences
%       % Annotator chose chunk A over B in each pair
%       [reward_model, stats] = reg.rl.train_reward_model(...
%           features(preferred_idx,:), features(rejected_idx,:));
%
%       % Score all chunks
%       all_rewards = predict_reward(reward_model, features);
%       [~, priority] = sort(all_rewards, 'descend');
%
%   EXAMPLE 2: Convert pointwise ratings to pairs
%       % If you have pointwise scores, convert to pairs
%       pairs = nchoosek(1:N, 2);
%       better = scores(pairs(:,1)) > scores(pairs(:,2));
%       pref_idx = pairs(better, 1); rej_idx = pairs(better, 2);
%       % Swap where second is better
%       pref_idx(~better) = pairs(~better, 2);
%       rej_idx(~better) = pairs(~better, 1);
%
%   INTEGRATION WITH RL:
%       % Train reward model from initial annotations
%       [reward_model, ~] = reg.rl.train_reward_model(feat_pref, feat_rej);
%
%       % Use in RL environment to predict rewards
%       predicted_reward = predict_reward(reward_model, features(candidate,:));
%
%   REFERENCES:
%       Christiano et al. 2017 - Deep RL from Human Preferences
%       Ouyang et al. 2022 - Training language models to follow instructions
%                            with human feedback (InstructGPT)
%       Bradley & Terry 1952 - Rank Analysis of Incomplete Block Designs
%
%   SEE ALSO: reg.rl.train_annotation_agent, reg.rl.AnnotationEnvironment,
%             predict_reward

% Parse arguments
p = inputParser;
addParameter(p, 'HiddenSizes', [256, 128, 64], @(x) isnumeric(x) && all(x > 0));
addParameter(p, 'Epochs', 100, @(x) x > 0);
addParameter(p, 'MiniBatchSize', 32, @(x) x > 0);
addParameter(p, 'ValidationFraction', 0.2, @(x) x >= 0 && x < 1);
addParameter(p, 'ValidationPatience', 10, @(x) x > 0);
addParameter(p, 'Verbose', true, @islogical);
parse(p, varargin{:});

hidden_sizes = p.Results.HiddenSizes;
epochs = p.Results.Epochs;
minibatch_size = p.Results.MiniBatchSize;
val_fraction = p.Results.ValidationFraction;
patience = p.Results.ValidationPatience;
verbose = p.Results.Verbose;

% Validate inputs
N = size(features_preferred, 1);
D = size(features_preferred, 2);

if size(features_rejected, 1) ~= N || size(features_rejected, 2) ~= D
    error('reg:rl:train_reward_model:SizeMismatch', ...
        'features_preferred and features_rejected must have same size (N=%d, D=%d)', N, D);
end

if verbose
    fprintf('\n=== Training Pairwise Reward Model (Bradley-Terry) ===\n');
    fprintf('Preference pairs: %d\n', N);
    fprintf('Features:         %d dimensions\n', D);
    fprintf('Hidden Layers:    [%s]\n', num2str(hidden_sizes));
    fprintf('Epochs:           %d\n', epochs);
    fprintf('Early stopping:   patience=%d\n', patience);
    fprintf('\n');
end

%% Build Reward Network (scalar output, no sigmoid -- linear for reward)
layers = [featureInputLayer(D, 'Name', 'input')];

for i = 1:numel(hidden_sizes)
    layers = [layers
        fullyConnectedLayer(hidden_sizes(i), 'Name', sprintf('fc%d', i))
        reluLayer('Name', sprintf('relu%d', i))
        dropoutLayer(0.2, 'Name', sprintf('dropout%d', i))
    ];
end

% Linear scalar output (reward value, unconstrained range)
layers = [layers
    fullyConnectedLayer(1, 'Name', 'reward_output')
];

reward_net = dlnetwork(layers);

%% Split Training/Validation
if val_fraction > 0 && N > 10
    cv = cvpartition(N, 'HoldOut', val_fraction);
    train_idx = find(training(cv));
    val_idx = find(test(cv));
else
    train_idx = (1:N)';
    val_idx = [];
end

X_pref_train = features_preferred(train_idx, :);
X_rej_train = features_rejected(train_idx, :);
X_pref_val = features_preferred(val_idx, :);
X_rej_val = features_rejected(val_idx, :);

N_train = numel(train_idx);
N_val = numel(val_idx);

%% Training Loop with Bradley-Terry Loss
if verbose
    fprintf('Training reward model (Bradley-Terry pairwise loss)...\n');
end

% Adam optimizer state
avg_grad = [];
avg_sq_grad = [];
learn_rate = 1e-3;
iteration = 0;

% Early stopping state
best_val_loss = inf;
best_net = reward_net;
wait_count = 0;

% Training history
train_losses = zeros(epochs, 1);
val_losses = zeros(epochs, 1);

for epoch = 1:epochs
    % Shuffle training data
    perm = randperm(N_train);
    X_pref_shuf = X_pref_train(perm, :);
    X_rej_shuf = X_rej_train(perm, :);

    epoch_loss = 0;
    num_batches = 0;

    % Mini-batch training
    for batch_start = 1:minibatch_size:N_train
        batch_end = min(batch_start + minibatch_size - 1, N_train);

        X_pref_batch = dlarray(X_pref_shuf(batch_start:batch_end, :)', 'CB');
        X_rej_batch = dlarray(X_rej_shuf(batch_start:batch_end, :)', 'CB');

        % Compute loss and gradients
        [loss, gradients] = dlfeval(@bradleyTerryLoss, reward_net, X_pref_batch, X_rej_batch);

        % Update with Adam
        iteration = iteration + 1;
        [reward_net, avg_grad, avg_sq_grad] = adamupdate(...
            reward_net, gradients, avg_grad, avg_sq_grad, iteration, learn_rate);

        epoch_loss = epoch_loss + double(extractdata(loss));
        num_batches = num_batches + 1;
    end

    train_losses(epoch) = epoch_loss / num_batches;

    % Validation loss
    if N_val > 0
        X_pref_v = dlarray(X_pref_val', 'CB');
        X_rej_v = dlarray(X_rej_val', 'CB');
        val_loss = dlfeval(@bradleyTerryLoss, reward_net, X_pref_v, X_rej_v);
        val_losses(epoch) = double(extractdata(val_loss));

        % Early stopping check
        if val_losses(epoch) < best_val_loss
            best_val_loss = val_losses(epoch);
            best_net = reward_net;
            wait_count = 0;
        else
            wait_count = wait_count + 1;
            if wait_count >= patience
                if verbose
                    fprintf('  Early stopping at epoch %d (patience=%d)\n', epoch, patience);
                end
                break;
            end
        end
    else
        best_net = reward_net;
    end

    % Learning rate decay every 30 epochs
    if mod(epoch, 30) == 0
        learn_rate = learn_rate * 0.5;
    end

    if verbose && (mod(epoch, 10) == 0 || epoch == 1)
        if N_val > 0
            fprintf('  Epoch %3d: train_loss=%.4f  val_loss=%.4f\n', ...
                epoch, train_losses(epoch), val_losses(epoch));
        else
            fprintf('  Epoch %3d: train_loss=%.4f\n', epoch, train_losses(epoch));
        end
    end
end

reward_model = best_net;

if verbose
    fprintf('Training complete!\n\n');
end

%% Evaluate Model
stats = struct();
stats.num_pairs = N;
stats.num_features = D;
stats.hidden_sizes = hidden_sizes;
stats.train_losses = train_losses(1:epoch);
stats.val_losses = val_losses(1:epoch);
stats.epochs_trained = epoch;

if N_val > 0
    % Compute pairwise accuracy on validation set
    r_pref = predict_reward(reward_model, X_pref_val);
    r_rej = predict_reward(reward_model, X_rej_val);
    pairwise_accuracy = mean(r_pref > r_rej);

    stats.pairwise_accuracy = pairwise_accuracy;
    stats.best_val_loss = best_val_loss;

    if verbose
        fprintf('=== Validation Performance ===\n');
        fprintf('Pairwise accuracy: %.2f%%\n', pairwise_accuracy * 100);
        fprintf('Best val loss:     %.4f\n\n', best_val_loss);
    end
end

end

%% Bradley-Terry pairwise preference loss
function [loss, gradients] = bradleyTerryLoss(net, X_preferred, X_rejected)
%BRADLEYTERRY Loss = -mean(log(sigmoid(r_preferred - r_rejected)))

r_preferred = forward(net, X_preferred);
r_rejected = forward(net, X_rejected);

% Bradley-Terry: P(preferred > rejected) = sigmoid(r_pref - r_rej)
% Loss = -log(P) = -log(sigmoid(r_pref - r_rej))
% Using log-sigmoid form: log(sigmoid(x)) = -softplus(-x) for stability
diff = r_preferred - r_rejected;
loss = mean(softplus(-diff), 'all');

gradients = dlgradient(loss, net.Learnables);
end

%% Predict rewards for new data
function rewards = predict_reward(net, features)
%PREDICT_REWARD Compute scalar rewards for feature matrix.
X = dlarray(features', 'CB');
r = predict(net, X);
rewards = double(extractdata(r))';
rewards = rewards(:);
end

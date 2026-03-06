classdef AnnotationEnvironment < rl.env.MATLABEnvironment
    %ANNOTATIONENVIRONMENT RL environment for learning optimal annotation policies.
    %   This environment trains an RL agent to select the most valuable chunks
    %   for human annotation, learning from the improvement in validation metrics.
    %
    %   STATE SPACE (observation):
    %       - Model uncertainty for current chunk (1 value)
    %       - Label distribution confidence (L values, one per label)
    %       - Budget remaining (1 value)
    %       - Current validation F1 (1 value)
    %       Total: L + 3 dimensions (dynamic based on label count)
    %
    %   ACTION SPACE:
    %       - Continuous: Uncertainty threshold for chunk selection (1 value, [0,1])
    %         Selects the available chunk whose uncertainty is closest to threshold
    %
    %   REWARD:
    %       - Improvement in validation F1 per annotation
    %       - Penalized by annotation cost
    %       - Bonus for efficient budget usage
    %
    %   EXAMPLE:
    %       % Create environment
    %       env = reg.rl.AnnotationEnvironment(chunksT, features, scores, ...
    %           Yweak_train, Yweak_eval, labels, 'BudgetTotal', 100);
    %
    %       % Create DQN agent
    %       agent = rlDQNAgent(getObservationInfo(env), getActionInfo(env));
    %
    %       % Train agent
    %       trainOpts = rlTrainingOptions('MaxEpisodes', 500);
    %       trainingStats = train(agent, env, trainOpts);
    %
    %       % Use trained agent to select chunks
    %       selected_chunks = env.selectChunksWithAgent(agent, 50);

    properties
        % Data
        ChunksTable
        Features
        Scores              % Prediction scores (N x L)
        YweakTrain
        YweakEval
        Labels

        % Environment state
        State               % Current observation
        AnnotatedIndices    % Chunks already annotated
        BudgetRemaining     % Annotations left in budget
        BudgetTotal         % Total annotation budget
        CurrentF1           % Current validation F1 score

        % Ground truth (simulated for training)
        GroundTruth         % Simulated ground truth for training

        % Episode tracking
        EpisodeCount
        TotalReward
    end

    properties (Access = private)
        % Cached computations
        UncertaintyScores   % Pre-computed uncertainty for all chunks
        AvailableChunks     % Chunks not yet annotated

        % Running reward normalization (prevents reward scale drift)
        RewardRunningSum    % Sum of rewards seen
        RewardRunningSumSq  % Sum of squared rewards
        RewardCount         % Number of rewards seen
    end

    methods
        function this = AnnotationEnvironment(chunksT, features, scores, ...
                Yweak_train, Yweak_eval, labels, varargin)
            % Constructor

            % Parse arguments
            p = inputParser;
            addParameter(p, 'BudgetTotal', 100, @(x) x > 0);
            addParameter(p, 'GroundTruth', [], @ismatrix);  % Optional ground truth
            addParameter(p, 'ActionType', 'continuous', @(x) ismember(x, {'discrete', 'continuous'}));
            parse(p, varargin{:});

            % Observation dimension: 1 uncertainty + L label_conf + 1 budget + 1 f1
            L = numel(labels);
            obs_dim = 1 + L + 1 + 1;

            % Define observation space (dynamic based on label count)
            ObservationInfo = rlNumericSpec([obs_dim 1]);
            ObservationInfo.Name = 'Annotation State';
            ObservationInfo.Description = sprintf('Uncertainty, label confidence(%d), budget, F1', L);

            % Define action space: continuous threshold [0,1]
            % Selects the chunk whose uncertainty is closest to the threshold.
            % This scales O(1) regardless of corpus size, unlike discrete O(N).
            ActionInfo = rlNumericSpec([1 1], 'LowerLimit', 0, 'UpperLimit', 1);
            ActionInfo.Name = 'Uncertainty Threshold';

            % Call superclass constructor
            this = this@rl.env.MATLABEnvironment(ObservationInfo, ActionInfo);

            % Store data
            this.ChunksTable = chunksT;
            this.Features = features;
            this.Scores = scores;
            this.YweakTrain = Yweak_train;
            this.YweakEval = Yweak_eval;
            this.Labels = labels;
            this.BudgetTotal = p.Results.BudgetTotal;

            % Initialize ground truth
            if isempty(p.Results.GroundTruth)
                % No ground truth provided: attempt to load gold labels,
                % otherwise warn and fall back to eval rules (circular).
                gold_path = fullfile('gold', 'sample_gold_Ytrue.csv');
                if isfile(gold_path)
                    gold_Y = readmatrix(gold_path);
                    if size(gold_Y, 1) >= height(chunksT) && size(gold_Y, 2) >= numel(labels)
                        this.GroundTruth = gold_Y(1:height(chunksT), 1:numel(labels)) > 0.5;
                    else
                        warning('reg:rl:AnnotationEnvironment:GoldSizeMismatch', ...
                            ['Gold labels size (%d x %d) does not match data (%d x %d). ' ...
                             'Falling back to eval rules as ground truth (circular). ' ...
                             'Provide ''GroundTruth'' argument for reliable training.'], ...
                            size(gold_Y, 1), size(gold_Y, 2), height(chunksT), numel(labels));
                        this.GroundTruth = Yweak_eval > 0.5;
                    end
                else
                    warning('reg:rl:AnnotationEnvironment:NoGroundTruth', ...
                        ['No ground truth provided and gold labels not found at ''%s''. ' ...
                         'Using eval rules as ground truth proxy (circular). ' ...
                         'Provide ''GroundTruth'' argument for reliable training.'], gold_path);
                    this.GroundTruth = Yweak_eval > 0.5;
                end
            else
                this.GroundTruth = p.Results.GroundTruth;
            end

            % Pre-compute uncertainty scores
            this.UncertaintyScores = this.computeUncertainty();

            % Initialize reward normalization state (persists across episodes)
            this.RewardRunningSum = 0;
            this.RewardRunningSumSq = 0;
            this.RewardCount = 0;

            % Initialize state
            this.EpisodeCount = 0;
            this.reset();
        end

        function [observation, reward, isDone, loggedSignals] = step(this, action)
            % Execute one step of the environment

            loggedSignals = [];

            % Continuous action: threshold selects chunk with closest uncertainty
            if isempty(this.AvailableChunks)
                reward = 0;
                this.State = this.getObservation();
                observation = this.State;
                isDone = true;
                return;
            end

            threshold = max(0, min(1, action));  % Clamp to [0,1]
            available_unc = this.UncertaintyScores(this.AvailableChunks);
            [~, rel_idx] = min(abs(available_unc - threshold));
            chunk_idx = this.AvailableChunks(rel_idx);

            % Record previous F1
            prev_f1 = this.CurrentF1;

            % "Annotate" the chunk (get ground truth)
            this.AnnotatedIndices = [this.AnnotatedIndices; chunk_idx];
            this.BudgetRemaining = this.BudgetRemaining - 1;

            % Update available chunks
            this.AvailableChunks = setdiff(this.AvailableChunks, chunk_idx);

            % Re-evaluate model with new annotation
            % (In real system, would retrain. Here we simulate improvement)
            this.CurrentF1 = this.evaluateWithAnnotations();

            % Compute raw reward
            f1_improvement = this.CurrentF1 - prev_f1;

            % Reward = improvement in F1 per annotation
            % Bonus if high-uncertainty chunk was selected
            uncertainty_bonus = this.UncertaintyScores(chunk_idx) * 0.1;

            raw_reward = f1_improvement * 100 + uncertainty_bonus;

            % Small penalty for using budget (encourages efficiency)
            raw_reward = raw_reward - 0.01;

            % Normalize reward using running statistics (prevents scale drift)
            this.RewardRunningSum = this.RewardRunningSum + raw_reward;
            this.RewardRunningSumSq = this.RewardRunningSumSq + raw_reward^2;
            this.RewardCount = this.RewardCount + 1;

            if this.RewardCount >= 2
                running_mean = this.RewardRunningSum / this.RewardCount;
                running_var = this.RewardRunningSumSq / this.RewardCount - running_mean^2;
                running_std = sqrt(max(running_var, 1e-8));
                reward = (raw_reward - running_mean) / running_std;
            else
                reward = raw_reward;
            end

            % Update total reward
            this.TotalReward = this.TotalReward + reward;

            % Check if episode is done
            isDone = (this.BudgetRemaining <= 0) || (this.CurrentF1 >= 0.95);

            % Get new observation
            this.State = this.getObservation();
            observation = this.State;
        end

        function initialObservation = reset(this)
            % Reset environment to initial state

            this.AnnotatedIndices = [];
            this.BudgetRemaining = this.BudgetTotal;
            this.AvailableChunks = (1:height(this.ChunksTable))';
            this.TotalReward = 0;
            this.EpisodeCount = this.EpisodeCount + 1;

            % Initial F1 (without any annotations)
            this.CurrentF1 = this.evaluateWithAnnotations();

            % Get initial observation
            this.State = this.getObservation();
            initialObservation = this.State;
        end
    end

    methods (Access = private)
        function obs = getObservation(this)
            % Construct observation vector

            N = height(this.ChunksTable);
            L = numel(this.Labels);

            if isempty(this.AvailableChunks)
                % No chunks available
                current_uncertainty = 0;
                label_confidence = zeros(L, 1);
            else
                % Average uncertainty over available chunks
                current_uncertainty = mean(this.UncertaintyScores(this.AvailableChunks));

                % Average prediction confidence per label (available chunks)
                label_confidence = mean(this.Scores(this.AvailableChunks, :), 1)';
            end

            % Budget remaining (normalized)
            budget_norm = this.BudgetRemaining / this.BudgetTotal;

            % Current F1
            current_f1 = this.CurrentF1;

            % Construct observation: [uncertainty, label_conf(L), budget, f1]
            obs = [current_uncertainty; label_confidence; budget_norm; current_f1];
        end

        function uncertainty = computeUncertainty(this)
            % Compute uncertainty scores for all chunks

            % Combine multiple uncertainty metrics
            % 1. Binary entropy for independent multi-label predictions
            p = max(min(this.Scores, 1 - 1e-10), 1e-10);
            entropy = -sum(p .* log(p) + (1 - p) .* log(1 - p), 2);

            % 2. Disagreement between train and eval rules
            disagreement = sum(xor(this.YweakTrain > 0.5, this.YweakEval > 0.5), 2);

            % 3. Least confidence
            [max_prob, ~] = max(this.Scores, [], 2);
            least_conf = 1 - max_prob;

            % Normalize and combine
            entropy_norm = (entropy - min(entropy)) / (max(entropy) - min(entropy) + 1e-10);
            disagreement_norm = (disagreement - min(disagreement)) / (max(disagreement) - min(disagreement) + 1e-10);
            least_conf_norm = (least_conf - min(least_conf)) / (max(least_conf) - min(least_conf) + 1e-10);

            % Load weights from knobs.json (configurable), with defaults
            w_ent = 0.4; w_dis = 0.4; w_lc = 0.2;
            if isfile('knobs.json')
                try
                    knobs = jsondecode(fileread('knobs.json'));
                    if isfield(knobs, 'ActiveLearning') && isfield(knobs.ActiveLearning, 'UncertaintyWeights')
                        uw = knobs.ActiveLearning.UncertaintyWeights;
                        if isfield(uw, 'Entropy'); w_ent = uw.Entropy; end
                        if isfield(uw, 'Disagreement'); w_dis = uw.Disagreement; end
                        if isfield(uw, 'LeastConfidence'); w_lc = uw.LeastConfidence; end
                    end
                catch; end
            end
            uncertainty = w_ent * entropy_norm + w_dis * disagreement_norm + w_lc * least_conf_norm;
        end

        function f1 = evaluateWithAnnotations(this)
            % Evaluate model performance with current annotations.
            % Retrains a classifier using ground truth for annotated chunks
            % and weak labels for remaining chunks, so the reward reflects
            % which specific chunks were selected (content-aware).

            N = height(this.ChunksTable);
            L = size(this.YweakTrain, 2);

            if isempty(this.AnnotatedIndices)
                % No annotations yet: evaluate baseline predictions
                predictions = this.Scores > 0.5;
                f1 = this.computeF1(predictions, this.GroundTruth);
                return;
            end

            % Build training labels: ground truth for annotated, weak for rest
            Y_train = this.YweakTrain > 0.5;
            Y_train(this.AnnotatedIndices, :) = this.GroundTruth(this.AnnotatedIndices, :);

            % Retrain simple per-label classifiers and predict
            predictions = false(N, L);
            for j = 1:L
                y = double(Y_train(:, j));
                if nnz(y) >= 2 && nnz(y) < N
                    mdl = fitclinear(this.Features, y, ...
                        'Learner', 'logistic', 'ObservationsIn', 'rows');
                    [~, sc] = predict(mdl, this.Features);
                    predictions(:, j) = sc(:, end) > 0.5;
                else
                    predictions(:, j) = y > 0.5;
                end
            end

            f1 = this.computeF1(predictions, this.GroundTruth);
        end

        function f1 = computeF1(this, predictions, ground_truth)
            % Compute F1 score
            tp = sum(predictions & ground_truth, 'all');
            fp = sum(predictions & ~ground_truth, 'all');
            fn = sum(~predictions & ground_truth, 'all');

            prec = tp / max(1, tp + fp);
            rec = tp / max(1, tp + fn);
            f1 = 2 * prec * rec / max(1e-9, prec + rec);
        end
    end

    methods (Access = public)
        function selected = selectChunksWithAgent(this, agent, budget)
            % Use trained agent to select chunks for annotation

            this.reset();
            selected = [];

            for i = 1:budget
                if this.BudgetRemaining <= 0 || isempty(this.AvailableChunks)
                    break;
                end

                % Get action from agent
                obs = this.getObservation();
                action = getAction(agent, obs);
                % getAction returns a cell array; unwrap the scalar action
                if iscell(action)
                    action = action{1};
                end

                % Execute action
                [~, ~, isDone, ~] = this.step(action);

                % Record selection
                if ~isempty(this.AnnotatedIndices)
                    selected = this.AnnotatedIndices;
                end

                if isDone
                    break;
                end
            end
        end
    end
end

classdef AnnotationEnvironment < rl.env.MATLABEnvironment
    %ANNOTATIONENVIRONMENT RL environment for learning optimal annotation policies.
    %   This environment trains an RL agent to select the most valuable chunks
    %   for human annotation, learning from the improvement in validation metrics.
    %
    %   STATE SPACE (observation):
    %       - Model uncertainty for current chunk (1 value)
    %       - Label distribution confidence (14 values, one per label)
    %       - Budget remaining (1 value)
    %       - Current validation F1 (1 value)
    %       Total: 17 dimensions
    %
    %   ACTION SPACE:
    %       - Discrete: Select which chunk to annotate next (N chunks)
    %       OR
    %       - Continuous: Uncertainty threshold for batch selection (1 value, [0,1])
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
    end

    methods
        function this = AnnotationEnvironment(chunksT, features, scores, ...
                Yweak_train, Yweak_eval, labels, varargin)
            % Constructor

            % Parse arguments
            p = inputParser;
            addParameter(p, 'BudgetTotal', 100, @(x) x > 0);
            addParameter(p, 'GroundTruth', [], @ismatrix);  % Optional ground truth
            addParameter(p, 'ActionType', 'discrete', @(x) ismember(x, {'discrete', 'continuous'}));
            parse(p, varargin{:});

            % Define observation space (17 dimensions)
            ObservationInfo = rlNumericSpec([17 1]);
            ObservationInfo.Name = 'Annotation State';
            ObservationInfo.Description = 'Uncertainty, label confidence, budget, F1';

            % Define action space
            if strcmp(p.Results.ActionType, 'discrete')
                % Discrete: select specific chunk index
                ActionInfo = rlFiniteSetSpec(1:height(chunksT));
                ActionInfo.Name = 'Chunk Index';
            else
                % Continuous: uncertainty threshold
                ActionInfo = rlNumericSpec([1 1], 'LowerLimit', 0, 'UpperLimit', 1);
                ActionInfo.Name = 'Uncertainty Threshold';
            end

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

            % Initialize ground truth (simulated from eval rules if not provided)
            if isempty(p.Results.GroundTruth)
                % Simulate ground truth: use eval rules as proxy
                this.GroundTruth = Yweak_eval > 0.5;
            else
                this.GroundTruth = p.Results.GroundTruth;
            end

            % Pre-compute uncertainty scores
            this.UncertaintyScores = this.computeUncertainty();

            % Initialize state
            this.EpisodeCount = 0;
            this.reset();
        end

        function [observation, reward, isDone, loggedSignals] = step(this, action)
            % Execute one step of the environment

            loggedSignals = [];

            % Determine which chunk to annotate based on action
            if isa(this.ActionInfo, 'rl.util.rlFiniteSetSpec')
                % Discrete action: direct chunk index
                chunk_idx = action;
            else
                % Continuous action: threshold for batch selection
                threshold = action;
                % Select chunk with uncertainty closest to threshold
                available_unc = this.UncertaintyScores(this.AvailableChunks);
                [~, rel_idx] = min(abs(available_unc - threshold));
                chunk_idx = this.AvailableChunks(rel_idx);
            end

            % Check if chunk is available
            if ~ismember(chunk_idx, this.AvailableChunks)
                % Invalid action: already annotated or out of bounds
                reward = -10;  % Large penalty
                this.State = this.getObservation();
                observation = this.State;
                isDone = this.BudgetRemaining <= 0;
                return;
            end

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

            % Compute reward
            f1_improvement = this.CurrentF1 - prev_f1;

            % Reward = improvement in F1 per annotation
            % Bonus if high-uncertainty chunk was selected
            uncertainty_bonus = this.UncertaintyScores(chunk_idx) * 0.1;

            reward = f1_improvement * 100 + uncertainty_bonus;

            % Small penalty for using budget (encourages efficiency)
            budget_penalty = -0.01;
            reward = reward + budget_penalty;

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

            % Construct observation: [uncertainty, label_conf(14), budget, f1]
            obs = [current_uncertainty; label_confidence; budget_norm; current_f1];
        end

        function uncertainty = computeUncertainty(this)
            % Compute uncertainty scores for all chunks

            % Combine multiple uncertainty metrics
            % 1. Entropy
            entropy = -sum(this.Scores .* log(this.Scores + 1e-10), 2);

            % 2. Disagreement between train and eval rules
            disagreement = sum(xor(this.YweakTrain > 0.5, this.YweakEval > 0.5), 2);

            % 3. Least confidence
            [max_prob, ~] = max(this.Scores, [], 2);
            least_conf = 1 - max_prob;

            % Normalize and combine
            entropy_norm = (entropy - min(entropy)) / (max(entropy) - min(entropy) + 1e-10);
            disagreement_norm = (disagreement - min(disagreement)) / (max(disagreement) - min(disagreement) + 1e-10);
            least_conf_norm = (least_conf - min(least_conf)) / (max(least_conf) - min(least_conf) + 1e-10);

            uncertainty = 0.4 * entropy_norm + 0.4 * disagreement_norm + 0.2 * least_conf_norm;
        end

        function f1 = evaluateWithAnnotations(this)
            % Evaluate model performance with current annotations

            if isempty(this.AnnotatedIndices)
                % No annotations yet: use eval rules
                predictions = this.Scores > 0.5;
                ground_truth = this.GroundTruth;
            else
                % Simulate improvement from annotations
                % In real system, would retrain model with ground truth

                % For simulation: assume linear improvement with annotations
                % Start with eval rule F1, improve toward 1.0

                predictions = this.Scores > 0.5;
                ground_truth = this.GroundTruth;

                % Base F1 (without annotations)
                base_f1 = this.computeF1(predictions, ground_truth);

                % Simulate improvement (diminishing returns)
                % Each annotation improves model slightly
                improvement_rate = 0.3;  % Max 30% improvement possible
                saturation = 1 - exp(-numel(this.AnnotatedIndices) / this.BudgetTotal);

                f1 = base_f1 + improvement_rate * (1 - base_f1) * saturation;

                % Add noise
                f1 = f1 + 0.01 * randn();
                f1 = max(0, min(1, f1));  % Clip to [0,1]
            end
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

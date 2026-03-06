function [agent, trainingStats] = train_annotation_agent(chunksT, features, scores, Yweak_train, Yweak_eval, labels, varargin)
%TRAIN_ANNOTATION_AGENT Train RL agent to learn optimal annotation policy.
%   [agent, stats] = TRAIN_ANNOTATION_AGENT(chunksT, features, scores,
%       Yweak_train, Yweak_eval, labels, ...)
%   trains a reinforcement learning agent to select the most valuable chunks
%   for human annotation, maximizing validation improvement per annotation.
%
%   INPUTS:
%       chunksT      - Table with chunk text and metadata
%       features     - Feature matrix (N x D)
%       scores       - Prediction scores (N x L)
%       Yweak_train  - Weak labels from training rules (N x L)
%       Yweak_eval   - Weak labels from eval rules (N x L)
%       labels       - Label names (L x 1)
%
%   NAME-VALUE ARGUMENTS:
%       'BudgetTotal'    - Total annotation budget per episode (default: 100)
%       'AgentType'      - RL algorithm:
%                          'DDPG' (default) - Deep Deterministic Policy Gradient (continuous)
%                          'DDPG_lite' - Lighter DDPG variant (smaller noise, equal LR)
%                          'PPO' - Proximal Policy Optimization
%       'MaxEpisodes'    - Training episodes (default: 500)
%       'MaxStepsPerEpisode' - Max steps per episode (default: BudgetTotal)
%       'Verbose'        - Display training progress (default: true)
%       'SaveAgent'      - Save trained agent to file (default: true)
%       'GroundTruth'    - Optional ground truth labels (N x L)
%
%   OUTPUTS:
%       agent         - Trained RL agent
%       trainingStats - Training statistics struct
%
%   ALGORITHM:
%       1. Create custom AnnotationEnvironment (RL environment)
%       2. Initialize RL agent (DQN, DDPG, or PPO)
%       3. Train agent to maximize validation improvement per annotation
%       4. Save trained agent for deployment
%
%   RL FORMULATION:
%       State:  [uncertainty, label_confidence(14), budget_remaining, current_f1]
%       Action: Chunk index to annotate (discrete) OR threshold (continuous)
%       Reward: Improvement in validation F1 + uncertainty bonus - budget penalty
%
%   EXAMPLE 1: Train DDPG agent (continuous policy)
%       [agent, stats] = reg.rl.train_annotation_agent(chunksT, features, ...
%           scores, Yweak_train, Yweak_eval, C.labels, ...
%           'AgentType', 'DDPG', 'MaxEpisodes', 500);
%
%   EXAMPLE 2: Train PPO agent
%       [agent, stats] = reg.rl.train_annotation_agent(chunksT, features, ...
%           scores, Yweak_train, Yweak_eval, C.labels, ...
%           'AgentType', 'PPO', 'MaxEpisodes', 300);
%
%   EXAMPLE 3: Use trained agent for chunk selection
%       % After training
%       selected_chunks = env.selectChunksWithAgent(agent, 50);
%       annotation_set = chunksT(selected_chunks, :);
%
%   REFERENCES:
%       Mnih et al. 2015 - Human-level control through deep RL (DQN)
%       Lillicrap et al. 2015 - Continuous control with deep RL (DDPG)
%       Schulman et al. 2017 - Proximal Policy Optimization (PPO)
%
%   SEE ALSO: reg.rl.AnnotationEnvironment, reg.select_chunks_active_learning

% Parse arguments
p = inputParser;
addParameter(p, 'BudgetTotal', 100, @(x) x > 0);
addParameter(p, 'AgentType', 'DDPG', @(x) ismember(x, {'DDPG', 'DDPG_lite', 'PPO'}));
addParameter(p, 'MaxEpisodes', 500, @(x) x > 0);
addParameter(p, 'MaxStepsPerEpisode', [], @(x) isempty(x) || x > 0);
addParameter(p, 'Verbose', true, @islogical);
addParameter(p, 'SaveAgent', true, @islogical);
addParameter(p, 'GroundTruth', [], @ismatrix);
parse(p, varargin{:});

budget_total = p.Results.BudgetTotal;
agent_type = p.Results.AgentType;
max_episodes = p.Results.MaxEpisodes;
max_steps = p.Results.MaxStepsPerEpisode;
verbose = p.Results.Verbose;
save_agent = p.Results.SaveAgent;
ground_truth = p.Results.GroundTruth;

if isempty(max_steps)
    max_steps = budget_total;
end

if verbose
    fprintf('\n=== Training RL Agent for Annotation Policy ===\n');
    fprintf('Agent Type:      %s\n', agent_type);
    fprintf('Budget/Episode:  %d\n', budget_total);
    fprintf('Max Episodes:    %d\n', max_episodes);
    fprintf('Chunks:          %d\n', height(chunksT));
    fprintf('Labels:          %d\n', numel(labels));
    fprintf('\n');
end

%% Create Environment

% Always use continuous action space (scales O(1) regardless of corpus size)
env = reg.rl.AnnotationEnvironment(chunksT, features, scores, ...
    Yweak_train, Yweak_eval, labels, ...
    'BudgetTotal', budget_total, ...
    'GroundTruth', ground_truth, ...
    'ActionType', 'continuous');

obsInfo = getObservationInfo(env);
actInfo = getActionInfo(env);

%% Create Agent

switch agent_type
    case 'DDPG'
        % Deep Deterministic Policy Gradient (continuous actions)
        agent = create_ddpg_agent(obsInfo, actInfo);

    case 'DDPG_lite'
        % Lighter DDPG variant (smaller target smoothing)
        agent = create_ddpg_lite_agent(obsInfo, actInfo);

    case 'PPO'
        % Proximal Policy Optimization
        agent = create_ppo_agent(obsInfo, actInfo);
end

%% Training Options

trainOpts = rlTrainingOptions(...
    'MaxEpisodes', max_episodes, ...
    'MaxStepsPerEpisode', max_steps, ...
    'Verbose', verbose, ...
    'Plots', 'training-progress', ...
    'StopTrainingCriteria', 'AverageReward', ...
    'StopTrainingValue', 50, ...  % Stop if avg reward > 50
    'ScoreAveragingWindowLength', 50);

if ~verbose
    trainOpts.Plots = 'none';
end

%% Train Agent

if verbose
    fprintf('Starting training...\n');
end

trainingStats = train(agent, env, trainOpts);

if verbose
    fprintf('\nTraining complete!\n');
    fprintf('Episodes:        %d\n', trainingStats.EpisodeIndex(end));
    fprintf('Final Avg Reward: %.2f\n', trainingStats.AverageReward(end));
    fprintf('\n');
end

%% Save Agent

if save_agent
    filename = sprintf('rl_annotation_agent_%s.mat', lower(agent_type));
    save(filename, 'agent', 'trainingStats', 'budget_total', 'agent_type');

    if verbose
        fprintf('Agent saved to: %s\n\n', filename);
    end
end

end

%% Helper Functions: Create Agents

function agent = create_ddpg_lite_agent(obsInfo, actInfo)
% Create lighter DDPG variant (smaller target smoothing factor).
% Formerly named "DQN" but always produced a DDPG agent since the
% environment uses continuous actions. Renamed for clarity.

% Actor network
actorNet = [
    featureInputLayer(obsInfo.Dimension(1), 'Normalization', 'none', 'Name', 'state')
    fullyConnectedLayer(128, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(64, 'Name', 'fc2')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(actInfo.Dimension(1), 'Name', 'fc_out')
    tanhLayer('Name', 'tanh')
    functionLayer(@(x) x * 0.5 + 0.5, 'Name', 'scale', 'Formattable', true)
];

actor = rlContinuousDeterministicActor(actorNet, obsInfo, actInfo);

% Critic network (state-action Q-value)
statePath = [
    featureInputLayer(obsInfo.Dimension(1), 'Normalization', 'none', 'Name', 'state')
    fullyConnectedLayer(128, 'Name', 'state_fc')
];

actionPath = [
    featureInputLayer(actInfo.Dimension(1), 'Normalization', 'none', 'Name', 'action')
    fullyConnectedLayer(128, 'Name', 'action_fc')
];

commonPath = [
    additionLayer(2, 'Name', 'add')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(64, 'Name', 'critic_fc2')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(1, 'Name', 'output')
];

criticNet = layerGraph(statePath);
criticNet = addLayers(criticNet, actionPath);
criticNet = addLayers(criticNet, commonPath);
criticNet = connectLayers(criticNet, 'state_fc', 'add/in1');
criticNet = connectLayers(criticNet, 'action_fc', 'add/in2');

critic = rlQValueFunction(criticNet, obsInfo, actInfo);

% Agent options (M7 fix: critic LR 10x actor for stable training)
agentOpts = rlDDPGAgentOptions(...
    'SampleTime', 1, ...
    'DiscountFactor', 0.99, ...
    'ExperienceBufferLength', 10000, ...
    'MiniBatchSize', 64, ...
    'TargetSmoothFactor', 5e-3);

% Exploration noise
agentOpts.NoiseOptions.StandardDeviation = 0.3;
agentOpts.NoiseOptions.StandardDeviationDecayRate = 1e-3;

% Learning rates via agent options (R2025b API)
agentOpts.ActorOptimizerOptions.LearnRate = 1e-4;
agentOpts.ActorOptimizerOptions.GradientThreshold = 1;
agentOpts.CriticOptimizerOptions.LearnRate = 1e-3;
agentOpts.CriticOptimizerOptions.GradientThreshold = 1;

% Create agent
agent = rlDDPGAgent(actor, critic, agentOpts);
end

function agent = create_ddpg_agent(obsInfo, actInfo)
% Create DDPG agent for continuous action space (R2025b API)

% Actor network
actorNet = [
    featureInputLayer(obsInfo.Dimension(1), 'Normalization', 'none', 'Name', 'state')
    fullyConnectedLayer(128, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(64, 'Name', 'fc2')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(actInfo.Dimension(1), 'Name', 'fc_out')
    tanhLayer('Name', 'tanh')
    functionLayer(@(x) x * 0.5 + 0.5, 'Name', 'scale', 'Formattable', true)
];

actor = rlContinuousDeterministicActor(actorNet, obsInfo, actInfo);

% Critic network
statePath = [
    featureInputLayer(obsInfo.Dimension(1), 'Normalization', 'none', 'Name', 'state')
    fullyConnectedLayer(128, 'Name', 'state_fc')
];

actionPath = [
    featureInputLayer(actInfo.Dimension(1), 'Normalization', 'none', 'Name', 'action')
    fullyConnectedLayer(128, 'Name', 'action_fc')
];

commonPath = [
    additionLayer(2, 'Name', 'add')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(64, 'Name', 'critic_fc2')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(1, 'Name', 'output')
];

criticNet = layerGraph(statePath);
criticNet = addLayers(criticNet, actionPath);
criticNet = addLayers(criticNet, commonPath);
criticNet = connectLayers(criticNet, 'state_fc', 'add/in1');
criticNet = connectLayers(criticNet, 'action_fc', 'add/in2');

critic = rlQValueFunction(criticNet, obsInfo, actInfo);

% Agent options
agentOpts = rlDDPGAgentOptions(...
    'SampleTime', 1, ...
    'DiscountFactor', 0.99, ...
    'ExperienceBufferLength', 10000, ...
    'MiniBatchSize', 64, ...
    'TargetSmoothFactor', 1e-3);

% Noise model for exploration (larger initial noise per Lillicrap et al. 2015)
agentOpts.NoiseOptions.StandardDeviation = 0.3;
agentOpts.NoiseOptions.StandardDeviationDecayRate = 1e-3;

% Learning rates via agent options (R2025b API)
agentOpts.ActorOptimizerOptions.LearnRate = 1e-4;
agentOpts.ActorOptimizerOptions.GradientThreshold = 1;
agentOpts.CriticOptimizerOptions.LearnRate = 1e-3;
agentOpts.CriticOptimizerOptions.GradientThreshold = 1;

% Create agent
agent = rlDDPGAgent(actor, critic, agentOpts);
end

function agent = create_ppo_agent(obsInfo, actInfo)
% Create PPO agent with continuous Gaussian policy (R2025b API).
% The actor has two output paths: mean and log-standard-deviation.

obs_dim = obsInfo.Dimension(1);
act_dim = actInfo.Dimension(1);

% Shared trunk
trunk = [
    featureInputLayer(obs_dim, 'Normalization', 'none', 'Name', 'state')
    fullyConnectedLayer(128, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(64, 'Name', 'fc_shared')
    reluLayer('Name', 'relu_shared')
];

% Mean path: outputs action mean in [0,1]
meanPath = [
    fullyConnectedLayer(act_dim, 'Name', 'mean_fc')
    tanhLayer('Name', 'tanh_mean')
    functionLayer(@(x) x * 0.5 + 0.5, 'Name', 'mean', 'Formattable', true)
];

% Standard deviation path: outputs positive std via softplus
stdPath = [
    fullyConnectedLayer(act_dim, 'Name', 'std_fc')
    softplusLayer('Name', 'std')
];

actorNet = layerGraph(trunk);
actorNet = addLayers(actorNet, meanPath);
actorNet = addLayers(actorNet, stdPath);
actorNet = connectLayers(actorNet, 'relu_shared', 'mean_fc');
actorNet = connectLayers(actorNet, 'relu_shared', 'std_fc');

actor = rlContinuousGaussianActor(actorNet, obsInfo, actInfo, ...
    'ActionMeanOutputNames', "mean", ...
    'ActionStandardDeviationOutputNames', "std");

% Critic network (value function)
criticNet = [
    featureInputLayer(obs_dim, 'Normalization', 'none', 'Name', 'state')
    fullyConnectedLayer(128, 'Name', 'critic_fc1')
    reluLayer('Name', 'critic_relu1')
    fullyConnectedLayer(64, 'Name', 'critic_fc2')
    reluLayer('Name', 'critic_relu2')
    fullyConnectedLayer(1, 'Name', 'value')
];

critic = rlValueFunction(criticNet, obsInfo);

% Agent options (more epochs, GAE, entropy bonus for exploration)
agentOpts = rlPPOAgentOptions(...
    'SampleTime', 1, ...
    'DiscountFactor', 0.99, ...
    'ExperienceHorizon', 512, ...
    'MiniBatchSize', 64, ...
    'NumEpoch', 8, ...
    'ClipFactor', 0.2, ...
    'AdvantageEstimateMethod', 'gae', ...
    'GAEFactor', 0.95, ...
    'EntropyLossWeight', 0.01);

% Learning rates via agent options (R2025b API)
agentOpts.ActorOptimizerOptions.LearnRate = 1e-4;
agentOpts.ActorOptimizerOptions.GradientThreshold = 1;
agentOpts.CriticOptimizerOptions.LearnRate = 1e-3;
agentOpts.CriticOptimizerOptions.GradientThreshold = 1;

% Create agent
agent = rlPPOAgent(actor, critic, agentOpts);
end

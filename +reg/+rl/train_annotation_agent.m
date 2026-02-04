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
%                          'DQN' (default) - Deep Q-Network (discrete actions)
%                          'DDPG' - Deep Deterministic Policy Gradient (continuous)
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
%   EXAMPLE 1: Train DQN agent (discrete actions)
%       [agent, stats] = reg.rl.train_annotation_agent(chunksT, features, ...
%           scores, Yweak_train, Yweak_eval, C.labels, ...
%           'AgentType', 'DQN', 'MaxEpisodes', 500);
%
%   EXAMPLE 2: Train DDPG agent (continuous policy)
%       [agent, stats] = reg.rl.train_annotation_agent(chunksT, features, ...
%           scores, Yweak_train, Yweak_eval, C.labels, ...
%           'AgentType', 'DDPG', 'MaxEpisodes', 300);
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
addParameter(p, 'AgentType', 'DQN', @(x) ismember(x, {'DQN', 'DDPG', 'PPO'}));
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

if strcmp(agent_type, 'DQN')
    action_type = 'discrete';
else
    action_type = 'continuous';
end

env = reg.rl.AnnotationEnvironment(chunksT, features, scores, ...
    Yweak_train, Yweak_eval, labels, ...
    'BudgetTotal', budget_total, ...
    'GroundTruth', ground_truth, ...
    'ActionType', action_type);

obsInfo = getObservationInfo(env);
actInfo = getActionInfo(env);

%% Create Agent

switch agent_type
    case 'DQN'
        % Deep Q-Network (discrete actions)
        agent = create_dqn_agent(obsInfo, actInfo);

    case 'DDPG'
        % Deep Deterministic Policy Gradient (continuous actions)
        agent = create_ddpg_agent(obsInfo, actInfo);

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

function agent = create_dqn_agent(obsInfo, actInfo)
% Create DQN agent for discrete action space

% Critic network (Q-network)
statePath = [
    featureInputLayer(obsInfo.Dimension(1), 'Normalization', 'none', 'Name', 'state')
    fullyConnectedLayer(128, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(128, 'Name', 'fc2')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(64, 'Name', 'fc3')
    reluLayer('Name', 'relu3')
    fullyConnectedLayer(numel(actInfo.Elements), 'Name', 'output')
];

criticNet = layerGraph(statePath);
critic = rlQValueRepresentation(criticNet, obsInfo, actInfo, ...
    'Observation', {'state'});

% Agent options
agentOpts = rlDQNAgentOptions(...
    'SampleTime', 1, ...
    'DiscountFactor', 0.99, ...
    'ExperienceBufferLength', 10000, ...
    'MiniBatchSize', 64, ...
    'TargetSmoothFactor', 1e-3, ...
    'EpsilonGreedyExploration', rlEpsilonGreedyExploration(...
        'EpsilonDecay', 0.001, ...
        'EpsilonMin', 0.01));

% Learning rate
critic.Options.LearnRate = 1e-3;

% Create agent
agent = rlDQNAgent(critic, agentOpts);
end

function agent = create_ddpg_agent(obsInfo, actInfo)
% Create DDPG agent for continuous action space

% Actor network
actorNet = [
    featureInputLayer(obsInfo.Dimension(1), 'Normalization', 'none', 'Name', 'state')
    fullyConnectedLayer(128, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(64, 'Name', 'fc2')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(actInfo.Dimension(1), 'Name', 'fc_out')
    tanhLayer('Name', 'tanh')
    scalingLayer('Name', 'scale', 'Scale', 0.5, 'Bias', 0.5)  % Scale to [0,1]
];

actor = rlDeterministicActorRepresentation(actorNet, obsInfo, actInfo, ...
    'Observation', {'state'}, 'Action', {'scale'});

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
    fullyConnectedLayer(64, 'Name', 'fc2')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(1, 'Name', 'output')
];

criticNet = layerGraph(statePath);
criticNet = addLayers(criticNet, actionPath);
criticNet = addLayers(criticNet, commonPath);
criticNet = connectLayers(criticNet, 'state_fc', 'add/in1');
criticNet = connectLayers(criticNet, 'action_fc', 'add/in2');

critic = rlQValueRepresentation(criticNet, obsInfo, actInfo, ...
    'Observation', {'state'}, 'Action', {'action'});

% Agent options
agentOpts = rlDDPGAgentOptions(...
    'SampleTime', 1, ...
    'DiscountFactor', 0.99, ...
    'ExperienceBufferLength', 10000, ...
    'MiniBatchSize', 64, ...
    'TargetSmoothFactor', 1e-3);

% Noise model for exploration
agentOpts.NoiseOptions.StandardDeviation = 0.1;
agentOpts.NoiseOptions.StandardDeviationDecayRate = 1e-3;

% Learning rates
actor.Options.LearnRate = 1e-4;
critic.Options.LearnRate = 1e-3;

% Create agent
agent = rlDDPGAgent(actor, critic, agentOpts);
end

function agent = create_ppo_agent(obsInfo, actInfo)
% Create PPO agent

% Actor network (stochastic policy)
actorNet = [
    featureInputLayer(obsInfo.Dimension(1), 'Normalization', 'none', 'Name', 'state')
    fullyConnectedLayer(128, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(64, 'Name', 'fc2')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(numel(actInfo.Elements), 'Name', 'output')
    softmaxLayer('Name', 'actionProb')
];

actor = rlStochasticActorRepresentation(actorNet, obsInfo, actInfo, ...
    'Observation', {'state'});

% Critic network (value function)
criticNet = [
    featureInputLayer(obsInfo.Dimension(1), 'Normalization', 'none', 'Name', 'state')
    fullyConnectedLayer(128, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(64, 'Name', 'fc2')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(1, 'Name', 'value')
];

critic = rlValueRepresentation(criticNet, obsInfo, ...
    'Observation', {'state'});

% Agent options
agentOpts = rlPPOAgentOptions(...
    'SampleTime', 1, ...
    'DiscountFactor', 0.99, ...
    'ExperienceHorizon', 512, ...
    'MiniBatchSize', 64, ...
    'NumEpoch', 3, ...
    'ClipFactor', 0.2);

% Learning rates
actor.Options.LearnRate = 1e-4;
critic.Options.LearnRate = 1e-3;

% Create agent
agent = rlPPOAgent(actor, critic, agentOpts);
end

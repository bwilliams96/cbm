function [loglik] = model_hybrid(parameters,subj)
nd_eta  = parameters(1); % normally-distributed eta
eta     = 1/(1+exp(-nd_eta)); % eta (transformed to be between zero and one)

nd_kappa  = parameters(2);
kappa    = 1/(1+exp(-nd_kappa));

% unpack data
actions = subj.actions; % 1 for action=1 and 2 for action=2
outcome = subj.outcome; % 1 for outcome=1 and 0 for outcome=0

% number of trials
T       = size(outcome,1);

% Q-value for each action
q       = zeros(1,2); % Q-value for both actions initialized at 0

% to save probability of choice. Currently NaNs, will be filled below
p       = nan(T,1);

% beta assumed to be 1
beta = 1;

% initial associability set to 0 
alpha = 1;

for t=1:T    
    % probability of action 1
    % this is equivalant to the softmax function, but overcomes the problem
    % of overflow when q-values or beta is big.
    p1   = 1./(1+exp(-beta*(q(1)-q(2))));
    
    % probability of action 2
    p2   = 1-p1;
    
    % read info for the current trial
    a    = actions(t); % action on this trial
    o    = outcome(t); % outcome on this trial
    
    % store probability of the chosen action
    if a==1
        p(t) = p1;
    elseif a==2
        p(t) = p2;
    end
    
    delta    = o - q(a); % prediction error
    q(a)     = q(a) + (kappa*alpha*delta);
    alpha = eta*abs(delta) + (1-eta)*alpha;
end

% log-likelihood is defined as the sum of log-probability of choice data
% (given the parameters).
loglik = sum(log(p+eps));
% Note that eps is a very small number in matlab (type eps in the command 
% window to see how small it is), which does not have any effect in practice, 
% but it overcomes the problem of underflow when p is very very small 
% (effectively 0).
end
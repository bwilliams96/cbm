%{
Model atapted from:
Computational modelling reveals contrasting effects on reinforcement 
learning and cognitive flexibility in stimulant use disorder and 
obsessive-compulsive disorder: remediating effects of dopaminergic 
D2/3 receptor agents
Authors:
Jonathan W. Kanen
Karen D. Ersche
Naomi A. Fineberg
Trevor W. Robbins
Rudolf N. Cardinal
https://doi.org/10.1007/s00213-019-05325-w
%}

function [loglik] = model_Kanen_4c(parameters,subj)
%%% NOTE! Transforms for parameters need to be determined %%%
%%%         should they all be sigmoid transforms?        %%%
nd_a_pos = parameters(1); %learning rate - positive prediction error
a_pos = 1/(1+exp(nd_a_pos)); % a0 transformed to be between 0-1
nd_a_neg = parameters(2); %learning rate - positive prediction error
a_neg = 1/(1+exp(nd_a_neg)); % a0 transformed to be between 0-1
nd_tau_v = parameters(3); %reinforcement sensitivity
tau_v = 1/(1+exp(nd_tau_v)); % a0 transformed to be between 0-1
nd_tau_stim = parameters(4); %stimulus stickiness
tau_stim = 1/(1+exp(nd_tau_stim)); % a0 transformed to be between 0-1
nd_tau_side = parameters(5); %location stickiness
tau_side = 1/(1+exp(nd_tau_side)); % a0 transformed to be between 0-1

actions = subj.actions;
outcome = subj.outcome;
key = subj.side;

%number of trials
T = size(outcome,1);
%expected value
v = zeros(1,2);
%q-values
q = zeros(1,2);
%choice probability
p = nan(T,1);
%initial stickiness values
stim = 0;
side = 0;

nanMod = 0;

for t = 1:T
    %Adds modifier to indexing based on number of missed key presses. Sets
    %stickinesses to 0 for trials where 
    tmod = t+nanMod;
    if key{tmod} ~= 'NaN'
        %sets stickiness values for all trials other than the first
        if t ~=1
            if actions(t) == actions(t-1)
                stim = 1;
            else 
                stim = 0;
            end
            if key{t} == key{t-1}
                side = 1;
            else
                side = 0;
            end
        end
    else
        nanMod = nanMod + 1;
        stim = 0;
        side = 0;
    end
    
    %determine choice on trial t and set q values
    c = actions(t);
    q(c) = tau_side * side + tau_stim * stim + tau_v * v(c);
    q(c*-1+3) = tau_side * side + tau_stim * 0 + tau_v * v(c*-1+3);
    softmax = exp(q - max(q)) / sum(exp(q - max(q))); %softmax from https://stackoverflow.com/questions/54880369/implementation-of-softmax-function-returns-nan-for-high-inputs
    %softmax = exp(q - (max(q) + log(sum(exp(q-max(q)))))); %softmax from http://haines-lab.com/post/2018-03-24-human-choice-and-reinforcement-learning-3/
    %p1 = 1./(1+exp(-beta*(q(1)-q(2)))); softmax from model_RL
    %p1 = exp(q(1)) / (exp(q(1)) + exp(q(2)))
    %p2 = 1-p1;
    p1 = softmax(1);
    p2 = softmax(2);
    o = outcome(t);
    
    if c == 1
        p(t) = p1;
    elseif c == 2
        p(t) = p2;
    end
    
    pe = o - v(c);
    if pe > 0
        v(c) = v(c) + a_pos * pe;
    else
        v(c) = v(c) + a_neg * pe;
    end
end
    
loglik = sum(log(p+eps));
end
    
    
    
    
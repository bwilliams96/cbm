%{
Model adapted from:
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
nd_a_pos = parameters(1); %learning rate - positive prediction error
a_pos = 1./(1+exp(-nd_a_pos)); % a+ transformed to be between 0-1
nd_a_neg = parameters(2); %learning rate - positive prediction error
a_neg = 1./(1+exp(-nd_a_neg)); % a- transformed to be between 0-1
nd_tau_v = parameters(3); %reinforcement sensitivity
tau_v = exp(nd_tau_v); % reinforcement sensitivity transformed to have minimum bound of 0
tau_stim = parameters(4); %stimulus stickiness
tau_side = parameters(5); %location stickiness

actions = subj.actions;
outcome = subj.outcome;
key = subj.side;
right = subj.right;

%number of trials
T = size(outcome,1);
%expected value
v = zeros(1,2);
left_val = 0; right_val = 0;
%q-values
q = zeros(1,2);
%choice probability
p = nan(T,1);
%side images are shown on
show = zeros(1,2);
%initial stickiness values
side_left = 0;
side_right = 0;

for t = 1:T

    %sets stickiness values for all trials other than the first
    if t ~=1
        %check if right side was selected on the previous trial
        if right(t-1) == 1
            side_right = 1; side_left = 0;
        else
            side_right = 0; side_left = 1;
        end
        %check side images were shown on previous trial for stickiness
        if ((actions(t-1) == actions(t)) && (right(t) == 1)) 
            show = [0,1];
        elseif ((actions(t-1) == actions(t)) && (right(t) == 0)) %image 1 selected on left
            show = [1,0];
        elseif ((actions(t-1) ~= actions(t)) && (right(t) == 1)) %image 2 selected on right
            show = [1,0];
        elseif ((actions(t-1) ~= actions(t)) && (right(t) == 0)) %image 2 selected on left
            show = [0,1];          
        end
        
        %check side images were shown on for current trial for expected value
        if ((actions(t) == 1) && (right(t) == 1)) %image 1 selected on right
            left_val = v(2); right_val = v(1);
        elseif ((actions(t) == 1) && (right(t) == 0)) %image 1 selected on left
            left_val = v(1); right_val = v(2);
        elseif ((actions(t) == 2) && (right(t) == 1)) %image 2 selected on right
            left_val = v(1); right_val = v(2);
        elseif ((actions(t) == 2) && (right(t) == 0)) %image 2 selected on left
            left_val = v(2); right_val = v(1);           
        end
    end
    
    %determine choice on trial t and set q values
    c = actions(t);
    q(1) = tau_side * side_left + tau_stim * show(1) + tau_v * left_val;
    q(2) = tau_side * side_right + tau_stim * show(2) + tau_v * right_val;
    % softmax = exp(q - max(q)) / sum(exp(q - max(q))); is equivalent to
    % Kanen's implimentation
    softmax = exp(q - max(q)) / sum(exp(q - max(q))); %softmax from https://stackoverflow.com/questions/54880369/implementation-of-softmax-function-returns-nan-for-high-inputs
    %softmax = exp(q - (max(q) + log(sum(exp(q-max(q)))))); %softmax from http://haines-lab.com/post/2018-03-24-human-choice-and-reinforcement-learning-3/
    o = outcome(t);
    
    if c == 1
        p(t) = softmax(1);
    elseif c == 2
        p(t) = softmax(2);
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
    
    
    
    
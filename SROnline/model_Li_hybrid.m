%{
Model atapted from:
Differential roles of human striatum and amygdala in associative learning
Authors:
Jian Li,
Daniela Schiller,
Geoffrey Schoenbaum,
Elizabeth A. Phelps,
Nathaniel D. Daw.
https://doi.org/10.1038/nn.2904
%}

function [loglik] = model_Li_hybrid(parameters,subj)
nd_a0 = parameters(1); % initial associability, normally distributed
a0 = exp(nd_a0); % a0 transformed to be > 0
nd_eta = parameters(2); % associability update rate
eta = 1/(1+exp(-nd_eta));
nd_kappa = parameters(3); %associability tuning parameter
kappa = exp(nd_kappa);
%kappa = 1/(1+exp(-nd_kappa));

actions = subj.actions;
outcome = subj.outcome;

T = size(outcome,1);
q = zeros(1,2);
p = nan(T,1);
a = [a0,a0];

for t = 1:T
    softmax = exp(q - max(q)) / sum(exp(q - max(q))); %softmax from https://stackoverflow.com/questions/54880369/implementation-of-softmax-function-returns-nan-for-high-inputs
    %softmax = exp(q - (max(q) + log(sum(exp(q-max(q)))))); %softmax from http://haines-lab.com/post/2018-03-24-human-choice-and-reinforcement-learning-3/
    %p1 = 1./(1+exp(-beta*(q(1)-q(2)))); softmax from model_RL
    %p1 = exp(q(1)) / (exp(q(1)) + exp(q(2)))
    c = actions(t);
    o = outcome(t);
    
    if c == 1
        p(t) = softmax(1);
    elseif c == 2
        p(t) = softmax(2);
    end
      
    pe = o - q(c);
    q(c) = q(c) + kappa*a(c)*pe;
    q(q>1) = 1;
    q(q<-1) = -1;
    a(c) = eta*abs(pe)+(1-eta)*a(c);
end

loglik = sum(log(p+eps));

end
    
    
    
    
side
%%% IMPORTANT NOTE FOR TESTING %%%
%these data removed because 'no positive hessian' found when using Li model
data(7) = [];
data(10) = [];
data(18) = [];
data(23) = [];

%{
First, we should run cbm_lap, which fits every model to each subject data separately (i.e. in a
non-hierarchical fashion). cbm_lap employs Laplace approximation, which needs a normal prior
for every parameter. We set zero as the prior mean. We also assume that the prior variance for
all parameters is 6.25. This variance is large enough to cover a wide range of parameters with no
excessive penalty (see supplementary materials of the reference article for more details on how
this variance is calculated).
%}
v = 6.25;
prior_RL = struct('mean',zeros(2,1),'variance',v); % note dimension of 'mean'
prior_Li = struct('mean',zeros(3,1),'variance',v); % note dimension of 'mean'

% We also need to specify a file-address for saving the output of each model:

fname_RL = 'lap_RL.mat';
fname_Li = 'lap_Li.mat';

% Now we run cbm_lap for each model. Note that model_RL and model_dualRL are both in the current directory.

cbm_lap(data, @model_RL, prior_RL, fname_RL);
cbm_lap(data, @model_Li_hybrid, prior_Li, fname_Li);

% Now we can do hierarchical Bayesian inference using cbm_hbi. cbm_hbi needs 4 inputs. The good news is that you already have all of them!
% 1st input: data for all subjects
data = load('all_data.mat', 'data');
% 2nd input: a cell input containing function handle to models
models = {@model_RL, @model_Li_hybrid};
% note that by handle, I mean @ before the name of the function
% 3rd input: another cell input containing file-address to files saved by cbm_lap
fcbm_maps = {'lap_RL.mat','lap_Li.mat'};
% note that they corresponds to models (so pay attention to the order)
% 4th input: a file address for saving the output
fname_hbi = 'hbi_RL_Li.mat';

cbm_hbi(data,models,fcbm_maps,fname_hbi);

% You can use the group_mean and group_hierarchical_errorbar values to plot group parameters, or use cbm_hbi_plot to plot the main outputs of the HBI.
% 1st input is the file-address of the file saved by cbm_hbi
fname_hbi = 'hbi_RL_Li.mat';

% 2nd input: a cell input containing model names
model_names = {'RL', 'Li Hybrid'};
% note that they corresponds to models (so pay attention to the order)

% 3rd input: another cell input containing parameter names of the winning model
param_names = {'\alpha0','\eta','\kappa'};
% note that '\alpha^+' is in the latex format, which generates a latin alpha

% 4th input: another cell input containing transformation function associated with each parameter of the winning model
transform = {'sigmoid','sigmoid','sigmoid'};
% note that if you use a less usual transformation function, you should pass the handle here (instead of a string)

cbm_hbi_plot(fname_hbi, model_names, param_names, transform)
% this function creates a model comparison plot (exceednace probability and model frequency) as well as 
% a plot of transformed parameters of the most frequent model.

%{
The exceedance probability indicates the probability that each model is the most likely model
across the group.
A more useful metric is called protected exceedance probability, which also takes into account
the null hypothesis that no model in the model space is most likely across the population (i.e. any
difference between model frequencies is due to chance).
%}

fdata = load('all_data.mat');
data = fdata.data;
fname_hbi = 'hbi_RL_dualRL';
cbm_hbi_null(data,fname_hbi);

%Load again hbi_RL_dualRL.mat and look at the protected exceedance probability

fname_hbi = load('hbi_RL_dualRL.mat');
cbm = fname_hbi.cbm;
pxp = cbm.output.protected_exceedance_prob

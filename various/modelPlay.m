% This script demonstrates how the XXX model can be used to simulate
% responses and how to fit the model's parameters to (simulated) data.
% 
% 2023-11-02
% David Meijer, david.meijer@oeaw.ac.at

clearvars;
close all;

%Add the model and its sub-functions to the path
model_path = fileparts(cd);                                                 %Assuming that we are in "various" folder now
addpath(genpath(model_path));    

%% Generate trials and conditions

num_trials = 100;
trials_cell = cell(num_trials,1);  

%Fill trials structure with model-specific fields
for j=1:num_trials
    trials_cell{j}.x = j;
    trials_cell{j}.dummy = 'dummy';
end

%Associate condition numbers with each trial
trl_cond_nrs = ones(num_trials,1);                                          %Odd trial indexes belong to condition 1
trl_cond_nrs(2:2:num_trials) = 2;                                           %Even trial indexes belong to condition 2

%% Create input_data structure 

input_data.trials_cell = trials_cell(:);                                    %Ensure column vectors
input_data.trl_cond_nrs = trl_cond_nrs(:);                                    

%% 1. Produce some figures of predicted responses with some pre-set parameters       

options_struct = [];

%Set some parameter values
options_struct.param_settings.intercept = 5;                                %one shared intercept
options_struct.param_settings.sd = 10;                                      %one shared standard deviation
options_struct.param_settings.slope = [1.1, 1.2];                           %two slopes, one for each condition

XXXfitResults_1 = XXXfitModel(input_data,options_struct);  

%% 2. Simulate responses for one participant with the pre-set parameters

input_data.responses = '2';                                                 %Two simulated responses per trial 
XXXfitResults_2 = XXXfitModel(input_data,options_struct);

%Collect and merge the simulated responses for the same trials
input_data.responses = XXXfitResults_2.generated_responses(:,1);            %We'll use the simulated responses for the fits below
for j=1:num_trials
    input_data.responses{j,1}.y = [input_data.responses{j,1}.y, XXXfitResults_2.generated_responses{j,2}.y];
end

%% 3. Call model to compute just a single log likelihood (LL)

options_struct.fit_settings.gen_predictions = false;                        %Don't create predictions (therefore also no figures), default = true 

%With the correct param settings
XXXfitResults_3a = XXXfitModel(input_data,options_struct);             
disp('LL with correct params: '); disp(XXXfitResults_3a.LL_total);

%Set different parameter settings and compute again
param_settings_backup = options_struct.param_settings;
options_struct.param_settings.intercept = 0;                                %one shared intercept
options_struct.param_settings.sd = 5;                                       %one shared standard deviation
options_struct.param_settings.slope = [1, 1];                               %two slopes, one for each condition

XXXfitResults_3b = XXXfitModel(input_data,options_struct);                  %The LL with wrong params should be lower than the LL with correct params
disp('LL with wrong params: '); disp(XXXfitResults_3b.LL_total);

%% 4. Fit parameters to the simulated dataset 

options_struct = rmfield(options_struct,'param_settings');                  %Remove the fixed parameter settings that we used above

options_struct.fit_settings.fit_param_names = {'intercept','sd','slope','slope'};                       %The names of the parameters to fit 
options_struct.fit_settings.fit_param_nrs_per_cond = {[1 2 3],[1 2 4]};     %The first two parameters belong to both conditions, whereas param 3 is for cond 1 and param 4 for cond 2.

options_struct.fit_settings.gen_predictions = true;                         %Generate predictions with the fitted parameters 
options_struct.disp_settings.overall = true;                                %Display overall results (default = true) 

%Use a t-distribution to compute the likelihood of the errors
XXXfitResults_4a = XXXfitModel(input_data,options_struct);                  %The t-distribution is used for "robust" regression

disp('Comparison with the backed-up correct parameters:'); 
disp(param_settings_backup);

%Use a normal distribution to compute the likelihood of the errors
options_struct.model_settings.use_t_distribution = false;                   %Default is true

XXXfitResults_4b = XXXfitModel(input_data,options_struct);                  %In this case the normal distribution works better, because the errors are perfectly normally distributed without outliers

%Do not fit the sd as a free parameter
options_struct.fit_settings.fit_param_names = {'intercept','slope','slope'};                       %The names of the parameters to fit 
options_struct.fit_settings.fit_param_nrs_per_cond = {[1 2],[1 3]};         %The first parameter belongs to both conditions, whereas param 2 is for cond 1 and param 3 for cond 2.

XXXfitResults_4c = XXXfitModel(input_data,options_struct);                  %The result is very similar to 4b, because the maximum likelihood for intercept and slope leads to a RMSE that is identical to the optimal sd. 

%% 5. Compare to standard regression with Matlab's "fitlm" function

x_all = cellfun(@(x) x.x,trials_cell);
x_cond1 = reshape(repmat(x_all(trl_cond_nrs == 1),[1 2])',[num_trials 1]);
x_cond2 = reshape(repmat(x_all(trl_cond_nrs == 2),[1 2])',[num_trials 1]);

x_cond1 = [x_cond1; zeros(num_trials,1)];
x_cond2 = [zeros(num_trials,1); x_cond2];

y_all = cell2mat(cellfun(@(x) x.y,input_data.responses,'UniformOutput',false));
y_cond1 = reshape(y_all(trl_cond_nrs == 1,:)',[num_trials 1]);
y_cond2 = reshape(y_all(trl_cond_nrs == 2,:)',[num_trials 1]);

fitlm_fitResults = fitlm([x_cond1 x_cond2],[y_cond1; y_cond2]); 
disp(fitlm_fitResults);                                                     %Results should be very similar to 4b and 4c (n.b. RMSE here has the same meaning as "sd" above)

disp('LL with t-distribution: '); disp(XXXfitResults_4a.fit.prob.logLikelihood);
disp('LL with normal distribution and free sd: '); disp(XXXfitResults_4b.fit.prob.logLikelihood);
disp('LL with normal distribution and RMSE as sd: '); disp(XXXfitResults_4c.fit.prob.logLikelihood);
disp('LL with fitlm: '); disp(fitlm_fitResults.LogLikelihood);              %The likelihoods also correspond


%% 6. Do a model comparison to see whether the slopes are significantly different

input_data.trl_cond_nrs(:) = 1;                                             %Assign condition number 1 to all trials (i.e. no more condition 2)    

options_struct.fit_settings.fit_param_names = {'intercept','slope'};        %Only fit one slope parameter
options_struct.fit_settings.fit_param_nrs_per_cond = {[1 2]};               %Both parameters belong to the one and only condition    

XXXfitResults_6 = XXXfitModel(input_data,options_struct);                   
disp('LL with only one slope param: '); disp(XXXfitResults_6.fit.prob.logLikelihood);

%Perform a likelihood ratio test using the chi square distribution
chi_stat = -2*(XXXfitResults_6.fit.prob.logLikelihood-XXXfitResults_4c.fit.prob.logLikelihood);
df = 1;
p = chi2cdf(chi_stat,df,'upper'); 
disp('Likelihood ratio test for differences between slopes: '); disp(['p = ' num2str(p)]);

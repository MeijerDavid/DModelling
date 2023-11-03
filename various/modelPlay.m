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

XXXfitModel_1 = XXXfitModel(input_data,options_struct);  

%% 2. Simulate responses for one participant with the pre-set parameters

input_data.responses = '2';                                                 %Two simulated responses per trial 
XXXfitModel_2 = XXXfitModel(input_data,options_struct);

%Collect and merge the simulated responses for the same trials
input_data.responses = XXXfitModel_2.generated_responses(:,1);              %We'll use the simulated responses for the fits below
for j=1:num_trials
    input_data.responses{j,1}.y = [input_data.responses{j,1}.y, XXXfitModel_2.generated_responses{j,2}.y];
end

%% 3. Call model to compute just a single log likelihood (LL)

options_struct.fit_settings.gen_predictions = false;                        %Don't create predictions (therefore also no figures), default = true 

%With the correct param settings
XXXfitModel_3a = XXXfitModel(input_data,options_struct);             
disp('LL with correct params: '); disp(XXXfitModel_3a.LL_total);

%Set different parameter settings and compute again
param_settings_backup = options_struct.param_settings;
options_struct.param_settings.intercept = 0;                                %one shared intercept
options_struct.param_settings.sd = 5;                                       %one shared standard deviation
options_struct.param_settings.slope = [1, 1];                               %two slopes, one for each condition

XXXfitModel_3b = XXXfitModel(input_data,options_struct);                    %The LL with wrong params should be lower than the LL with correct params
disp('LL with default params: '); disp(XXXfitModel_3b.LL_total);

%% 4. Fit parameters to the simulated dataset 

options_struct.fit_settings.fit_param_names = {'intercept','sd','slope','slope'};                       %The names of the parameters to fit 
options_struct.fit_settings.fit_param_nrs_per_cond = {[1 2 3],[1 2 4]};     %The first two parameters belong to both conditions, whereas param 3 is for cond 1 and param 4 for cond 2.

options_struct.fit_settings.gen_predictions = true;                         %Generate predictions with the fitted parameters 
options_struct.disp_settings.overall = true;                                %Display overall results (default = true) 

%Use a t-distribution to compute the likelihood of the errors
XXXfitModel_4a = XXXfitModel(input_data,options_struct);                    %The t-distribution is used for "robust" regression

disp('Comparison with the backed-up correct parameters:'); 
disp(param_settings_backup);

%Use a normal distribution to compute the likelihood of the errors
options_struct.model_settings.use_t_distribution = false;                   %Default is true

XXXfitModel_4b = XXXfitModel(input_data,options_struct);                    %In this case the normal distribution works better, because the errors are perfectly normally distributed without outliers

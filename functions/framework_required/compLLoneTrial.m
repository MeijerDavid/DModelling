function LL_trial_struct = compLLoneTrial(trial_responses,trial_data,param_settings,model_settings,fit_settings)
%Compute log likelihood for one or more responses on this particular trial.   
%If there are multiple responses, then their LLs form a column vector.

%Normally, compute one LL per response on this trial and save it in the LL field. 
LL_trial_struct.LL = [];

%Alternatively, you can add other fields and use those in postprocessLLs.m to compute the likelihoods for all trials simultaneously.  
LL_trial_struct.errors = [];

%%% Regression example %%%

%Create model predictions
x = trial_data.x;
intercept = param_settings.intercept;                                           
slope = param_settings.slope;   
y_pred = intercept + slope*x;

%Remove NaNs from the responses to avoid NaNs in the log-likelihoods
y = trial_responses.y;
y(isnan(y)) = [];

%Compute the prediction errors
LL_trial_struct.errors = y_pred-y;

end %[EoF]

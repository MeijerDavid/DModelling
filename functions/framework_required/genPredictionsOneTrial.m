function pred_trial_struct = genPredictionsOneTrial(trial_data,param_settings,model_settings,fit_settings,trial_responses)
%Generate predictions for one trial 

%Create model predictions
x = trial_data.x;
intercept = param_settings.intercept;                                           
slope = param_settings.slope;   
y_pred = intercept + slope*x;

%Save in output struct
pred_trial_struct.y = y_pred;

end %[EoF]

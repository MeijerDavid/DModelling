function generated_responses_trial = genRespOneTrial(N,trial_data,param_settings,model_settings,fit_settings)
%Generate N responses for one particular trial. 

%Initialize output
generated_responses_trial = cell(1,N);

%Create model predictions
x = trial_data.x;
intercept = param_settings.intercept;                                           
slope = param_settings.slope;   
y_pred = intercept + slope*x;

%Add noise to create 'responses'
SD = param_settings.sd; 
y_resp = SD*randn([1 N]) + y_pred;

%Save responses in the cell-array
for j=1:N
    generated_responses_trial{1,j}.y = y_resp(j);
end

end %[EoF]

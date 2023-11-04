function LL_trial_struct = compLLoneTrial(trial_responses,trial_data,param_settings,model_settings,fit_settings)
%Compute log likelihood for one or more responses on this particular trial.   

%Create model predictions
x = trial_data.x;
intercept = param_settings.intercept;                                           
slope = param_settings.slope;   
y_pred = intercept + slope*x;

%Remove NaNs from the responses to avoid NaNs in the log-likelihoods
y = trial_responses.y;
y(isnan(y)) = [];

%Compute prediction errors and save them (for optional use in postprocessLLs.m)   
errors = y_pred-y;
LL_trial_struct.errors = errors;

%Compute log-likelihoods (one for each response) and save them in output structure 
SD = param_settings.sd;
        
if model_settings.use_t_distribution

    %We use the t-distribution instead of a normal distribution to better deal with outliers (i.e. heavy tails instead of a lapse rate). 
    %E.g. see https://solomonkurz.netlify.app/blog/2019-02-02-robust-linear-regression-with-student-s-t-distribution/
    %tpdf_v5 = @(t) 8./(3*pi*sqrt(5)*(1+t.^2./5).^3);               %t-distribution with nu=5 (d.f.) https://en.wikipedia.org/wiki/Student%27s_t-distribution
    log_tpdf_v5 = @(t) log(8)-log(3*pi*sqrt(5))-3*log(1+t.^2./5);   %Apparently, using 5 d.f. is recommended in: Modern Applied Statistics with S 4th Ed, Venables & Ripley (2002)    
    %LL_trial_struct.LL = log(tpdf_v5(errors./SD)./SD);             %https://stats.stackexchange.com/questions/193692/how-to-choose-t-distribution-degrees-of-freedom-in-robust-bayesian-linear-mode
    LL_trial_struct.LL = log_tpdf_v5(errors./SD)-log(SD);           %And see here for explanation of division by SD: https://stats.stackexchange.com/questions/232263/t-distribution-likelihood

else %Use normal distribution

    LL_trial_struct.LL = -0.5 * (errors./SD).^2 - log(SD) - 0.5*log(2*pi);
end

end %[EoF]

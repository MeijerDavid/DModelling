function [LL_total,LL_trials] = postprocessLLs(LL_trials_cell,LL_total,trial_nr,trl_cond_nrs,param_settings_cond,model_settings,fit_settings)
% Use content in LL_trials_cell to post-process or compute log likelihoods

% % Default per trial: Simply sum the log likelihoods
% LL_total = LL_total + sum(LL_trials_cell{trial_nr}.LL(:));                  %sum over multiple responses
% 
% % Default at the end: Create one column vector of log-likelihoods (across trials and responses)
% if nargout >= 1
%     LL_trials = cell2mat(reshape(cellfun(@(x) x.LL(:),LL_trials_cell,'UniformOutput',false),[numel(LL_trials_cell),1]));
% 
%     % Check for NaNs in the log-likelihoods
%     assert(~any(isnan(LL_trials)),'There are NaNs in the log-likelihoods, something is likely wrong. E.g. check that NaN responses are removed successfully in compLLoneTrial.m');
% end

%% Alternatively, you may want to compute the log-likelihoods here for all trials simultaneously - e.g. using a robust regression method

LL_total = LL_total + 0;

if nargout >= 2
    
    LL_trials = cell(fit_settings.num_conds,1);
    errors_cell = reshape(cellfun(@(x) x.errors(:),LL_trials_cell,'UniformOutput',false),[numel(LL_trials_cell),1]);
    
    for c=1:fit_settings.num_conds
        
        errors = cell2mat(errors_cell(trl_cond_nrs == c));
        %SD = std(errors);
        param_settings = param_settings_cond{c};
        SD = param_settings.sd;
        
        if model_settings.use_t_distribution
            
            %We use the t-distribution instead of a normal distribution to better deal with outliers (i.e. heavy tails instead of a lapse rate). 
            %E.g. see https://solomonkurz.netlify.app/blog/2019-02-02-robust-linear-regression-with-student-s-t-distribution/
            %tpdf_v5 = @(t) 8./(3*pi*sqrt(5)*(1+t.^2./5).^3);               %t-distribution with nu=5 (d.f.) https://en.wikipedia.org/wiki/Student%27s_t-distribution
            log_tpdf_v5 = @(t) log(8)-log(3*pi*sqrt(5))-3*log(1+t.^2./5);   %Apparently, using 5 d.f. is recommended in: Modern Applied Statistics with S 4th Ed, Venables & Ripley (2002)    
            %LL_trials{c} = log(tpdf_v5(errors./SD)./SD);                   %https://stats.stackexchange.com/questions/193692/how-to-choose-t-distribution-degrees-of-freedom-in-robust-bayesian-linear-mode
            LL_trials{c} = log_tpdf_v5(errors./SD)-log(SD);                 %And see here for explanation of division by SD: https://stats.stackexchange.com/questions/232263/t-distribution-likelihood

        else %Use normal distribution
        
            LL_trials{c} = -0.5 * (errors./SD).^2 - log(SD) - 0.5*log(2*pi);
        end
    end
        
    LL_trials = cat(1,LL_trials{:}); 
    
    % Check for NaNs in the log-likelihoods
    assert(~any(isnan(LL_trials)),'There are NaNs in the log-likelihoods, something is likely wrong. E.g. check that NaN responses are removed successfully in compLLoneTrial.m');
end 
    
end %[EoF]

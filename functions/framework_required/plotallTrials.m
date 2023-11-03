function plotallTrials(trials_cell,trl_cond_nrs,predictions,responses,param_settings_cond,model_settings,fit_settings)
%Plot model predictions summarized across all trials

%Open a new figure
figure('WindowState', 'maximized','Name','Regression example: all trials');
box on; hold on;

%We assume two conditions
num_conds = fit_settings.num_conds;

colours_cond = {'r','b'};

%Loop over the trials 
h_pred = nan(1,num_conds);
h_resp = nan(1,num_conds);
x_min = inf;
x_max = -inf;
y_min = inf;
y_max = -inf;
for j=1:numel(trials_cell)
    
    c = trl_cond_nrs(j);
    x = trials_cell{j}.x;
    y_pred = predictions{j}.y;    
        
    %Plot responses if available
    if isfield(responses{j},'y')
        y_resp = responses{j}.y;
        x_resp = x*ones(size(y_resp));
        h_resp(c) = plot(x_resp(:),y_resp(:),'o','Color',colours_cond{c});
    else
        y_resp = NaN;
    end 
    
    %Track min and max
    x_min = min(x_min,x); x_max = max(x_max,x); 
    y_min = min([y_min; y_pred; y_resp(:)]); y_max = max([y_max; y_pred; y_resp(:)]); 
end

%Also plot the regression line according to the parameters
for c=1:num_conds
    
    intercept = param_settings_cond{c}.intercept;                                           
    slope = param_settings_cond{c}.slope;   
    
    x = [x_min x_max];
    y_pred = intercept + slope*x;
    h_pred(c) = plot(x,y_pred,'-','Color',colours_cond{c});
    
    %Ensure validity of handle
    if isnan(h_resp(c))
        h_resp(c) = plot(x_min-10,y_min-10,'o','Color',colours_cond{c});
    end
end

%Finish the plot
xlim([x_min x_max]); ylim([y_min y_max]); 
legend([h_resp,h_pred],{'resp cond 1','resp cond 2','pred cond 1','pred cond 2'},'location','best');
xlabel('input x'); ylabel('outcome y'); title('Regression results');

end %[EoF]

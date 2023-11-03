function XXXfitResults = XXXfitModel(input_data,options_struct)
% XXXfitResults = XXXfitModel(input_data,options_struct)
%
% Fit various versions of the XXX model ...
%
% The XXX model makes use of David Meijer's general modelling framework. 
% Please see "fitModelStart.m" for a concise description of the input 
% arguments. For example usage, see "modelPlay.m" in the various folder.
%
% Author: David Meijer
% Affiliation: Acoustics Research Institute, Austrian Academy of Sciences
% Communication: MeijerDavid1@gmail.com
%
% Version: 03-11-2023

%% Add "functions" folder and its subfolders to the Matlab path

me = mfilename;                                                             %what is my filename
pathstr = fileparts(which(me));                                             %get my location
addpath(genpath([pathstr filesep 'functions']));                                     

%% Call the start function of the general modelling framework

XXXfitResults = fitModelStart(input_data,options_struct);

end %[EoF]

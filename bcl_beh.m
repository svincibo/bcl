clear all; close all; clc;

addpath(genpath(fullfile('Applications', 'Psychtoolbox')));

% Add location of support files to path.
localdir = '/Users/dfdf/Desktop/bcl-beh/';
addpath(genpath(fullfile(localdir, 'supportFiles')));

% User input.
prefs.subID = str2num(deblank(input('\nPlease enter the subID number (e.g., 101): ', 's')));%'101';

% Practice.
bcl_test_practice(prefs.subID);

if mod(prefs.subID, 2) == 0
    
    % even
    bcl_test(prefs.subID);
    bcl_test_gen(prefs.subID);
    
else
    
    % odd
    bcl_test_gen(prefs.subID);
    bcl_test(prefs.subID);
    
end



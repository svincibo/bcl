% WML_test.m

% Originally written by Krista Ehinger, December 2012
% Downloaded on Oct 2, 2020 from : http://www.kehinger.com/PTBexamples.html
% Modified by Sophia Vinci-Booher in 2020

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up the experiment (don't modify this section)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sca; clear all; clc;
Screen('Preference','SkipSyncTests', 1);
PsychJavaTrouble;
localdir = '/Users/dfdf/Desktop/bcl/';
savedir = '/Users/dfdf/Desktop/bcl/data';

% Add location of support files to path.
addpath(genpath(fullfile(localdir, 'supportFiles')));
addpath(genpath(fullfile(localdir, 'stimuli')));

settingsImageSequence_mri; % Load all the settings from the file
rand('state', sum(100*clock)); % Initialize the random number generator
symbolduration = 1;
isi = [1.3 1.5 1.7]; % 1 seconds for TR = 1
drawduration = 4;
wei = [1.7 1.5 1.3];
epochduration = 8;

% User input.
prefs.subID = str2num(deblank(input('\nPlease enter the subID number (e.g., 101): ', 's')));%'101';

% Load in the mapping between the subID and training group.
load(fullfile(localdir, 'supportFiles/bcl_subID_mappings.mat'));

%% Set session information.

% symbol counterbalance group: 1, 2, 3
prefs.group = symbol_counterbalance_group(find(subID == prefs.subID));
% scanning day: 1, 2, 3
prefs.day = 1; %str2num(deblank(input('\nPlease enter the MRI day (e.g., 1, 2, or 3): ', 's')));%'1';
% functional run: 1, 2
prefs.run = str2num(deblank(input('\nPlease enter the MRI run number (e.g., 0, 1, or 2): ', 's')));%'1';

% ch = input(['You have indicated that this run number ' num2str(prefs.run) ' of MRI day ' num2str(prefs.day) ' for participant ' num2str(prefs.subID) '. Is this entirely correct [y, n]? '], 's');
% if strcmp(ch, 'no') || strcmp(ch, 'NO') || strcmp(ch, 'n') || strcmp(ch, 'N')
%     error('Please start over and be sure to enter the information correctly.');
% elseif ~strcmp(ch, 'yes') && ~strcmp(ch, 'YES') && ~strcmp(ch, 'y') && ~strcmp(ch, 'Y')
%     error('Your response must be either y or n. Please start over and be sure to enter the information correctly.');
% end
% clear ch

%%%%%%%%%%%%%%%%%%%%% Parameters: DO NOT CHANGE. %%%%%%%%%%%%%%%%%%%%%%%%
prefs.backcolor = [255 255 255];   % (0 0 0) is black, (255 255 255) is white, (220 220 220) is gainsboro (i.e., light gray)
prefs.forecolor = [0 0 0];
prefs.penWidth = 6; % You can increase the thickness of the pen-tip by increasing this number, but there's a limit to the thickness... around 10 maybe.
prefs.scale = 150;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Screen.
prefs.s1 = max(Screen('Screens')); % Choose the screen that is most likely not the controller screen.
prefs.s0 = min(Screen('Screens')); % Find primary screen.

%% Select window according to number of screens present. (Assumes that the desired device for display will have the highest screen number.)

% Choose dimension of window according to available screens. If only one
% screen available, them set the window to be a short portion of it b/c
% testing. If two screens are available, then set the window to be the
% % second screen b/c experiment.
prefs.w1Size = [0 0 1921 1201]; %[0 0 640 480]; %[0 0 1921 1201];
prefs.w1Width = prefs.w1Size(3); prefs.w1Height = prefs.w1Size(4);
prefs.xcenter = prefs.w1Width/2; prefs.ycenter = prefs.w1Height/2;
% Dimensions of stimulus presentation area.
prefs.rectForStim = [prefs.w1Width/2-prefs.scale/2 prefs.w1Height/2-prefs.scale/2 prefs.w1Width/2+prefs.scale/2 prefs.w1Height/2+prefs.scale/2];

% Hide cursor and orient to the Matlab command window for user input.
commandwindow;

% Keyboard setup
KbName('UnifyKeyNames');
KbCheckList = [KbName('space'),KbName('ESCAPE')];
for i = 1:length(responseKeys)
    KbCheckList = [KbName(responseKeys{i}),KbCheckList];
end
RestrictKeysForKbCheck(KbCheckList);

% Screen setup
clear screen

%% Select window according to number of screens present. (Assumes that the desired display device will have the highest screen number.)

% Choose dimension of window according to available screens. If only one
% screen is available, them set the window to be a short portion of it b/c
% testing. If two screens are available, then set the window to be the
% second screen b/c experiment.
whichScreen = prefs.s0; %0 is computer, 1 is tablet
[window1, ~] = Screen('Openwindow', whichScreen, prefs.backcolor, prefs.w1Size,[],2);
slack = Screen('GetFlipInterval', window1)/2;
prefs.w1 = window1;
W=prefs.w1Width; % screen width
H=prefs.w1Height; % screen height

Screen(prefs.w1,'FillRect',prefs.backcolor);
Screen('Flip', prefs.w1);
HideCursor([], prefs.w1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up stimuli lists and results file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the image files for the experiment. There are different groups
% because the target/distractor symbols were counterbalanced across
% subjects.

% If run = 0, then this is practice.
if prefs.run == 0
    
    nTrials = 6;
    nBlocks = 1;
    fixdur = 2;
    
    % Get letters/shapes for practice.
    imageFolder = fullfile(localdir, 'stimuli', 'typed_shapes');
    tsymbol_dir = dir(fullfile(localdir, 'stimuli', 'typed_shapes/s*'));
    
else
    
    nTrials = 40;
    nBlocks = 1;
    fixdur = 20;
    
    % Get symbols for training.
    if prefs.group == 1
        imageFolder = fullfile(localdir, 'stimuli', 'symbols_all_group1');
    elseif prefs.group == 2
        imageFolder = fullfile(localdir, 'stimuli', 'symbols_all_group2');
    elseif prefs.group == 3
        imageFolder = fullfile(localdir, 'stimuli', 'symbols_all_group3');
    end
    
    % Read in target symbols.
    if prefs.group == 1
        tsymbol_dir = dir(fullfile(localdir, 'stimuli', 'symbols_all_group1/S*'));
    elseif prefs.group == 2
        tsymbol_dir = dir(fullfile(localdir, 'stimuli', 'symbols_all_group2/S*'));
    elseif prefs.group == 3
        tsymbol_dir = dir(fullfile(localdir, 'stimuli', 'symbols_all_group3/S*'));
    end
end

% Remove the '.' and '..' files.
tsymbol_dir = tsymbol_dir(arrayfun(@(x) x.name(1), tsymbol_dir) ~= '.');

% Get the noise image files for the experiment
n_imageFolder = fullfile(localdir, 'stimuli', 'noise_masks');
n_imgList = dir(fullfile(n_imageFolder, 'nm*.bmp'));

% Set up the output files
outputfile = fopen([savedir '/mri_sub' num2str(prefs.subID) '_session' num2str(prefs.day) '_run' num2str(prefs.run) '_' datestr(now,'yyyy-mm-dd-_HH-MM') '.txt'], 'a');
fprintf(outputfile, 'onset\tduration\ttrialtype\n');

% Start screen
Screen('FillRect', prefs.w1, prefs.backcolor);
PresentCenteredText(prefs.w1,'Ready?', 60, prefs.forecolor, prefs.w1Size);
Screen('Flip',prefs.w1);
% WaitSecs(1);
% clear all; clc; sca;
% fclose(outputfile);

% Wait for RA to press spacebar
while 1
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyCode(KbName('space'))==1
        break
    end
end
baseline = GetSecs;
tic;
count = 0;
for b = 1:nBlocks
    
    disp(['Block ', num2str(b)])
    count = count + 1;
    
    % Fixation block before and after every condition block.
    % Show fixation cross
    drawCross(prefs.w1,W,H);
    tFixation = Screen('Flip', prefs.w1);
    
    % Record.
    if b == 1
        tStartAll = tFixation;
        fixationDuration = fixdur;
        fprintf(outputfile, '%2.2f\t%2.2f\tfixation\n', tFixation-tStartAll, fixationDuration);
    else
        fixationDuration = 12; % Length of fixation in seconds
        fprintf(outputfile, '%2.2f\t%2.2f\tfixation\n', tFixation-tStartAll, fixationDuration);
    end
    
    % Blank screen
    Screen(window1, 'FillRect', prefs.backcolor);
    Screen('Flip', prefs.w1, tFixation + fixationDuration - slack,0);
    
    % Randomize the trial list
    randomizedTrials = randperm(nTrials);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Run experiment
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    trial = 0;
    % Run experimental trials
    for t = randomizedTrials
        
        % Trial counter.
        trial = trial + 1;
        
        % Randomly select the isi/wei for this trial.
        idx = randi(3);
        
        % Load symbol image
        file = tsymbol_dir(t).name;
        img = imread(fullfile(imageFolder,file));
        imageDisplay = Screen('MakeTexture', prefs.w1, img);
        
        % Load noise image
        nimg = imread(fullfile(n_imageFolder , n_imgList(t).name));
        nimageDisplay = Screen('MakeTexture', prefs.w1, nimg);
        
        % Screen priority
        Priority(MaxPriority(prefs.w1));
        Priority(2);
        
        %% Stimulation Time 1: typed symbol
        
        % Show the typed symbol
        Screen(prefs.w1, 'FillRect', prefs.backcolor);
        Screen('DrawTexture', prefs.w1, imageDisplay, [], prefs.rectForStim);
        startTime = Screen('Flip', prefs.w1); % Start of trial
        
        while ((GetSecs - startTime) < symbolduration)
            
            [keyIsDown,secs,keyCode] = KbCheck;
            pressedKeys = find(keyCode);
            
            % ESC key quits the experiment
            if keyCode(KbName('ESCAPE')) == 1
                %                 clear all
                close all
                sca
                return;
            end
            
        end
        
        %% Stimulation Time 2:  noise for 2 seconds.
        
        % Replace symbol with noise after display is over.
        Screen(prefs.w1, 'FillRect', prefs.backcolor);
        Screen('DrawTexture', prefs.w1, nimageDisplay, [], prefs.rectForStim);
        endTime = Screen('Flip', prefs.w1); % End of trial
        fprintf(outputfile, '%1.2f\t%1.2f\twatch\t%s\n', startTime-baseline, endTime-startTime, tsymbol_dir(t).name);
        startTime_noise = endTime;
        
        while (GetSecs - startTime) < symbolduration + isi(idx)
            
            [keyIsDown,secs,keyCode] = KbCheck;
            pressedKeys = find(keyCode);
            
            % ESC key quits the experiment
            if keyCode(KbName('ESCAPE')) == 1
                %                 clear all
                close all
                sca
                return;
            end
            
        end
        
        %% Stimulation Time 2: draw for 4 seconds.
        
        % Move mouse to projector
        %         SetMouse((ceil(prefs.w1Width / 2) + prefs.w0Width), ceil(prefs.w1Height / 2))
        
        prefs.lengthEvents = drawduration;
        [prefs, tnow] = drawInk2(prefs); %for wacom tablet
        startTime = prefs.startTime;
        fprintf(outputfile, '%1.2f\t%1.2f\tnoisemask\n', startTime_noise-baseline, tnow-startTime_noise);
        
        endTime = prefs.endTime;
        fprintf(outputfile, '%1.2f\t%1.2f\tdraw\t%s\n', startTime-baseline, endTime-startTime, tsymbol_dir(t).name);
        
        % Append the sample from this round to the end of the sample struct.
        sample(count).subID = prefs.subID;
        sample(count).group = prefs.group;
        sample(count).day = prefs.day;
        sample(count).symbolname = file;
        sample(count).block = b;
        sample(count).trial = trial;
        
        % Save drawing duration.
        if max(prefs.time)-min(prefs.time) > 0.01
            
            sample(count).drawduration = max(prefs.time)-min(prefs.time);
            
        else
            sample(count).drawduration = NaN;
            
        end
        
        % Save dynamic stim for yoked participant.
        sample(count).dynamicStim = prefs.dynamicStim;
        
        % Save static stim.
        sample(count).staticStim = prefs.image;
        
        %% Stimulation Time 4: rest for jittered interval.
        drawCross(prefs.w1,W,H);
        Screen('Flip', prefs.w1);
        while (GetSecs - startTime) < epochduration
            
            [keyIsDown,secs,keyCode] = KbCheck;
            pressedKeys = find(keyCode);
            
            % ESC key quits the experiment
            if keyCode(KbName('ESCAPE')) == 1
                %                 clear all
                close all
                sca
                return;
            end
            
        end
        
        disp(trial);
        
    end
    
    % Final fixation
    if b == nBlocks
        
        % Show fixation cross
        fixationDuration = fixdur; % Length of fixation in seconds
        drawCross(prefs.w1,W,H);
        tFixation = Screen('Flip', prefs.w1);
        %         fprintf(outputfile, '======= Beginning of final9 fixation at %2.2f ======\n', tFixation-tStartAll);
        fprintf(outputfile, '%2.2f\t%2.2f\tfixation\n', tFixation-tStartAll, fixationDuration);
        
        % Blank screen
        Screen(window1, 'FillRect', prefs.backcolor);
        Screen('Flip', prefs.w1, tFixation + fixationDuration - slack,0);
        fprintf(outputfile, '======= End at %2.2f ======\n', GetSecs-tStartAll);
        
    end
        
end

save(fullfile(savedir, ['bcl_mri_sub' num2str(prefs.subID) '_session' num2str(prefs.day) '_run' num2str(prefs.run) '_' datestr(now,'yyyy-mm-dd-_HH-MM') '.mat']));
ShowCursor;
% ListenChar(0);
%
% % Backup cloud storage to local device.
% copyfile(fullfile(savedir, ['bcl_mri_sub' num2str(prefs.subID) '_session' num2str(prefs.day) '_run' num2str(prefs.run) '_' datestr(now,'yyyy-mm-dd-_HH-MM') '.mat']), fullfile(localdir, 'data'));
% copyfile(fullfile(savedir, ['bcl_mri_sub' num2str(prefs.subID) '_session' num2str(prefs.day) '_run' num2str(prefs.run) '_' datestr(now,'yyyy-mm-dd-_HH-MM') '.txt']), fullfile(localdir, 'data'));
toc;
% Start screen
Screen('FillRect', prefs.w1, prefs.backcolor);
PresentCenteredText(prefs.w1,'All done!', 60, prefs.forecolor, prefs.w1Size);
Screen('Flip',prefs.w1);
% Wait for RA to press spacebar
while 1
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyCode(KbName('space'))==1
        break
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End the experiment (don't change anything in this section)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RestrictKeysForKbCheck([]);
fclose(outputfile);
Screen(window1,'Close');
close all
sca;
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% Copyright NordicNeuroLab AS 2021 %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% File:          VSHD_example2D.m
%% Init Author:   ”Carl Fredrik Haakonsen” <cfhaakonsen@gmail.com>
%% Init Date:     2021-08-05
%% Project:       VSHD – PsychToolbox Usage Example
%% Description:   2D example script for psychtoolbox using VSHD
%%
%% To run this script you must first set the screen ID to the screen
%% corresponding to VSHD. This is set through the variable "screenNumber".
%% For details on how to set up the display for VSHD, see the article 
%% "Display Setup for Visual Stimuli using VSHD". This script is compatible 
%% with setup 1M or 2M. 
%% 
%% The script  will show rotating squares and textures. It is a modified
%% version of "Internal External Texture Rotation Demo" from 
%% http://peterscarfe.com/rotationsdemo.html. 
%% Added for use with VSHD is geometric distortion correction and 
%% informative text. 
%%
%% In the "Setup parameters" section of the code, different parameters can be
%% changed. First is the screen the stimuli will be displayed on. Also the
%% calibration file that is loaded can be chosen here. If no calibration is
%% wanted, simply comment out the two lines adding geometry correction. The text
%% and text parameters can also be changed i the parameters section. The speed
%% of rotation for the squares/textures can be set through angleInc. The color 
%% of the squares can be modified through colorMod. Other parameters can of
%% course be changed as well, the ones mentioned above are just those put in the 
%% parameters section. 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clear the workspace
close all;
clearvars;
sca;

%-----------------------------------------------------------------------------
%                          Setup parameters
%-----------------------------------------------------------------------------

% Set the screenNumber to the ID of the VSHD display.
screenNumber = 2;

% Filename of the geometry correction file
calibFilename = 'geoCalibVshd0diop.mat';

% Text to be displayed before the stimuli
preInfoText = 'Example of 2D stimuli for VSHD';

% The duation of the information in seconds
preInfoDuration = 2;

% Text to be shown along with the stimuli
stimuliText = 'Press any key to exit';

% Text parameters
textSize = 40;
font = 'Courier';

% Angle increment per frame
angleInc = 2;

% Color Modulation. This will be the color for each of the squares. 
% From left; white, red, green and blue.
colorMod = [1 1 1; 1 0 0; 0 1 0; 0 0 1]';

%-----------------------------------------------------------------------------
%                            Set up screen
%-----------------------------------------------------------------------------

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Skip sync tests for this demo in case people are using a defective
% system. This is for demo purposes only.
Screen('Preference', 'SkipSyncTests', 2);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
inc = white - grey;

% Correct for distortion with the calibration file given by the variable 
% "calibFilename". Comment out these two lines if no correction is wanted. 
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'AllViews', 'GeometryCorrection', calibFilename);

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%-----------------------------------------------------------------------------
%                            Set up stimuli
%-----------------------------------------------------------------------------

% Dimension of our texure (it will be this value +1 pixel
dim = 100;

% Make a second dimension value which is increased by a factor of the
% squareroot of 2. We need to do this because in this demo we will be using
% internal texture rotation. We round this to the nearest pixel.
dim2 = ceil(dim * sqrt(2));

% Define a simple spiral texture by defining X and Y coordinates with the
% meshgrid command, converting these to polar coordinates and finally
% defining the spiral texture. Not here we use dim2 NOT dim.
[x, y] = meshgrid(-dim2:1:dim2, -dim2:1:dim2);
[th, r] = cart2pol(x, y);
wheel = grey + inc .* cos(pi * th);

% Make our sprial texure into a screen texture for drawing
spiralTexture = Screen('MakeTexture', window, wheel);

% We are going to draw four textures to show how a black and white texture
% can be color modulated upon drawing.
yPos = yCenter;
xPos = linspace(screenXpixels * 0.2, screenXpixels * 0.8, 4);

% Define the destination rectangles for our spiral textures. This will be
% the same size as the window we use to view our texture.
ndim = dim * 2 + 1;
baseRectDst = [0 0 ndim ndim];
dstRects = nan(4, 4);
for i = 1:4
    dstRects(:, i) = CenterRectOnPointd(baseRectDst, xPos(i), yPos);
end

% Now we create a window through which we will view our texture. This is
% the same size as our destination rectangles. But we shift it in X and Y
% by a value of dim2 - dim. This makes sure our window is centered on the
% middle of the enlarged texture we made for internal texture rotation.
srcRect = baseRectDst + (dim2 - dim);

% Start Angle for all of the textures
angle = 0;

% Text settings
Screen('TextSize', window, textSize);
Screen('TextFont', window, font);

%-----------------------------------------------------------------------------
%                           Display stimuli
%-----------------------------------------------------------------------------

% Display informative text before the stimuli. The text will be centered at
% the screen.
DrawFormattedText(window, preInfoText, 'center', 'center', white);

% Flip the text to the screen
Screen('Flip', window);

% Wait while the text is showing before showing the stimuli. 
WaitSecs(preInfoDuration);

while ~KbCheck
    % Draw the first two textues using whole "external" texture rotation
    Screen('DrawTextures', window, spiralTexture, srcRect,...
        dstRects(:, 1:2), angle, [], [], colorMod(:, 1:2));

    % Draw the last two textues using "internal" texture rotation
    Screen('DrawTextures', window, spiralTexture, srcRect, dstRects(:, 3:end), angle,...
        [], [], colorMod(:, 3:end), [], kPsychUseTextureMatrixForRotation);

    % Text showing along with the stimuli. The text will be positioned at 
    % the low on the screen. 
    DrawFormattedText(window, stimuliText, 'center', 0.85*screenYpixels, white);

    % Flip to the screen
    Screen('Flip', window);

    % Increment the angle
    angle = angle + angleInc;
end
sca;

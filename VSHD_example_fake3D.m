%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% Copyright NordicNeuroLab AS 2021 %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% File:          VSHD_example_fake3D.m
%% Init Author:   ”Carl Fredrik Haakonsen” <cfhaakonsen@gmail.com>
%% Init Date:     2021-08-06
%% Project:       VSHD – PsychToolbox Usage Example
%% Description:   Fake 3D example script for psychtoolbox using VSHD
%%
%% To run this script you must set the screenid to the ID corresponding to
%% VSHD. The hardware and software must also be correctly set up. This demo is
%% compatible with setup 2S Combined, see the article "Display Setup for Visual
%% Stimuli using VSHD". 
%%
%% The script  will show four different shapes which appear to lie at
%% different depths. The depth efffect is achieved by shifting the shapes for
%% each eye. The different shapes are shifted with different values, making
%% them appear as if they are at differnt depths. The demo is based on several
%% example demos from
%% http://peterscarfe.com/ptbtutorials.html
%%
%% To change which correction file is loaded, change calibFilename. If no 
%% geometry correction is wanted, simply comment out the two lines adding it.
%% In the "Setup parameter" section, the text can be changed. The amount of
%% pixels each of the objects are shifted can be set in the vector shifterPix.
%% Additional changes can be done in the section "Set up the stimuli".
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clear the workspace
sca; 
clearvars;
close all;

%-----------------------------------------------------------------------------
%                           Setup parameters
%-----------------------------------------------------------------------------

% This should be 4 with the VSHD. If combined displays (surround) is set up
% properly, the left eye image will be shown at the left eye at the VSHD, and 
% vice versa for the right eye.
stereoMode = 4;

% Set to the screen ID corresponding to the VSHD Goggles. 
screenid = 2;

% Filename of the geometry correction file
calibFilename = 'geoCalibVshd0diop.mat';

% Text to be displayed before the stimuli
preInfoText = 'Example of emulated 3D stimuli for VSHD. \n By drawing the images with an offset, \n a 3D effect is achieved.';

% The duation of the information in seconds
preInfoDuration = 3; 

% Text to be shown along with the stimuli
stimuliText = 'Press any key to exit';

% Text parameters
textSize = 40;
font = 'Courier';

% The shift in pixels between the rith and left eye images for the different figures.
% This will determine which depth they are percieved to be in. 
shifterPix = [0 , 130, 40, 70];

%-----------------------------------------------------------------------------
%                      Set up the screen
%-----------------------------------------------------------------------------

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Skip sync tests for this demo in case people are using a defective
% system. This is for demo purposes only.
Screen('Preference', 'SkipSyncTests', 2);

% Correct for distortion with the calibration file given by the parameter calibFilename
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'AllViews', 'GeometryCorrection', calibFilename);

% Open the main window
[window, windowRect] = PsychImaging('OpenWindow', screenid, 0,...
    [], 32, 2, stereoMode);

% Show cleared start screen:
Screen('Flip', window);

% Screen size pixels
[screenXpix, screenYpix] = Screen('WindowSize', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) edges to our dots
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%-----------------------------------------------------------------------------
%                      Set up the stimuli
%-----------------------------------------------------------------------------

%----------- Setting up the position of the different shapes------------------

% Screen position of the rectangles
squareXpos = [screenXpix*0.4 screenXpix*0.6];
squareYpos = screenYpix*0.42;

% Screen position of the cross
crossPos = [screenXpix*0.4, screenYpix*0.6];

% Screen position of the polygon
polyPos = [screenXpix*0.6, screenYpix*0.6];

% -------------------- Setting the color of the objects -----------------------

% Set the rectangle colors to red and green
rectColors = [1 0 0; 0 1 0]';

% Set the color of the polygon
polyColor = [0.8 0.1 0.5];

% Set the color of the fixation cross
fixColor = [1 1 1];


%--------------------- Setting up drawing of the rectangles -------------------
% Make a base Rect of 200 by 200 pixels
baseRect = [0 0 100 100];

% Make our rectangle coordinates for both eyes
allRectsL = [];
allRectsR = [];

% Adding the coordinates of the two rectangles to shared matrices, 
% one for each eye offset MAKE THESE LINES SHORTER SOMEHOW
allRectsL = [
CenterRectOnPointd(baseRect, squareXpos(1)+shifterPix(1), squareYpos)' CenterRectOnPointd(baseRect, squareXpos(2)+shifterPix(2), squareYpos)'
];

allRectsR = [
CenterRectOnPointd(baseRect, squareXpos(1)-shifterPix(1), squareYpos)' CenterRectOnPointd(baseRect, squareXpos(2)-shifterPix(2), squareYpos)'
];

% ------------------- Setting up drawing of a cross ---------------------------
% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 40;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;

% ------------------- Setting up drawing of a polygon -------------------------
% Number of sides for our polygon
numSides = 5;

% Angles at which our polygon vertices endpoints will be. We start at zero
% and then equally space vertex endpoints around the edge of a circle. The
% polygon is then defined by sequentially joining these end points.
anglesDeg = linspace(0, 360, numSides + 1);
anglesRad = anglesDeg * (pi / 180);
radius = 50;

% X and Y coordinates of the points defining out polygon, centred on the
% centre of the screen
yPosVector = sin(anglesRad) .* radius + polyPos(2);
xPosVector = cos(anglesRad) .* radius + polyPos(1);

% Cue to tell PTB that the polygon is convex (concave polygons require much
% more processing)
isConvex = 1;

%----------------------------------- ------------------------------------------
%                      Display the stimuli
%------------------------------------------------------------------------------

% Draing the displayed information before the stimuli is shown
for eye = 0:1
  Screen('SelectStereoDrawBuffer', window, eye );
  DrawFormattedText(window, preInfoText, 'center', 'center', [1 1 1]);
end

Screen('Flip', window);
WaitSecs(preInfoDuration);

% Drawing the stimuli. The for loop runs two times, one for each eye. 
for eye = 0:1
  Screen('SelectStereoDrawBuffer', window, eye);
  
  % Setting the positions for each eye
  if eye # Right eye
    allRects = allRectsR;
    shiftSign = -1;
  else # Left eye
    allRects = allRectsL;
    shiftSign = 1;
  end
  
  % Drawing rectangles
  Screen('FillRect', window, rectColors, allRects); 
    
  % Drawing the fixation cross
  Screen('DrawLines', window, allCoords,...
  lineWidthPix, fixColor, [(crossPos(1) + shiftSign * shifterPix(3)) crossPos(2)], 2);
    
  % Drawing the polygon
  Screen('FillPoly', window, polyColor, [(xPosVector + shiftSign * shifterPix(4)); yPosVector]', isConvex);
  
  % Draw text
  DrawFormattedText(window, stimuliText, 'center', 0.7*screenYpix, [1 1 1 ]);
  
end



% Flip to the screen
Screen('Flip', window);

% Wait for a key press
KbStrokeWait;

% Clear the screen
sca;

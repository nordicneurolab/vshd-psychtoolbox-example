%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% Copyright NordicNeuroLab AS 2021 %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% File:          VSHD_example3D.m
%% Init Author:   ”Carl Fredrik Haakonsen” <cfhaakonsen@gmail.com>
%% Init Date:     2021-08-06
%% Project:       VSHD – PsychToolbox Usage Example
%% Description:   3D example script for psychtoolbox using VSHD
%%
%% To run this script you must first set screenid to the ID corresponding
%% to VSHD. The hardware and software must be set up correctly as well.
%% For details on how to do this, see the article "Display Setup for Visual 
%% Stimuli using VSHD". This script is compatible with setup 2S Combined. 
%%
%% The script will show different 3D objects floating in space. The 3D stimuli
%% is achieved by rendering different images for the eyes. This is done by 
%% using two different camera positions for the eyes. The cameras are shifting 
%% side to side to illustrate the 3D effect. 
%% The script is based on the "Rotating Cubes Demo" from 
%% http://peterscarfe.com/rotatingcubesdemo.html
%%
%% To change which correction file is loaded, change calibFilename. If no 
%% geometry correction is wanted, simply comment out the two lines adding it.
%% The Inter Pupil Distance (IPD) can be changed through the variable IPD.
%% This should be set to the actual IPD of the viewer. The displayed text can 
%% easily be changed in the "Setup parameters" section, as well as the distance
%% to the cubes. 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clear the workspace
close all;
clearvars;
sca;

%--------------------------------------------------------------------------
%                           Setup parameters
%--------------------------------------------------------------------------

% This should be 4 with the VSHD. If combined displays (surround) is set up
% properly, the left eye image will be shown at the left eye at the VSHD, and 
% vice versa for the right eye.
stereoMode = 4;

% Set the screenNumber to the ID of the VSHD display.
% Dependant on the monitor setup.
screenid = 1;

% Name of the calibration file
calibFilename = 'Calibdata3.mat';

% Set the inter pupil distance of the subject. This variable will be used as the camera offset
% in the 3D rendering.
IPD = 6.3;

# Set the field of view (FOV) in y direction for the VSHD Goggles 
FOV_y = 30;

% Choose to display text along with the animations. 1 or 0.
displayStimuliText = 1;

% Displayed text with animation
stimuliText = 'Press any key to exit';

% The height of the text on the screen. 0 is the top of the screen, and 1 is at the bottom.
textPositionY = 0.85;

% Text to be displayed before the stimuli
preInfoText = 'Example of 3D stimuli for VSHD';

% The duation of the information in seconds
preInfoDuration = 1; 

% Set the distance to the cubes
dist = 13; 


%--------------------------------------------------------------------------
%                      Set up the screen
%--------------------------------------------------------------------------

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Skip sync tests for this demo in case people are using a defective
% system. This is for demo purposes only.
Screen('Preference', 'SkipSyncTests', 2);

% Initialise OpenGL 
InitializeMatlabOpenGL;

% Correct for distortion with calibration file. Comment this out if no correction is wanted.
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'AllViews', 'GeometryCorrection', calibFilename);

% Open the main window with multi-sampling for anti-aliasing
[window, windowRect] = PsychImaging('OpenWindow', screenid, 0, [],...
    32, 2, stereoMode, 6,  []);

% Query the frame du ration
ifi = Screen('GetFlipInterval', window);

% Screen size pixels
[screenXpix, screenYpix] = Screen('WindowSize', window);

% Finding the aspect ratio of the screen
ar = windowRect(3) / windowRect(4);

% Setting text parameters
Screen('TextSize', window, 40);
Screen('TextFont', window, 'Courier');

%--------------------------------------------------------------------------
%                      Set up the displayed animation
%--------------------------------------------------------------------------


% Start the OpenGL context (you have to do this before you issue OpenGL
% commands such as we are using here)
Screen('BeginOpenGL', window);

% Enable lighting
glEnable(GL.LIGHTING);

% Define a local light source
glEnable(GL.LIGHT0);

% Enable proper occlusion handling via depth tests
glEnable(GL.DEPTH_TEST);

% Lets set up a projection matrix, the projection matrix defines how images
% in our 3D simulated scene are projected to the images on our 2D monitor
glMatrixMode(GL.PROJECTION);
glLoadIdentity;

% Set up our perspective projection. This is defined by our field of view
% (here given by the variable "FOV_y") and the aspect ratio of our frustum
% (our screen) and two clipping planes. These define the minimum and
% maximum distances allowable here 0.1cm and 200cm.
gluPerspective(FOV_y, ar, 0.1, 200);

% Setup modelview matrix: This defines the position, orientation and
% looking direction of the virtual camera that will be look at our scene.
glMatrixMode(GL.MODELVIEW);
glLoadIdentity;

% Our point lightsource is at position (x,y,z) == (1,2,3)
glLightfv(GL.LIGHT0, GL.POSITION, [1 2 3 0]);

% Set background color to 'black' (the 'clear' color)
glClearColor(0, 0, 0, 0);

% Clear out the backbuffer
glClear;

% Change the light reflection properties of the material to blue. We could
% force a color to the cubes or do this.
glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT, [0.0 0.0 1 1]);
glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [0.0 0.0 1 1]);

% End the OpenGL context now that we have finished setting things up
Screen('EndOpenGL', window);

% Setup the positions of the squares using the meshgrid command.
% The number of cubes and their position can be changed here. 
[cubeX, cubeY] = meshgrid(linspace(-2.5, 0, 2), linspace(-1, 1.5, 2));
[s1, s2] = size(cubeX);
cubeX = reshape(cubeX, 1, s1 * s2);
cubeY = reshape(cubeY, 1, s1 * s2);

% Define the intial rotation angles of our cubes
rotaX = rand(1, length(cubeX)) .* 360;
rotaY = rand(1, length(cubeX)) .* 360;
rotaZ = rand(1, length(cubeX)) .* 360;

% Now we define how many degrees our cubes will rotated per second and per
% frame. Note we use Degrees here (not Radians)
degPerSec = 30;
degPerFrame = degPerSec * ifi;



%--------------------------------------------------------------------------
%                        Display the stimuli
%--------------------------------------------------------------------------

% Displaying the informative text before the stimuli
for eye = 0:1
  Screen('SelectStereoDrawBuffer', window, eye );
  DrawFormattedText(window, preInfoText, 'center', 'center', [1 1 1 ]);
end

Screen('Flip', window);
WaitSecs(preInfoDuration);

% Get a time stamp with a flip
vbl = Screen('Flip', window);

% Set the frames to wait to one
waitframes = 1;

% Displaying the animated stimuli
while ~KbCheck
    % Rendering images separately for each eye
    for eye = 0:1
      % Select eye image buffer for drawing
      Screen('SelectStereoDrawBuffer', window, eye);
      
      % Begin the OpenGL context now we want to issue OpenGL commands again
      Screen('BeginOpenGL', window);
      
      % Set distance (offset) between eye cameras
      if eye
        eyeOffset = IPD / 2;
      else
        eyeOffset = -IPD / 2;
      end
      
      % Location of the camera is at the origin
      cam = [eyeOffset 0 0];

      % Set our camera to be looking directly down the Z axis (depth) of our
      % coordinate system
      fix = [eyeOffset 0 -100];

      % Define "up"
      up = [0 1 0];

      % Here we set up the attributes of our camera using the variables we have
      % defined in the last three lines of code
      gluLookAt(cam(1), cam(2), cam(3), fix(1), fix(2), fix(3), up(1), up(2), up(3));

      % To start with we clear everything
      glClear;

      % Draw all the cubes
      for i = 1:1:length(cubeX)
          
          % Push the matrix stack
          glPushMatrix;

          % Translate the cube in xyz. Added periodic shifting along z-axis.
          if mod(i, 2)
            glTranslatef(cubeX(i), cubeY(i), -dist + 3*sin(rotaX/21));
          else
            glTranslatef(cubeX(i), cubeY(i), -dist + 3*sin(rotaX/20));
          end

          
          % Rotate the cube randomly in xyz
          glRotatef(rotaX(i), 1, 0, 0);
          glRotatef(rotaY(i), 0, 1, 0);
          glRotatef(rotaZ(i), 0, 0, 1);

          % Draw the solid cube
          glutSolidCube(1);

          % Pop the matrix stack for the next cube
          glPopMatrix;

      end

      % End the OpenGL context now that we have finished doing OpenGL stuff.
      % This hands back control to PTB
      Screen('EndOpenGL', window);
      
      % Display the stimuli text if displayStimuliText = 1
      if displayStimuliText
        DrawFormattedText(window, stimuliText, 'center', textPositionY*screenYpix, [1 1 1 ]);
      end  
    end
    
      
    
    % Show rendered image at next vertical retrace
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

    % Rotate the cubes for the next drawing loop
    rotaX = rotaX + degPerFrame;
    rotaY = rotaY + degPerFrame;
    rotaZ = rotaZ + degPerFrame;

end


% Take screenshot
##imageArray = Screen('GetImage', window);
##imwrite(imageArray, 'correction3.png');

% Shut the screen down
sca;

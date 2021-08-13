%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% Copyright NordicNeuroLab AS 2021 %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% File:          VSHD_example3D_2.m
%% Init Author:   ”Carl Fredrik Haakonsen” <cfhaakonsen@gmail.com>
%% Init Date:     2021-08-06
%% Project:       VSHD – PsychToolbox Usage Example
%% Description:   3D example script for psychtoolbox using VSHD
%%
%% To run this script you must first set screenid to the ID corresponding
%% to VSHD. The hardware and software must be set up correctly as well.
%% For details on how to do this, see the article "Display Setup for Visual 
%% Stimuli using VSHD". This script is compatible with setup 2S Combined. 
%% VSHD should be set as the main display.
%%
%% The script will show different 3D objects floating in space. The 3D stimuli
%% is achieved by rendering different images for the eyes. This is done by 
%% using two different camera positions for the eyes. The cameras are shifting 
%% side to side to illustrate the 3D effect. 
%% The script is based on several of the beginner tutorials from 
%% http://peterscarfe.com/ptbtutorials.html
%%
%% To change which correction file is loaded, change calibFilename. If no 
%% geometry correction is wanted, simply comment out the two lines adding it.
%% The Inter Pupil Distance (IPD) can be changed through the variable IPD.
%% This should be set to the actual IPD of the viewer. The displayed text can 
%% easily be changed in the "Setup parameters" section, as well as parameters
%% for the camera movement. The distance to the objects can also be changed
%% in this section. Object sizes and shapes can also be changed further down
%% in the script. 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clear the workspace
close all;
clearvars;
sca;

%-----------------------------------------------------------------------------
%                           Setup parameters
%-----------------------------------------------------------------------------

% This should be 4 with the VSHD. If combined displays (surround) is set up
% properly, the left eye image will be shown at the left eye at the VSHD, and 
% vice versa for the right eye.
stereoMode = 4;

% Set the screenNumber to the ID of the VSHD display.
% Dependant on the monitor setup, usually 1 or 2. max(Screen('Screens') will 
% most likely be the ID of the external monitor, which is likely VSHD.
screenid = 2;

% Filename of the geometry correction file
calibFilename = 'geoCalibVshd0diop.mat';

% Set the distance between the eyes (cameras). 
IPD = 6.3; % 6.3 cm

# Set the field of view (FOV) in y direction for the VSHD Goggles 
FOV_y = 30;

% Choose to display text along with the animations. 1 or 0.
displayStimuliText = 1;

% Displayed tezt with animation
stimuliText = 'Press any key to exit';

% The height of the text. 0 is the top of the screen, and 1 is at the bottom.
textPositionY = 0.95 ;

% Text to be displayed before the stimuli
preInfoText = 'Example of 3D stimuli for VSHD';

% The duation of the information in seconds
preInfoDuration = 1; 

% Distances to the objects
dist = -[15 25]; 

% Incremental value for camera movement
cameraInc = 0.01;
cameraCount = 0;

% Displasement amplitude of the camera
cameraDistp = 0.015 ;

%-----------------------------------------------------------------------------
%                      Set up the screen
%-----------------------------------------------------------------------------

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Skip sync tests for this demo in case people are using a defective
% system. This is for demo purposes only.
Screen('Preference', 'SkipSyncTests', 2);

% Initialise OpenGL 
InitializeMatlabOpenGL;

% Correct for distortion with calibration file
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'AllViews', 'GeometryCorrection', calibFilename);

% Open the main window with multi-sampling for anti-aliasing
[window, windowRect] = PsychImaging('OpenWindow', screenid, 0, [],...
    32, 2, stereoMode, 6,  []);

% Query the frame du ration
ifi = Screen('GetFlipInterval', window);

% Screen size pixels
[screenXpix, screenYpix] = Screen('WindowSize', window);

% For this demo we will assume our screen is 30cm in height. The units are
% essentially arbitary with OpenGL as it is all about ratios. But it is
% nice to define things in normal scale numbers
ar = windowRect(3) / windowRect(4);
screenHeight = 30;
screenWidth = screenHeight * ar;

% Setting text parameters
Screen('TextSize', window, 40);
Screen('TextFont', window, 'Courier');

%-----------------------------------------------------------------------------
%                      Set up the displayed animation
%-----------------------------------------------------------------------------

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

% End the OpenGL context now that we have finished setting things up
Screen('EndOpenGL', window);

% Setup the positions of the spheres using the mexhgrid command
[posX, posY, posZ] = meshgrid(linspace(-2, 2, 2), linspace(-2, 2, 2), dist);
[s1, s2, s3] = size(posX);
posX = reshape(posX, 1, s1 * s2 * s3);
posY = reshape(posY, 1, s1 * s2 * s3);
posZ = reshape(posZ, 1, s1 * s2 * s3);

% Define the intial rotation angles of our objects
rotaX = rand(1, length(posX)) .* 360;
rotaY = rand(1, length(posX)) .* 360;
rotaZ = rand(1, length(posX)) .* 360;

% Now we define how many degrees our objects will rotated per second and per
% frame. Note we use Degrees here (not Radians)
degPerSec = 15;
degPerFrame = degPerSec * ifi;

% Matrix for object colors. If only one color is in the matrix, all objects 
% will have this color. If there are two, every second object will have the
% same color and so on. 
objectColors = [
[0.6 0.6 0.6];
[1 1 1];
[1 0.5 0];
[1 0 0];
[1 0.4 1];
[0 1 1];
[0 0 1];
[0 1 0]
];

% Cell containing the different object functions, sizes and colors.
% If this cell has less elements then there are objects, some objects will 
% be the same. They may however have a different color. Which objects are drawn
% can be changed here. See 
% https://www.opengl.org/resources/libraries/glut/spec3/node80.html
objects(1, 1) = {'glutSolidCube'}; objects(1, 2) = 2;
objects(2, 1) = {'glutSolidTeapot'}; objects(2, 2) = 1;
objects(3, 1) = {'glutSolidCone'}; objects(3, 2) = [1, 2, 50, 50];
objects(4, 1) = {'glutSolidTetrahedron'}; 
objects(5, 1) = {'glutWireSphere'}; objects(5, 2) = [1, 20, 20];
objects(6, 1) = {'glutSolidIcosahedron'}; 
objects(7, 1) = {'glutSolidSphere'}; objects(7, 2) = [1, 50, 50];

%--------------------------------------------------------------------------
%                        Display the stimuli
%--------------------------------------------------------------------------

% Displaying the informative text before the stimuli. Drawn in white ([1 1 1])
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
      
      % Set the "head" x position (middle of the two cameras). This is what makes
      % it appear as if the objects are sliding back and forth to the sides.
      camPosX = cameraDistp * sin(cameraCount);
      cameraCount = cameraCount + cameraInc;
      
      % Set x coordinate for the camera location
      if eye
        eyeOffset = camPosX + IPD / 2;
      else
        eyeOffset = camPosX - IPD / 2;
      end
      
      % Location of the camera
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

      % Draw all the objects
      for i = 1:length(posX)
          
          % Push the matrix stack
          glPushMatrix;
          
          % Set color of light source induvidually for each object to yield different colors
          % This is done by changing the light reflection properties of the material. We could
          % force a color to the objects or do this.
          color = objectColors( rem(i, size(objectColors, 1)) + 1, :);
          glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT, [color 1]);
          glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, color);
          
          % Translate the object in xyz.
          glTranslatef(posX(i), posY(i), posZ(i));
          
          % Rotate the object randomly in xyz
          glRotatef(rotaX(i), 1, 0, 0);
          glRotatef(rotaY(i), 0, 1, 0);
          glRotatef(rotaZ(i), 0, 0, 1);

          % Draw the object
          objectIndex = rem(i, size(objects, 1)) + 1;
          
          % Checking the number of inputs of the object function
          numInputs = size(objects{objectIndex, 2}, 2);
          
          % Drawing the objects from the objects cell. 
          if numInputs == 0
            feval(objects{objectIndex, 1});
          elseif numInputs == 1
            feval(objects{objectIndex, 1}, objects{objectIndex, 2}); 
          elseif numInputs == 3
            feval(objects{objectIndex, 1}, objects{objectIndex, 2}(1), objects{objectIndex, 2}(2), 
            objects{objectIndex, 2}(3)); 
          elseif numInputs == 4
            feval(objects{objectIndex, 1}, objects{objectIndex, 2}(1), objects{objectIndex, 2}(2), 
            objects{objectIndex, 2}(3), objects{objectIndex, 2}(4));
          end

          % Pop the matrix stack for the next object
          glPopMatrix;
      end

      % End the OpenGL context now that we have finished doing OpenGL stuff.
      % This hands back control to PTB
      Screen('EndOpenGL', window);
      
      % Drawin the text to the screen in white ([1 1 1])
      if displayStimuliText
        DrawFormattedText(window, stimuliText, 'center', textPositionY*screenYpix, [1 1 1 ]);
      end  
    end
    
    % Show rendered image at next vertical retrace
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

    % Rotate the objects for the next drawing loop
    rotaX = rotaX + degPerFrame;
    rotaY = rotaY + degPerFrame;
    rotaZ = rotaZ + degPerFrame;

end


% Shut the screen down
sca;

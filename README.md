# Usage examples for Psychtoolbox using VSHD

This repository contains four example scripts showing how to use Psychtoolbox to display stimuli on VisualSystemHD from NordicNeuroLab. The code corresponds to the examples in the article "Using Psychtoolbox with VSHD". 

![image](https://user-images.githubusercontent.com/47245270/128488394-7ce05341-93bc-44ef-8a47-7814824cf2f3.png)

The scripts are largely based on demo scripts from http://peterscarfe.com/ptbtutorials.html.  

## Prerequisites

To run the scripts on VSHD, the following must be done:

* Install GNU Octave / Matlab
* Install Psychtoolbox
* Set up VSHD display, see the article "Display Setup for Visual Stimuli using VSHD". See indivual script headers for further details on which setups can be used. 
* Change the display ID in the scripts to the one corresponding to VSHD

## Display Distortion Correction

The file "geoCalibVshd0diop.mat" contains geometry correction data for VSHD, which is loaded in the scripts to add pre-distortion. The file is made by using Psychtoolbox' function "DisplayUndistortionBVL". It is made for diopter setting 0 on the VSHD Goggles. New correction files can be made using "DisplayUndistortionBVL". Simply change the variable "calibFilename" to load another correction file. 

## 2D Example

"VSHD_example2D.m" shows rotating squares and textures. For use with VSHD, geometry correction and text has been added to the script. 

## Fake 3D Example

"VSHD_example_fake3D.m" shows four different objects appearing as if they are at different depths. The 3D effect is achieved by shifting the objects for each eye. By shifting with different amount of pixels it looks as if they are at different depths. 

## Real 3D Example 1

"VSHD_example3D.m" shows rotating cubes moving back and towards the camera, aiming to illustrate the 3D possibilities with Psychtoolbox and VSHD. For this VSHD example the animation has been changed. Informative text has also been added along with distortion correction. The script was originally not 3D. The 3D is achieved by rendering images from two different cameras, one for each eye. 

## Real 3D Example 2

"VSHD_example3D_2.m" shows different 3D objects floating and rotating in space. The objects lie at different positions and depths. The camera position moves side to side to enhance the 3D effect. The 3D graphics are rendered as in "Real 3D Example 1". 

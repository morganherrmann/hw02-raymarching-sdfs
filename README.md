# CIS 566 : Implicit Surfaces

#### Morgan Herrmann
moher@seas.upenn.edu
www.morganherrmann.com
DEMO - https://morganherrmann.github.io/raymarching/


## Overview
Objective: To use Raycasting and Raymarching to create an animated, interactive scene.

### Ray Casting
Given the position of the up vector and screen dimensions, I first computed the direction the rays would be cast.
The field of view has been set to 45 degrees.  Sources are linked below.
[Slides on Raycasting](https://docs.google.com/presentation/d/e/2PACX-1vSN5ntJISgdOXOSNyoHimSVKblnPnL-Nywd6aRPI-XPucX9CeqzIEGTjFTwvmjYUgCglTqgvyP1CpxZ/pub?start=false&loop=false&delayms=60000#slide=id.g27215b64c6_0_107)
[Jamie Wong SDFs](http://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions/)

### Use of Shape Operations
 * Intersection - The outer border is an intersection of a tall cylinder and a rotating cube.
 * Subtraction - A small sphere was subtracted from the interior of the cube/cylinder to create a hollow area in the center.
 * Smooth Blend - The center object is a torus smooth unioned with a small sphere, to create a flattened disc shape.
### Bounding Volumes
 * To bound the volumes, I first forced any ray to stop and return if their x or y coordinate passed the range of the shape equations.
 * I also computed the distance at which the shapes began and ended in the z space, using only enough steps along the ray to cover this z space.
 * There are two bounding boxes arranged- One is for the larger cube and cylinder intersected, the other for the torus/2 spheres in the center.
 
 
### Animated Attributes
  - The color is animated with respect to time.
  - The rotation of the center object and the outer square is also animated with respect to time.
  
### ToolBox Functions Used
  - Used TRIANGLE WAVE to modify the colors over time.
  - Used SQUARE WAVE to modify one color attribute over time.
  - Used SIN/COS to create the spinning effect of the objects.
  - [Toolbox Functions](https://cis700-procedural-graphics.github.io/files/toolbox_functions.pdf)

### Procedural Texturing
  - Procedural texturing was done using SIN/COS displacement toolbox functions to create a wavy, noisy, bubbly effect.
  - [SDFs and Displacement Functions](http://iquilezles.org/www/articles/distfunctions/distfunctions.htm)
   - [Toolbox Functions](https://cis700-procedural-graphics.github.io/files/toolbox_functions.pdf)
  
  
### Shading that involves surface normal computation
![](https://drive.google.com/uc?export=view&id=1ZXaK66AIJuG1K5hcHg1yGriheFx_t-S5)
![](https://drive.google.com/uc?export=view&id=1eFFYgROL7xyk_j_dgPiG5fqsDPxnxyWB)
  - To estimate the normals, I initially used the formula linked in the slides, used to estimate the gradient at the current point, and used the normals to map colors.
  - [Normal Estimation](http://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions/)

### Modifiable GUI Features
![](giphy2.gif)
 - COLOR/STYLE - A slider allows the user to manipulate the style from electric bluish to a cartoon pink.
 - ROTATION SPEED - The user can also control how quickly the central torus spins and makes waves in the scene.






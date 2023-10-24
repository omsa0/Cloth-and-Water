# Cloth and Water Simulations
![Image of the cloth Simulation](clothsim.png)
![Image of the water Simulation](watersim.png)

A Rod-based cloth and SPH fluid simulations, created for CSCI 5611 by Omar Salem

## Demo
[Cloth - YouTube Demo](https://youtu.be/hDOxoVIeFUQ)
[Water - YouTube Demo](https://youtu.be/glHPKJ2ocBM)

### Features & Timestamps
#### Part 1 - Cloth:
1. 00:08 - Multiple Ropes

    The simulation must support multiple ropes which are hanging from the top and can swing naturally, as well as interacting with an obstacle. Obstacle interaction can be seen more in the "User Interaction" section below. While the simulation may not look like multiple ropes, a cloth is multiple ropes with extra horizontal constraints so it fulfills this requirement.

2. 00:08/00:50/01:16 - Cloth Simulation
    
    A cloth is multiple independent ropes that are tied together with horizontal constraints, and it can interact with obstacle just like the "Multiple Ropes" section states. This is explained in 00:08 and the swinging and behavior of the rope is also shown and explained again at 00:50. 01:16, as well as the "User Interaction" section demonstrates how the cloth can bend and interact with a spherical obstacle.

3. 00:54/00:30 - 3D Simulation
    
    The cloth is represented by a 2D mesh able to swing in a 3D space. There are multiple lights shining on the cloth to make it look more realistic as it bends and folds, and 00:30 demonstrates how we can use the camera controls to looks at different angles of the cloth.
    
4. 00:57 - High Quality Rendering
    
    This demonstrates how the rendering, 3D lighting, and the texture help make the cloth look more realistic and produce a better quality image and simulation.

5. 01:24 - User Interaction
    
    The obstacle in the simulation can be controlled by the user to interact with the cloth and push it around to better understand it's behavior.

#### Part 2 - Water:
No specific timestamps, as the [video](https://youtu.be/glHPKJ2ocBM) covers all of it. The chosen challenge simulation was an SPH fluid simulation. The fluid is comprised of multiple particles that represent water. They interact with their environment with gravity and obstacle/wall bouncing. The particles interact with each other using near forces that push particles away from each other so that they don't overlap, and pressure forces that cause the particles to look like they are behaving and moving like the other particles around them, effectively making the movement of the particles together look like a fluid. The fluid can be interacted with using the mouse to drag it around and explore the results of the forces on the particles in different scenarios.

## Difficulties Encountered
1. Springiness/Bounciness of Cloth
    
    Before ultimately deciding that I wanted to make the cloth a flag (meaning that realistically it's not that bouncy) I tried implementing the flag as a spring based cloth instead of a rod based one, despite my rod based one working fine. I encountered the trouble of it being far too stretchy, and worse, fixing it forced me to use very high substeps/relaxation steps which made the simulation impossible to run. While the spring based implementation was ditched in the end, I was still able to make use of the bounciness that comes from having low substeps in the rod-based approach and still get a good result and good look for the flag without making it too rigid. Overall, the cloth simulation went by very smoothly.

2. SPH Fluid

   The SPH fluid was a nightmare. Much of what I tried did not work and I had to spend a lot more time than I had expected on it. While there were problems with the code I wrote, and small bugs that unfortunately broke the whole system, and took a lot of time to find, it was also difficult to get the right tuning for the system, even when the physics were generally well. For example I had a lot of jittery-ness in the simulation for a long time. Even now, if the fluid settles, the bottom of the fluid still has some jittery components, even though it is so small (and most of it was eliminated). Additionally, due to struggling to even make it work, I wasn't able to implement any extra major things for the fluid, like other objects to play with, or a background, like I had hoped. Another major problem, like the previous assignment, was Processing's debugger. I am not sure if it's just me, but the debugger has not functioned once and I cannot get it to work, even with a fresh install. It wasn't a big issue for cloth, but it really slowed me down when trying to make the fluid.

## Libraries Used
No external libraries outside of the provided Processing libraries were used.

## Attribution

### Code
Code can be found on the [github page](https://github.com/omsa0/Cloth-and-Water/)

All code used was either written by me or provided in class

### Images
For the cloth flag texture - [VectorFlags.com](https://vectorflags.com/palestine/ps-square-01)

# Atomic Clusters explorer [Processing]

*This project was released under the MIT License*

* Instagram: [https://instagram.com/ciphrd](https://instagram.com/ciphrd)
* Blog: [https://ciphered.xyz](https://ciphered.xyz)
* Atomic Clusters article: [https://ciphered.xyz/2020/06/01/atomic-clusters,-a-molecular-particle-based-simulation/](https://ciphered.xyz/2020/06/01/atomic-clusters,-a-molecular-particle-based-simulation/)

Atomic Clusters is a particle-based simulation inspired by the work **Clusters** from *Jeffrey Ventrella*. I wrote [an article](https://ciphered.xyz/2020/06/01/atomic-clusters,-a-molecular-particle-based-simulation/) to describe both the system and its implementation on my blog. Feel free to check it out if you want an insight on this system.

![Atomic Clusters explorer demo](demo/tool-overview.gif)

This simulation is an attraction-repulsion system, where particles can have [0; 4] attractors. Attractors of the same color are attracted, and repelled by attractors of some different colors. These forces generates torque on the particles, creating the angular rotation we can observe.

This tool was made to explore Atomic Clusters with more precision than just throwing random particles all arround. It is still under development and the code is not 100% clean. Like the UI architecture is garbage, but it was enough for this first version. There is also a lot of room for optimisation, especially when it comes to the particles interactions. This is my first project using Processing so if you want to improve this tool feel free to contribute. I made a quick video to explain how the tool works:

[![Link to the presentation of the tool](https://img.youtube.com/vi/2viKdYow9LM/0.jpg)](https://www.youtube.com/watch?v=2viKdYow9LM)

## How to run

* [Download Processing](https://processing.org/download/) and install it
* Clone this repo
* Open the `sketch_atomic_clusters_explorer.pde` file with Processing 
* Run

## How to use

* You can interact with the system by adding, deleting, rotating and moving particles
* Adjust the simulation settings on the bottom right
* **The list of controls can be seen by clicking on the keyboard icon of the bottom left toolbar**
* New atoms can be created and added to the toolbar using available subatomic charges (colors)
* The number of different subatomic charges can be modified by clicking on the top-right icon.

## Exploration of Atomic Clusters with more particles

I explored this system using compute shaders to have more particles, I posted some of my results on my instagram: [@ciphrd](https://instagram.com/ciphrd)

## Todo

* refacto of some components - **required** before next update
* optimization of particle-particle interactions
* add interaction tools (such as mouse repelling particles, random particle spawn, eraser?)
* selected particle should have more data displayed + a way to modify its settings
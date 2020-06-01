# Atomic Clusters explorer [Processing]

Atomic Clusters is a particle-based simulation inspired by the work **Clusters** from *Jeffrey Ventrella*. I wrote [an article](https://ciphered.xyz/2020/06/01/atomic-clusters,-a-molecular-particle-based-simulation/) to describe both the system and its implementation on my blog. Feel free to check it out if you want an insight on this system.

![Atomic Clusters explorer demo](demo/demo.gif)

This simulation is an attraction-repulsion system, where particles can have [0; 4] attractors. Attractors of the same color are attracted, and repelled by attractors of some different colors. These forces generates torque on the particles, creating the angular rotation we can observe.

This tool was made to explore Atomic Clusters with more precision than just throwing random particles all arround. It is still under development and the code is not 100% clean. Like the UI architecture is garbage, but it was enough for this first version. There are also a lot of room for optimisation, especially when it comes to the particles interractions. This is my first project using Processing so if you want to improve this tool feel free to contribute. I made a quick video to explain how the tool works:

I explored this system using compute shaders to have more particles, I posted some of my results on my instagram: [@ciphrd](https://instagram.com/ciphrd)

## Todo

* refacto of some components - if this project gets bigger this will be required ahah
* optimization
* add interraction tools (such as mouse repelling particles)
* selected particle should have more data displayed + a way to modify its settings
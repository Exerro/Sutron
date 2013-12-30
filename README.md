Sutron
======

A small game I am developing.

This is a minecraft style 2D game in it's very early stages.
The engine is designed to be very open and allow objects in the game (including 3rd party modifications) to have complete control over how they behave and react, while providing standard resources for objects that want a more uniform behaviour.

It uses blocks, entites, and updaters in the map to control everything.
Blocks are just static items that can collide with entities and be rendered.
Entities are moving objects with velocity.
Updaters are non solid objects that contain a function that is called every game loop.

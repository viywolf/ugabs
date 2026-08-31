# Unnamed Grid Algorithm Battle Simulator

A customisable simulation of algorithms colouring a grid. Try it out at [itch.io](https://viywolf.itch.io/ugabs)!

## What is it?

UGABS is a simulation of various algorithms on a 2d grid, following the following rules:

-Each lil guy can only move on an empty cell or a cell of their colour.

-When one of them travels over an uncoloured cell, that cell is coloured in their colour.

-When a cell thing creates an enclosed space without any other creatures inside it, this space automatically gets filled in (to save time, as no other traveller can go inside of that area)

-The blocky beings move according to their algorithm

![](https://github.com/viywolf/ugabs/blob/main/misc/RealDemoUGABS.gif)

## Features

UGABS currently features four (plus two) different algorithms. More are planned to be added.

Currently availiable algorithms:
	'Random' chooses a random direction to travel in every turn. This includes directions which it cannot move to, causing it to skip a turn.
	'Random Router' chooses a random uncoloured cell on the grid, which it will then attempt to travel to in the shortest route possible.
	'Closest' tries to find the closest uncoloured cell and moves towards it.
	'Spiral' moves in an anti-clockwise direction in a spiral like shape.
Plus a few bonus non-algorithms:
	'User' is controlled by you. Use arrow keys to control its movement. If no input is detected in time, its turn is skipped.
	'Stationary' will never move. Not to be confused with 'stationery'.

You may customise the colours for each one of the algorithm grid people, as well as choose where they start on the grid.

The grid itself can also be customised, with the ability to choose a square/circle based shape, and the radius/size of it.

![](https://github.com/viywolf/ugabs/blob/main/misc/CustomisationDemoUGABS.gif)

After all cells in the grid are taken, the simulation will stop. You will then have the option to replay it.

## Inspiration

I made this based on all of the grid algorithm battle videos I've seen on the internet, wanting to make one that was highly customisable. New algorithms can be added relatively easily, allowing simple exapansion of this game!

## Other Info

The primary tool I used to make this was Godot with GDScript. Special mention to Aseprite, BeepBox, and itch.io. No AI was used in this project.

This project was made for Horizons by Hack Club.

## License

This project uses the MIT license which is [here](godotengine.org/license).

# Life of a Cheetah

*A sort of chill game about parenthood, made for the Hive Game Jam 2025.*

You are a mama cheetah caring for her cubs, who normally roam happily around you. Once in a while, a cub will get lost, and you have to find it and get it back. If all your ten cubs are lost, you lose the game. Your score is how long you managed to last.

## Controls

- WASD / left stick: movement
- mouse / right stick: looking around
- space / south gamepad button: stand up above the tall grass
- F: switch to fullscreen
- escape: quit

## Compiling from source

- On Linux, make sure you have a C compiler installed (for instance `sudo apt install build-essential` on Ubuntu)
- Install DUB and the LDC2 compiler (for instance: `brew install dub ldc` or `sudo apt install dub ldc2`, or by hand on Windows)
- Run `dub build -b release`
- Run `dub run raylib-d:install` to fetch the raylib dynamic library (on some Linux distributions this fails, so you might have to download the compiled lib from the [raylib website](https://github.com/raysan5/raylib/releases/tag/5.5))

## Licenses

- Music by BaDoink, released under Creative Commons 0: https://freesound.org/people/BaDoink/sounds/536200/
- Art by Selma Falzon, [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/)
- Source code by Noé Falzon, [MIT license](license.md)

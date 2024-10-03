# GameBoy tests
I have written these tests (just one as of now) for my [own gameboy emulator](https://github.com/velllu/gameman), this repo has a script to build them, or you can get them from the release tab on the right

> [!CAUTION] 
> I have written these to be used on an emulator, altough these should also work on hardware, I will not be responsible for the damage it might cause

# Tests
- `sprite-scroll-x`, this one puts a sprite in the middle of the screen, and after every vblank interrupt, moves the sprite by one pixel.

# Building
To build a test run `./build.sh testname`, for example, `./build.sh sprite-scroll-x`. To clean generated files except the rom, run `./build.sh clean`.  
If you are running Nix you can do `nix develop .` to get the dev environment installed, otherwise you'll have to manually download the rgbds tools
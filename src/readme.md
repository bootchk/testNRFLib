
testNRFLib

A test harness for a library for Nordic SoC chips.

Mainly an exercise in dividing a monlithic build system 
into a build system that builds libraries and links them together.

Also an exercise in using CMake
instead of make files provided by Nordic
or Eclipse managed make (copying things from makefiles to the GUI.)

Easily modified to test any library that you create and specify in the CMakeLists.txt?

Source in this project:

    sdk_config (since it specifies what you are building)
    .ld loader script (since you can/should modify it to use optimum RAM?)
    main.cpp
    
Other sources come from the nRFSDK.

Project (the IDE artifact)
-

Project created using Cmake generator "Eclipse CDT4 - Ninja"
per instructions here https://cmake.org/Wiki/Eclipse_CDT4_Generator

Project has build targets.

Project is not in the source tree (sibling to build tree).
Project has links to the source tree.
But project is not integrated with Git (use command line for that.)
IOW, there is no separate "source" project as recommended by the CMake folks.

Dependencies
-
    
     uses cmake scripts from nRF5Cmake repository
    
# Fantasy Crystals

This Pack Contains two big features:

- a bunch of shaders ( that can work on any mesh! )
- a way to generate crystals

All of the magic of the shaders can be found in the Shaders folder / the materials to use in the materials folder, and the magic for making the crystals all in the scripts. Check out that if you want to dig into the math behind the crystal generation. I've tried to comment both shaders and generation code in a reasonable fashion, but feel free to hit me up on twitter @cabbibo for any questions.

These meshes currenlty do NOT have uv texture space. if this is something you feel like you need, please contact me and I'll try and figure out a way to generate them.


Keep in Mind that these shaders can be QUITE heavy if you make them so! Especially for something like mobile even 10 trace steps is probably too much. I've broken the materials into differen folders w/ seperate step counts, but keep in mind that you can change these materials using the 'numSteps' property ( you may need to make the 'color multiplier' greater too to conteract the number of steps used ) 

The Rock, Metal, and Gravel textures are from https://cc0textures.com/ its a great resource and if you can you should support them on patreon so they can make more!


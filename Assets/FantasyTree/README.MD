MIT License 2020 Prismatic Simulations


Huge thanks to my patrons for making this possible!
If you would like to support and get this / other
tools early / free please check out https://www.patreon.com/cabbibo

Notes:

- currently no way to save teh animation curves for the trunks and branches im sorry!
- To save a new tree set, change the 'Save Name' and then press save.
- its possible to generate wayyy too much stuff so be careful
- you may want to add the tree data to your gitignore if you are making complex trees


Under the hood:

To save all of the procedural information within the mesh itself 
we are using multiple texturecoordinates.

In our case:

uv0 refers to base uv
uv1 refers to centerPosition ( a float3 )
uv2 refers to baseVal , total points and normalized time of creation ( that last one we use the most! )
uv3 refers to offset and row for flowers, and debug for trunk!

Check out the Build Mesh function if you want to dig into these values


There is a bunch of commented-out code throughout the tree.cs file. 
this is all there if you would prefer to do things through DrawProcedural 
and ComputeBuffers! otherwise you shouldn't really have to worry about it :)


Explanation of parameters

Many of the parameters will have a "REDUCER" value. this is the value
that the base value will be multiplied by every iteration level.

for example:

if you had a Length value of 8 and a reducer value of .5,
then your trunk would have a lenght of 8, the first branches
a lenght of 4, the second branches a length of 2, 3rd  1 , 4th .5 , etc. 

if the value is GREATER than one, it will grow. ( 8 -> 16 -> 32 for reducer of 2)









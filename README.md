# Shkadov*
A 100% Swift game engine with plans on being multi-platform. Currently supports OS X + Metal, but rendering is abstracted in a way such that Linux + Vulkan and even Windows + DirectX 12 should be possible. Porting to OpenGL may even be an option but not something I'm planning.

Currently there is a very basic scene graph which uses AABB (axis-aligned bounding box) trees for frustum culling and basic static object collision detection. I am planning on using AABB trees for determining which lights are visible also.

Code should be considered in an alpha state, and will change often in ways that break existing code. Use at your own risk. Check back next year (2017) and hopefully things will be more stable by then.

## Note:
To run the CastleDemo must first download [GTEngine](http://www.geometrictools.com/Downloads/Downloads.html) and place the geometry and textures from the Samples/Graphics/Castle sample into the provided directories in the CastleDemo bundle called assets/geometry and assets/textures.

Pressing `m` enables mouse look.

*A Shkadov thruster is a Class A [stellar engine](https://en.wikipedia.org/wiki/Stellar_engine).

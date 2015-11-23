## Best Practices for Shaders

1. Compile on initialization

2. Check program compile error only on debugging, use NSAssert.

3. Separate Shader Compiling...
- Pros: 
Flexible program struture
Speed up when there're many shaders to compile
Less Code
- Cons:
Runtime slow down, have to bind two programs together.

4. Use Precision Hints

5. Vector Calculation
- Example 1:
highp float f0, f1;
highp vec4 v0, v1;
v0 = (v1 * f0) * f1;
v0 = v1 * (f0 * f1); // faster
- Example 2:
highp vec4 v0, v1, v2;
v2.xy = v0 * v1; // specific xy make this calculation faster

6. Avoid Branching Instructions
Instead of creating a large shader with many conditional options, create smaller shaders specialized for specific rendering tasks.

7. Use Vertex Array Objects to config Vertex Array State

8. About using multiple passes to render a single object
- Ensure that the position data remains unchanged for every pass
- On the second and later stage, test for pixels that are on the surface of your model by calling the glDepthFunc function with GL_EQUAL as the parameter.

9. Reduce Texture Menory Usage
- Compress texture
- Use lower precision color formats
- Use properly sized textures
- Combine textures into texture atlases
- Use Mipmapping to reduce memory bandwidth usage


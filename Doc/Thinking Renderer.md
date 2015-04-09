## Thinking Renderer
CEModel -> CEMeterial -> CEProgram

# CEObject
has normal
has texture

# CEMeterial
- some lighting attributes
- testure?
- enable texture
- enable normal

object
meterial
texture
program
renderer

consider meterial for each model :NO
Categorized Render or Categorized Program

## Conclusion:
We will use categorized renderer.
- Renderer has many environment params to use, so it's good for extension.
- We introduce a RendererManager to manager different kinds of renderer. It's job is deside which renderer to use base on current object(model).

# how to match renderer with object?
+ projectionMatrix
+ vertexPosition

- textureCoordinate

- normal(lighting)

# Four Base Render
Renderer_V
Renderer_VT
Renderer_VN
Renderer_VTN
Renderer_Extension


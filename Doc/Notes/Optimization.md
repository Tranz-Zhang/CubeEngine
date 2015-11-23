# Optimization 2015.07.04

- NvTriStrip

- 16-bit texture ?  

- Always use lowp when dealing with the normal attribute
As with the normal, the tangent should always be normalized

- LODs(levels of detail), geomentry details base on distance from the camera

- Full State Control of OpenGL to reduce GL calls

- Shader Optimization
GLSL optimizer: https://github.com/aras-p/glsl-optimizer

- Simple computation is typically faster than memory access or transfer
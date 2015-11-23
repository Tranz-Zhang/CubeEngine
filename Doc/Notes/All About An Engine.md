## All About An Engine (2015.03.05)
Frameworks: OpenGLES2.0 GLKit UIKit

# 3DObject
Representing a 3D Object in the scene.
- Properties:
Location		:matrix3
ModelVertex	:array of matrix
Texture			:image data, could be shared
Animation?
Collision?
Meterial?

# LightObject
Representing a light source in the scene
- Properties:
lightType		: Direct, Point
lightColor	: color of light source

# CameraObject
control a camera

# SenceObject
Managing a scene, including 3DObject, LightObject, Camera


## Priorities
# MUST
- Support Base Object Rendering
- Support Texture
- Support Lighting
- Support Shadow

# May
- Object Animation
- Animation Binding

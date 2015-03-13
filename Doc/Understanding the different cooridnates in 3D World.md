## Understanding the different cooridnates in 3D World
We got *World Coordiante* *Self/Local Coordiante*

# IMPORTANT:Forget about the fucking anchorPoint of the object.

# Position
- World = parent.position + local.position * (parent.rotation)
- Local: relative to parent

# Rotation
- World = parent + local
- Local: relative to parent

# Scale
- local only!!!

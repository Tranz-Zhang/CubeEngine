# CERenderObject
- mesh data
>> VertexBuffer 			(Share)
>> IndicesBuffer 			(Share)

- material data
>> diffuse texture 		(Share)
>> normal texture 		(Share)
>> specular texture		(Share)
>> other material params

- skeleton
>> skeleton data			(Share)
>> animation data

- model matrix

# CEModelInfo
record model resource ids and store in db

# CEResourceManager
: offer resources for CERenderObject
: manage data in main memory and video memory, 
- load mesh data
- load texture data
- load other data

**How it works ?**
read data form disk
track duplicated resources
load to video memory?
output as CEResourceObject

# CEResourceObject
: represent resource data in video memory, the actural data is maintain by CEResourceManager.
: after remove from CEScene, call CEResourceManager to release resource in video memory
: during destory, call CEResourceManager to release resource in main memory

# CEResourceTexture
CEResourceTexture = CEResourceManager->loadTextureWithID();

# CEResourceMesh
CEResourceMesh = CEResourceManager->loadMeshWithID();




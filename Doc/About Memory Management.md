# About Memory Management

# CECache 
: base class for all momory cache
- inUse
- lastUseTime
- startUsing
- EndUsing
- deprecate
- priority

# Protocol:CECPUCache
: represent cache in memory
- loadToMemory
- removeFromMemory

# Protocol: CEGPUCache
: represent cache in gpu memory
- loadToGPU
- removeFromGPU

# CEVertexArrayCache -> CECache<CEGPUCache, CGCPUCache>
: represent a vertex buffer object, can load in gpu or cpu

# CETextureCache -> CECache<CEGPUCache, CGCPUCache>
: represent a texture cache, can load in gpu ro cpu

# CEDynamicTextureCache -> CECache<CEGPUCache>
: use to cache offscreen content in runtime, only use in gpu

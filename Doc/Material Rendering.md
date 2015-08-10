## Material Rendering

# Three type
- Solid
- Alpha-tested
- Transparent

# Rendering Order
1. Solid: sort the object from front to back can gain a bit of speed.
2. Alpha-tested: order alpha-tested objects from front to back to avoid processing unnecessary pixels. Actually you can mix alpha-tested with soild objects.
3. Semitransparent: *Draw from back to front*
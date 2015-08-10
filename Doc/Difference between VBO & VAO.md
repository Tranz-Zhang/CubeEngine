# Difference between VBO & VAO

A "buffer" or "buffer object" is a block of memory which may reside in video memory, meaning that you can't simply grab a pointer to it, write into it, and expect the changes to automatically affect subsequent operations. You need to either explicitly copy data into it (e.g. glBufferSubData), or map it to the CPU's address space (e.g. glMapBuffer) then unmap it before instructing the GPU to access it (it is an error to execute a GL operation which reads or writes a buffer while it is mapped).

A vertex buffer object (VBO) is a buffer which is used to hold a vertex attribute array (aka vertex array). If a buffer is bound to the GL_ARRAY_BUFFER binding point when glVertexAttribPointer (or glVertexPointer, glTexCoordPointer etc in the compatibility profile) is called, the "pointer" argument is interpreted as an offset into the buffer rather than as a pointer to client memory. Subsequent draw calls (glDrawArrays, glDrawElements, etc) will read data attribute data from the buffer rather than from client memory. The buffer used is the one bound at the time of the glVertexAttribPointer (etc) call, not the draw call.

A vertex array object (VAO) is a named object used to group together certain state relating to vertex arrays. If a VAO is bound (via glBindVertexArray), functions which affect how vertex attributes are sourced by the vertex shader modify the state in the bound VAO rather than global state. Specifically, the state stored in a VAO is, for each vertex array:

The size, type, stride, and normalized flag as set by glVertexAttribPointer.
The "pointer" (i.e. offset) as set by glVertexAttribPointer.
The buffer holding the data, i.e. that bound to GL_ARRAY_BUFFER at the time of the last glVertexAttribPointer call.
Whether the array contains integers (glVertexAttribIPointer) or fixed/floating point values (glVertexAttribPointer).
the divisor, as set by glVertexAttribDivisor.
whether the array is enabled (glEnableVertexAttribArray, glDisableVertexAttribArray).

In addition to the above per-array data, the buffer currently bound to GL_ELEMENT_ARRAY_BUFFER is stored in the VAO.

Note that the primitive restart index and primitive restart enabled state isn't stored in a VAO although (conceptually) it probably should be.

By grouping all of this state into a VAO, you can change all of it with a single glBindVertexArray call, rather than having to make 4 calls (glBindBuffer, glVertexAttribPointer, glVertexAttribDivisor, gl{Enable,Disable}VertexAttribArray) per vertex array plus one more for the element array.
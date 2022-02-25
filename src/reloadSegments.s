reloadSegments:
   /* Reload CS register containing code selector: */
   jmp   $0x08:$reload_CS
reload_CS:
   /* Reload data segment registers: */
   mov   $0x10, %AX
   mov   %AX, %DS
   mov   %AX, %ES
   mov   %AX, %FS
   mov   %AX, %GS
   mov   %AX, %SS
   ret

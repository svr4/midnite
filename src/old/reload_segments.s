.global reload_segments
.type reload_segments,%function
reload_segments:
   # Reload CS register containing code selector:
   # reload_CS: 0x08 points at the new code selector
   jmp   $0x08,$reload_CS
reload_CS:
   # Reload data segment registers:
   mov   0x10, %AX # 0x10 points at the new data selector
   mov   %AX, %DS
   mov   %AX, %ES
   mov   %AX, %FS
   mov   %AX, %GS
   mov   %AX, %SS
   ret
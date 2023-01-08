#ifndef MIDNITE_ISR_HPP
#define MIDNITE_ISR_HPP

#include <stddef.h>
#include <stdint.h>

struct interrupt_state
{
    uint32_t ds;
    uint32_t edi, esi, ebp, useless, ebx, edx, ecx, eax;
    uint32_t int_no, err_code;
    uint32_t eip, cs, eflags, esp, ss;
}__attribute__((packed));
typedef struct interrupt_state interrupt_state_t;

typedef void (*isr_t)(interrupt_state_t *);

void isr_register(uint8_t int_no, isr_t handler);

#define IRQ_BASE_NO     32
#define INT_NO_TIMER    (IRQ_BASE_NO + 0)
#define INT_NO_KEYBOARD (IRQ_BASE_NO + 1)




#endif
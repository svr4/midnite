#include "../../../include/interrupt/idt.hpp"
#include "../../../include/interrupt/isr.hpp"
#include "../../../include/display/terminal.hpp"
#include "../../../include/common/string.hpp"

isr_t isr_table[NUM_GATE_ENTRIES] = {NULL};



extern "C" void isr_handler(interrupt_state_t *state)
{   
    //uint8_t int_no = state->int_no;

    char * s = "caught interrupt";
    Terminal::terminal_write(s, strlen(s));
}
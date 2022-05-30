#ifndef MIDNITE_TERMINAL_HPP
#define MIDNITE_TERMINAL_HPP

#include <stddef.h>
#include "vga.hpp"
#include <stdint.h>

class Terminal
{
    private:

        void terminal_putentryat(char c, uint8_t color, size_t x, size_t y);

    public:
        static const vga_color TERMINAL_DEFAULT_COLOR_BG;
        static const vga_color TERMINAL_DEFAULT_COLOR_FG;

        static uint16_t* const VGA_MEMORY;
        static const size_t VGA_WIDTH = 80;
        static const size_t VGA_HEIGHT = 25;

        static size_t terminal_row;
        static size_t terminal_column;
        static uint16_t* terminal_buffer;

        void terminal_init();
        void terminal_write(const char *data, size_t size);
        void terminal_write_color(const char *data, size_t size, vga_color fg);
        void terminal_clear();

};
#endif
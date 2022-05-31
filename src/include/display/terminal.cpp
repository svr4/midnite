// #include <stddef.h>
// #include <stdint.h>
#include "../../../include/display/terminal.hpp"


uint16_t* const Terminal::VGA_MEMORY = (uint16_t*) 0xB8000;
const vga_color Terminal::TERMINAL_DEFAULT_COLOR_BG = VGA_COLOR_BLACK;
const vga_color Terminal::TERMINAL_DEFAULT_COLOR_FG = VGA_COLOR_GREEN;
// const vga_color Terminal::TERMINAL_DEFAULT_COLOR_FG = VGA_COLOR_WHITE;

size_t Terminal::terminal_row;
size_t Terminal::terminal_column;
uint16_t* Terminal::terminal_buffer;

void Terminal::terminal_putentryat(char c, uint8_t color, size_t x, size_t y)
{
	const size_t index = y * VGA_WIDTH + x;
	terminal_buffer[index] = vga_entry(c, color);
}

void Terminal::terminal_init()
{
    terminal_row = 0;
	terminal_column = 0;
	terminal_buffer = VGA_MEMORY;
	uint8_t terminal_color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);

	for (size_t y = 0; y < VGA_HEIGHT; y++) {
		for (size_t x = 0; x < VGA_WIDTH; x++) {
			const size_t index = y * VGA_WIDTH + x;
			terminal_buffer[index] = vga_entry(' ', terminal_color);
		}
	}
}
void Terminal::terminal_write(const char *data, size_t size)
{
    terminal_write_color(data, size, TERMINAL_DEFAULT_COLOR_FG);
}
void Terminal::terminal_write_color(const char *data, size_t size, vga_color fg)
{
	for (size_t i = 0; i < size; i++)
	{
		terminal_putentryat(data[i], fg, terminal_column, terminal_row);
		if (++terminal_column == VGA_WIDTH) {
			terminal_column = 0;
			if (++terminal_row == VGA_HEIGHT)
				terminal_row = 0;
		}
	}
}
void Terminal::terminal_clear()
{
	uint8_t default_color = vga_entry_color(TERMINAL_DEFAULT_COLOR_FG, TERMINAL_DEFAULT_COLOR_BG);
	for(size_t y=0; y < VGA_HEIGHT; ++y)
	{
		for(size_t x; x < VGA_WIDTH; ++x)
		{
			size_t idx = y * VGA_WIDTH + x;
			terminal_buffer[idx] = vga_entry(' ', default_color);
		}
	}

	terminal_row = 0;
	terminal_column = 0;
}
/* Cyclone V FPGA devices */
#define LEDR_BASE 0xFF200000
#define HEX3_HEX0_BASE 0xFF200020
#define HEX5_HEX4_BASE 0xFF200030
#define SW_BASE 0xFF200040
#define KEY_BASE 0xFF200050
#define TIMER_BASE 0xFF202000
#define PIXEL_BUF_CTRL_BASE 0xFF203020
#define CHAR_BUF_CTRL_BASE 0xFF203030

#define ABS(x) (((x) > 0) ? (x) : -(x))

/* Screen size. */
#define RESOLUTION_X 318
#define RESOLUTION_Y 238

/* Constants for animation */
#define FALSE 0
#define TRUE 1

#include <stdbool.h>
#include <stdlib.h>

void clear_screen(void);
void draw_box(int, int, short int);
void plot_pixel(int, int, short int);
void draw_line(int, int, int, int, short int);
void wait_for_vsync(void);
void swap(int *, int *);


int x_box[8], y_box[8]; // x, y coordinates of boxes to draw
int dx[8], dy[8]; // amount to move boxes in animation
int color_box[8]; // color
int prev_x_box[8], prev_y_box[8], old_x_box[8], old_y_box[8];
int color[] = {0xFFFF, 0xF800, 0x07E0, 0x001F, 0xF81F, 0x7FFF, 0x9813, 0xFFE0};

volatile int pixel_buffer_start;
short int Buffer1[240][512]; // 240 rows, 320 columns + paddings
short int Buffer2[240][512];

int main(void) {
    volatile int *pixel_ctrl_ptr = (int*) PIXEL_BUF_CTRL_BASE;

    // Prev_boxes store frame from 2 frames ago. Initialize to 0
    for (int i = 0; i < 8; i++) {
        prev_x_box[i] = 0;
        prev_y_box[i] = 0;
    }

    // Generate random start positions, directions and colors for boxes
    for (int i = 0; i < 8; i++) {
        x_box[i] = rand() % (RESOLUTION_X + 1);
        y_box[i] = rand() % (RESOLUTION_Y + 1);

        dx[i] = (((rand() % 2) * 2) - 1);
        dy[i] = (((rand() % 2) * 2) - 1);
        
        color_box[i] = color[rand() % 8]; // Random number from 0-7
    }

    /* set front pixel buffer to Buffer 1 */
    *(pixel_ctrl_ptr + 1) = (int)&Buffer1; // first store the address in the back buffer

    /* now, swap the front/back buffers, to set the front buffer location */
    wait_for_vsync();

    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen(); // pixel_buffer_start points to the pixel buffer

    /* set back pixel buffer to Buffer 2 */
    *(pixel_ctrl_ptr + 1) = (int)&Buffer2;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
    clear_screen();  // pixel_buffer_start points to the pixel buffer

    while (1) {

        /* Erasing any boxes and lines drawn in the last iteration */

        for (int i = 0; i < 8; i++) {
            // First, erase the old boxes
            draw_box(old_x_box[i], old_y_box[i], 0);

            // Then, erase the lines
            if (i < 7) {
                draw_line(old_x_box[i], old_y_box[i], old_x_box[i + 1], old_y_box[i + 1], 0);
            } else if (i == 7) {
                draw_line(old_x_box[i], old_y_box[i], old_x_box[0], old_y_box[0], 0);
            }
        }

        for (int i = 0; i < 8; i++) {
            // Update new locations of lines
            x_box[i] = x_box[i] + dx[i];
            y_box[i] = y_box[i] + dy[i];

            // Box hits 0 or RESOLUTION_X
            if ((x_box[i] < 1) || x_box[i] >= RESOLUTION_X) {
                dx[i] *= -1; // Flip in opposite direction
            }

            // Box hits 0 or RESOLUTION_Y
            if ((y_box[i] < 1) || y_box[i] >= RESOLUTION_Y) {
                dy[i] *= -1; // Flip in opposite direction
            }
        }

        for (int i = 0; i < 8; i++) {
            // Draw new boxes
            draw_box(x_box[i], y_box[i], color_box[i]);
            
            // Draw new lines
            if (i < 7) {
                draw_line(x_box[i], y_box[i], x_box[i + 1], y_box[i + 1], color_box[i]);
            } else {
                draw_line(x_box[i], y_box[i], x_box[0], y_box[0], color_box[i]);
            }
        }

        wait_for_vsync(); // swap front and back buffers on VGA vertical sync
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer

        // old_x_box, old_y_box <-- prev_x_box, prev_y_box
        // prev_x_box, prev_y_box <-- current box
        for (int i = 0; i < 8; i++)
        {
            old_x_box[i] = prev_x_box[i];
            old_y_box[i] = prev_y_box[i];

            prev_x_box[i] = x_box[i];
            prev_y_box[i] = y_box[i];
        }
    }
}

// code for subroutines (not shown)

void draw_box(int x, int y, short color) {
    for (int i = x; i < x + 2; i++) {
        for (int j = y; j < y + 2; j++) {
            plot_pixel(i, j, color);
        }
    }
}

void plot_pixel(int x, int y, short int line_color) {
    volatile short int *one_pixel_address;
    one_pixel_address = pixel_buffer_start + (y << 10) + (x << 1);
    *one_pixel_address = line_color;
}

void wait_for_vsync() {
    volatile int *pixel_ctrl_ptr = (int *) PIXEL_BUF_CTRL_BASE;
    int bufferStatusBit;
    *(pixel_ctrl_ptr) = 1;                         // Write 1 into buffer register, causing a frame buffer swap.
    bufferStatusBit = *(pixel_ctrl_ptr + 3) & 1; // isolates S bit
    // implementing v-sync (waiting for S bit to go low)
    while (bufferStatusBit != 0)
    {
        bufferStatusBit = *(pixel_ctrl_ptr + 3) & 1;
    }
}

void clear_screen() {
    for (int x = 0; x < 320; x++) {
        for (int y = 0; y < 240; y++) {
            plot_pixel(x, y, 0);
        }
    }
}

void draw_line(int x0, int y0, int x1, int y1, short int colour){
	
	bool is_steep = abs(y1 - y0) > abs(x1 - x0);
	
 	if(is_steep){
		swap(&x0, &y0);
 		swap(&x1, &y1);
	}	
 	if(x0 > x1){
 		swap(&x0, &x1);
 		swap(&y0, &y1);
	}

 	int deltax = x1 - x0;
 	int deltay = abs(y1 - y0);
 	int error = -(deltax / 2);
	int y_step = 0;
 	int y = y0;
 	if(y0 < y1){
		y_step = 1;
	}else{
		y_step = -1;
	}

 	for(int x = x0; x <= x1; x++){
 		if(is_steep){
 			plot_pixel(y, x, colour);
		}else{
 			plot_pixel(x, y, colour);
		}
 		error = error + deltay;
 		if(error > 0){
 			y = y + y_step;
			error = error - deltax;
		}
	}
}

void swap(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}
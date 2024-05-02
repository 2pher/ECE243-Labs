#include <stdbool.h>

int pixel_buffer_start; // global variable

void update_image(bool *moveDown, int *y);
void plot_pixel(int x, int y, short int line_color);
void draw_line(int y, short int colour);
void clear_screen();

int main(void){
	
	//get address of buffer controller
	volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
	pixel_buffer_start = *pixel_ctrl_ptr;
	
	//clear screen
	clear_screen();
	
	//draw initial line
	int y = 0;
	for(int x = 0; x < 320; x++){
		plot_pixel(x, y, 0xFFFF);
	}
	bool moveDown = true;
	*(pixel_ctrl_ptr) = 1;
	//loop graphics infinitely
	while(true){
		//write 1 to buffer

		int status = *(pixel_ctrl_ptr+3) &1;
		while (status != 0) {
			status = *(pixel_ctrl_ptr+3) &1;
		}
		update_image(&moveDown, &y);
		*(pixel_ctrl_ptr) = 1;
		//wait for status to return 1
	}
}

void update_image(bool *moveDown, int *y){

	//determine whether line moves down or up
	if(*y == 239){
		*moveDown = false;
	}else if(*y == 0){
		*moveDown = true;
	}
	
	//erase old line
	draw_line(*y, 0);
	
	//update y
	if(*moveDown){
		//increment y, then draw line
		*y = *y + 1;
	}else{
		//decrement y, then draw line
		*y = *y - 1;
	}
	//draw new line
	draw_line(*y, 0xFFFF);
}

void plot_pixel(int x, int y, short int line_color){
	volatile short int *one_pixel_address;
	one_pixel_address = pixel_buffer_start + (y << 10) + (x << 1);
	*one_pixel_address = line_color;
}

void draw_line(int y, short int colour){
	for(int x = 0; x < 320; x++){
		plot_pixel(x, y, colour);
	}
}

void clear_screen(){
	for(int x = 0; x < 320; x++){
		for(int y = 0; y < 240; y++){
			plot_pixel(x, y, 0);
		}
	}
}

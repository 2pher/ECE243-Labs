#include <stdio.h>
	
int main(){

	volatile int* KEYs = 0xFF200050;
	volatile int* LEDs = 0xFF200000;
	*(KEYs + 3) = 0xf;
	*LEDs = 0;
	
	while(1){
	
		int EDGE = *(KEYs + 3);
		int LED_value = *LEDs;
		
		while(EDGE == 0){
			EDGE = *(KEYs + 3);
			LED_value = *LEDs;
		}
		
		if(EDGE == 1 && LED_value == 0){
			*LEDs = 0x3FF;
			*(KEYs + 3) = 0xF;
		}else if(EDGE == 2 && LED_value == 0x3FF){
			*LEDs = 0x0;
			*(KEYs + 3) = 0xF;
		}
		*(KEYs + 3) = 0xF;
	}	
}
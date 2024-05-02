#include <stdio.h>

struct audio_t {
      volatile unsigned int control;
      volatile unsigned char rarc;
      volatile unsigned char ralc;
      volatile unsigned char wsrc;
      volatile unsigned char wslc;
      volatile unsigned int ldata;
      volatile unsigned int rdata;
};

int main(){

	struct audio_t *const audiop = ((struct audio_t *)0xff203040);

	audiop->control = 0xC; //clear all queues -- CW & CR
	audiop->control = 0; // resume conversion in & out

	while (1){
	   
    	while (audiop->rarc != 0) {
			audiop->ldata = audiop->ldata;
        	audiop->rdata = audiop->rdata;
    	}
    }
}	
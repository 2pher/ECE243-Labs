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
	
	int BUF_SIZE = 50000;
	int N = 0.4 * 8000;

	int left_buffer[BUF_SIZE];
	int right_buffer[BUF_SIZE];
	int left_output[BUF_SIZE + N];
	int right_output[BUF_SIZE + N];
	
	while(1){

     int buffer_index;
     audiop->control = 0x4; // clear the input FIFOs
     audiop->control = 0x0; // resume input conversion
     buffer_index = 0;
	
     while (buffer_index < BUF_SIZE) { 
     	// read samples if there are any in the input FIFOs

     	if (audiop->rarc) {
     		left_buffer[buffer_index] = audiop->ldata;
        	right_buffer[buffer_index] = audiop->rdata;
        	++buffer_index;
     	}
    } 
		
		buffer_index = 0;
		double damping = 0.5;
    	audiop->control = 0x8; // clear the output FIFOs
    	audiop->control = 0x0; // resume input conversion
    	while (buffer_index < BUF_SIZE) {
    		// output data if there is space in the output FIFOs
			if(audiop->wsrc && buffer_index > N){
				audiop->ldata = left_buffer[buffer_index] + (damping * left_output[buffer_index - N]);
            	audiop->rdata = right_buffer[buffer_index] + (damping * right_output[buffer_index - N]);
				left_output[buffer_index] = left_buffer[buffer_index] + (damping * left_output[buffer_index - N]); 											  
				right_output[buffer_index] = right_buffer[buffer_index] + (damping * right_output[buffer_index - N]);											  
            	++buffer_index;
			}else if (audiop->wsrc) {
        		audiop->ldata = left_buffer[buffer_index];
            	audiop->rdata = right_buffer[buffer_index];
				left_output[buffer_index] = left_buffer[buffer_index];
				right_output[buffer_index] = right_buffer[buffer_index];
            	++buffer_index;
        	}
    	}
	}
}
#define AUDIO_BASE  0xFF203040
#define SWITCHES    0xFF200040
int main(void) {

    volatile int* audio_ptr = (int*) AUDIO_BASE;
    volatile int* switch_ptr = (int*) SWITCHES;


    int switches, outFreq, sampleRate, WSLC, fifospace, edge, delay;


    *(audio_ptr) = 0x4; // Clear output & input FIFOs
    *(audio_ptr) = 0;
    edge = 1;

    while (1) {
        delay = 0;
        switches = *switch_ptr;

        outFreq = (switches*2)+100;
		
        sampleRate = 50000000 / outFreq;
        fifospace = *(audio_ptr + 1);

        WSLC = fifospace >> 24; // How many of left output FIFO words are empty

        for (int i = 0; i < sampleRate; i++) {
            if (WSLC <= 0) {
                while (delay <= sampleRate/2) {
                    delay++;
                }
            }

            if (edge == 1) {
                *(audio_ptr + 2) = 0xFFFFFFF;
                *(audio_ptr + 3) = 0xFFFFFFF;
            } else {
                *(audio_ptr + 2) = 0;
                *(audio_ptr + 3) = 0;
            }
            
        }
        edge = edge ^ 1; // Flip edge value
    }
}
	
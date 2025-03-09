#include <stdio.h>      // herein be sprintf 
#include <stdbool.h>

#define break() {__asm in a,(0x2e) __endasm;} // for debugging. may be risky to use as it trashes A

void print(unsigned char* szMessage);
bool disk_support(void);
bool has_signature(void);
unsigned char get_drive_count(void);


unsigned char main(void)
{
    unsigned char auBuffer[128];
    unsigned char* szTemplate = "Number of physical drives:%u";
    unsigned char v = 0;

    // break();
    if(disk_support())
    {
        if(has_signature())
            v = get_drive_count();
        else
            print("Unknown signature, cannot determine number of drives\r\n");
    }
    else
        print("No disk support\r\n");

    sprintf(auBuffer, szTemplate, v);
    print(auBuffer);

#if ROM_OUTPUT_FILE==1 
spin: goto spin;
#endif

    return 0;
}
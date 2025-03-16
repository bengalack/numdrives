#include <stdio.h>      // herein be sprintf 
#include <stdbool.h>

#define break() {__asm in a,(0x2e) __endasm;} // for debugging. may be risky to use as it trashes A

#define HIMEM               0xFC4A
#define SLTWRK              0xFD09
#define DISK_DRIVER_PAGE    1

void print(unsigned char* szMessage);
bool disk_support(void);
unsigned char get_signature_slot(void);
unsigned char get_drive_count(unsigned char*);

// ---------------------------------------------------------------------------
// See SLTWRK: https://www.msx.org/wiki/System_variables_and_work_area
// 2 bytes per page
unsigned char** get_sltwrk_address(unsigned char uSltId)
{
    unsigned char uOffset = 0;

    uOffset =   (DISK_DRIVER_PAGE + 
                (uSltId & 0b11) * 16 + 
                (uSltId & 0b1100)) * 2;

    return (unsigned char*) SLTWRK + uOffset;
}

// ---------------------------------------------------------------------------
// The whole discussion about finding number of drives started here:
// https://www.msx.org/forum/msx-talk/development/best-way-to-identify-the-msx-model-at-runtime?page=2#comment-472986
// This will only work if the diskdrive has not been in use. Only initialised, and thus, this program should
// be in ROM mode/format. Assumes main to be called AFTER all ROMs have been initialised.
//
unsigned char main(void)
{
    unsigned char auBuffer[128];
    unsigned const char* szTemplate = "Number of physical drives: %u";
    unsigned char v = 0;
    unsigned char uSigSlot = 255;

    if(disk_support())
    {
        uSigSlot = get_signature_slot();  // Where the rom starts with "ABoWve" or "AB<@\W"

        if(uSigSlot !=255 )
        {
            unsigned char*  pHIMEM       = *((unsigned char**)HIMEM);
            unsigned char** pSLTWRKEntry = get_sltwrk_address(uSigSlot);
            unsigned char*  pSLTWRK      = *pSLTWRKEntry;
            
            // break();

            if(pSLTWRK < pHIMEM)
            {
                print("Unexpectedly low SLTWORK address\r\n");
            }
            else
            {
                if(pSLTWRK >= (unsigned char*)0xF380)
                    print("Unexpectedly high SLTWORK address %hu\r\n");
                else
                    v = get_drive_count(pSLTWRK);
            }
        }
        else
        {
            print("Unknown signature... we will be guessing\r\n");
            v = 1; // Big chance it has 1 drive.
        }
    }
    else
        print("No disk support\r\n");

    sprintf(auBuffer, szTemplate, v);
    print(auBuffer);

    unsigned short himem = *(unsigned short*)HIMEM;

    sprintf(auBuffer, "\r\nHIMEM:  0x%x", himem);
    print(auBuffer);

    sprintf(auBuffer, "\r\nALLOC:  0x%x", 0xF380-himem);
    print(auBuffer);

#if ROM_OUTPUT_FILE==1 
spin: goto spin;
#else
ERROR: ONLY ROM SUPPORTED IN THIS VERSION
#endif


    return 0;
}
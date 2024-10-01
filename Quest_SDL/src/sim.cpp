#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
#include <memory>
#include <vector>
#include <pthread.h>
#include <thread>
#include "sim.h"
#include "crt_core.h"
#include <verilated_fst_c.h>
#include "VQuest__Syms.h"


#define COLOR_LEVEL (WHITE_LEVEL - 20)
int ccmodI[CRT_CC_SAMPLES]; /* color phase for mod */
int ccmodQ[CRT_CC_SAMPLES]; /* color phase for mod */
int ccburst[CRT_CC_SAMPLES]; /* color phase for burst */

void (*sim_draw)();
Uint32 *screenPixels;
SDL_Texture *screen;
unsigned char *sim_video;
struct CRT *sim_crt;
static uint64_t vidTime = 0;
static int PhaseOffset = 1;
struct COLOR_SETTINGS {
    char *text[8];
    uint8_t index;
    int Amplitude[8];
    int Phase[8];
    int PhaseAmp[8];
};

static COLOR_SETTINGS colors;

VerilatedFstC* m_trace;
VQuest__Syms *Quest_Syms;
VQuest *Quest;

Uint64 main_time=0;
Uint64 main_trace=0;
Uint8 trace=1;


Uint8 rom[0x4000];
Uint8 ram[0x8000];

Uint8 Display_Edge=0;
Uint8 HSync_Edge=0;
Uint8 VSync_Edge=0;
Uint8 Ready_Edge=0;
Uint8 Burst_Edge=0;
Uint8 Video_Last=0; 
Uint8 MW_Last=0;
Uint8 MR_Last=0;
Uint8 P_Last=0;
Uint16 R3_Last=0;
Uint16 ADDR_Last=0;
Uint8 colorBurst=1;
Uint16 keypad = 0;
Uint16 drawX, drawY, scanX;

Uint16 FrameCount = 0;
Uint16 FrameCurent = 0;

Uint64 ticksLast = 0;
char tmpstr[64];

pthread_t demod_thread;

int loadFile(const char *filename, Uint8 *pointer, const Uint32 len)
{
    FILE *fp = fopen(filename, "r");
    if ( fp == 0 )
    {
        printf( "Could not open file\n" );
        return -1;
    }

    fseek(fp, 0L, SEEK_END);
    Uint32 fsize = ftell(fp);
    fseek(fp, 0L, SEEK_SET);

    if(fsize > len){
        printf("File is to big!\n");
        fsize = len;
    }

    size_t s = fread(pointer, 1, fsize, fp);
    fclose(fp);

    return s;
}

int saveFile(const char *filename, Uint8 *pointer, const Uint32 len)
{
    FILE *fp = fopen(filename, "w+");
    if ( fp == 0 )
    {
        printf( "Could not open file\n" );
        return -1;
    }
    size_t s = fwrite(pointer, 1, len, fp);
    fclose(fp);

    return 0;
}

void genIQ()
{
    int sn, cs, n;
    for (int x = 0; x < CRT_CC_SAMPLES; x++) {
        n = x * (360 / CRT_CC_SAMPLES);
        crt_sincos14(&sn, &cs, (n + 33) * 8192 / 180);
        ccburst[x] = sn >> 10;
        crt_sincos14(&sn, &cs, n * 8192 / 180);
        ccmodI[x] = sn >> 10;
        crt_sincos14(&sn, &cs, (n - 90) * 8192 / 180);
        ccmodQ[x] = sn >> 10;
    }
}

void sim_init(unsigned char *v, SDL_Texture *td, void (*d)(), struct CRT *c, int argc, char *argv[]){
    //screenPixels = p;
    sim_draw = d;
    screen = td;
    sim_video = v;
    sim_crt = c;
    sim_crt->noise = 5;

    SDL_UpdateTexture(screen, NULL, screenPixels, 240 * sizeof(Uint32));
    sim_draw();

    printf("Started.\n");
    genIQ();
    
    char *rom_file = "../data/SUPRMON-v1.1-2708.rom";
    char *ram_file = "../data/Tinybasi.bin";
    char *chip8 = "";
    
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-rom") == 0 && i + 1 < argc) {
            rom_file = argv[i + 1];
        } else if (strcmp(argv[i], "-ram") == 0 && i + 1 < argc) {
            ram_file = argv[i + 1];
        } else if (strcmp(argv[i], "-chip8") == 0 && i + 1 < argc) {
            chip8 = argv[i + 1];
        }
    }
    
    loadFile(rom_file, rom, 0x3fff);
    loadFile(ram_file, ram, 0x3fff);
    if (strlen(chip8) > 0) {
        loadFile(chip8, &ram[0x0200], 0x3fff);
    }
    
    Quest = new VQuest();

	#ifdef TRACE
		Verilated::traceEverOn(true);
		m_trace = new VerilatedFstC;
		Quest->trace(m_trace, 99);
		m_trace->open ("simx.fst");
	#endif

    printf("CRT_INPUT_SIZE: %i\n", CRT_INPUT_SIZE);
    printf("DOT_ns: %lu\n", DOT_ns);
    printf("DOTx6_ns: %lu\n", DOTx6_ns);
    printf("LINE_BEG: %lu\n", LINE_BEG);
    printf("FP_ns: %lu\n", FP_ns);
    printf("SYNC_ns: %lu\n", SYNC_ns);
    printf("BW_ns: %lu\n", BW_ns);
    printf("CB_ns: %lu\n", CB_ns);
    printf("BP_ns: %lu\n", BP_ns);
    printf("AV_ns: %lu\n", AV_ns);
    printf("HB_ns: %lu\n", HB_ns);
    printf("LINE_ns: %lu\n", LINE_ns);
}

int keyIn = 0;
int keyWait = false;
int shift = false;
void sim_keyevent(int event, int key) {
    if(event == SDL_KEYDOWN && 
        key != SDLK_LSHIFT &&
        key != SDLK_RSHIFT &&
        key != SDLK_LCTRL &&
        key != SDLK_RCTRL &&
        key != SDLK_LALT &&
        key != SDLK_RALT
    ){
        keyIn = key;
        if(key == '\'' && shift) keyIn = '"';
        if(key != '\n') keyWait = true;
    }else if(event == SDL_KEYDOWN && 
        key == SDLK_LSHIFT ||
        key == SDLK_RSHIFT){
        shift = true;
    }else if(event == SDL_KEYUP && 
        key == SDLK_LSHIFT ||
        key == SDLK_RSHIFT){
        shift = false;
    }

    if(event == SDL_KEYDOWN)
    switch (key) {
        case SDLK_9:
            if (sim_crt->noise > 0) {
                sim_crt->noise -= 1;
                printf("Index: %i\n", sim_crt->noise);
            }
            break;
        case SDLK_0:
            if (sim_crt->noise < 100) {
                sim_crt->noise += 1;
                printf("Index: %i\n", sim_crt->noise);
            }
            break;

        case SDLK_o:
            colors.Amplitude[colors.index] -= 1;
            printf("Amplitude[%u]: %i\n", colors.index, colors.Amplitude[colors.index]);
            break;

        case SDLK_p:
            colors.Amplitude[colors.index] += 1;
            printf("Amplitude[%u]: %i\n", colors.index, colors.Amplitude[colors.index]);
            break;

        case SDLK_k:
            colors.Phase[colors.index] -= 50;
            printf("Phase[%u]: %i\n", colors.index, colors.Phase[colors.index]);
            break;

        case SDLK_l:
            colors.Phase[colors.index] += 50;
            printf("Phase[%u]: %i\n", colors.index, colors.Phase[colors.index]);
            break;

        case SDLK_n:
            colors.PhaseAmp[colors.index] -= 50;
            printf("PhaseAmp[%u]: %i\n", colors.index, colors.PhaseAmp[colors.index]);
            break;

        case SDLK_m:
            colors.PhaseAmp[colors.index] += 50;
            printf("PhaseAmp[%u]: %i\n", colors.index, colors.PhaseAmp[colors.index]);
            break;

        case SDLK_1:
            keypad |= 0x0001;   
            break;
                
        case SDLK_2:
            keypad |= 0x0002;   
            break;  

        case SDLK_3:
            keypad |= 0x0004;   
            break;  

        case SDLK_4:
            keypad |= 0x0008;   
            break;  

        case SDLK_q:
            keypad |= 0x0010;   
            break;  

        case SDLK_w:
            keypad |= 0x0020;   
            break; 

        case SDLK_e:
            keypad |= 0x0040;   
            break;    

        case SDLK_r:
            keypad |= 0x0080;   
            break;    

        case SDLK_a:
            keypad |= 0x0100;   
            break;    

        case SDLK_s:
            keypad |= 0x0200;   
            break;    

        case SDLK_d:
            keypad |= 0x0400;   
            break; 

        case SDLK_f:
            keypad |= 0x0800;   
            break;    

        case SDLK_z:
            keypad |= 0x1000;   
            break;    

        case SDLK_x:
            keypad |= 0x2000;   
            break;    

        case SDLK_c:
            keypad |= 0x4000;   
            break;    

        case SDLK_v:
            keypad |= 0x8000;   
            break;    
    }
    if(event == SDL_KEYUP)
    switch (key) {
        case SDLK_1:
            keypad &= ~0x0001;   
            break;
                
        case SDLK_2:
            keypad &= ~0x0002;   
            break;  

        case SDLK_3:
            keypad &= ~0x0004;   
            break;  

        case SDLK_4:
            keypad &= ~0x0008;   
            break;  

        case SDLK_q:
            keypad &= ~0x0010;   
            break;  

        case SDLK_w:
            keypad &= ~0x0020;   
            break; 

        case SDLK_e:
            keypad &= ~0x0040;   
            break;    

        case SDLK_r:
            keypad &= ~0x0080;   
            break;    

        case SDLK_a:
            keypad &= ~0x0100;   
            break;    

        case SDLK_s:
            keypad &= ~0x0200;   
            break;    

        case SDLK_d:
            keypad &= ~0x0400;   
            break; 

        case SDLK_f:
            keypad &= ~0x0800;   
            break;    

        case SDLK_z:
            keypad &= ~0x1000;   
            break;    

        case SDLK_x:
            keypad &= ~0x2000;   
            break;    

        case SDLK_c:
            keypad &= ~0x4000;   
            break;  

        case SDLK_v:
            keypad &= ~0x8000;   
            break;    
    }
}

Uint32 colorsRGB[]={
    0x00000000,
    0x0000FF00,
    0x000000FF,
    0x0000FFFF,
    0x00FF0000,
    0x00FFFF00,
    0x00FF00FF,
    0x00FFFFFF,
};

void doNTSC(int CompSync, int Video)
{	
    int ire = -40, fi, fq, fy;
    int pA;
    int rA, gA, bA;
    int rB = 127, gB = 127, bB = 127;
	if(CompSync) ire=BLANK_LEVEL;
	if(Video) ire=WHITE_LEVEL;

    uint32_t i;
    int xoff;
    for (i = ns2pos(vidTime); i < ns2pos(vidTime+VERILOG_ns); i++)
    {
        //xoff = i % CRT_CC_SAMPLES;
        // if(Burst) ire = ccburst[(i + 0) & 3];
        
        // if(Color > 0) {
        //     ire = BLACK_LEVEL ;

        //     pA = colorsRGB[Color];
        //     bA = (pA >> 16) & 0xff;
        //     gA = (pA >>  8) & 0xff;
        //     rA = (pA >>  0) & 0xff;

        //     fy = (19595 * rA + 38470 * gA +  7471 * bA) >> 14;
        //     fi = (39059 * rA - 18022 * gA - 21103 * bA) >> 14;
        //     fq = (13894 * rA - 34275 * gA + 20382 * bA) >> 14;

        //     fy = fy;
        //     fi = fi * ccmodI[xoff] >> 4;
        //     fq = fq * ccmodQ[xoff] >> 4;
        //     ire += (fy + fi + fq) * (WHITE_LEVEL * 100 / 100) >> 10;
        //     if (ire < 0)   ire = 0;
        //     if (ire > 110) ire = 110;
        // }
        sim_crt->analog[i] = ire;
    }

    vidTime+=VERILOG_ns;
	return;
}

void doFrame()
{
    // #pragma omp parallel 
    // {
        if(!Quest->io_Pixie_VSync && VSync_Edge){
            sim_draw();
            sprintf(tmpstr,"Frames/Frame%04i.png",FrameCount++);
            Uint64 ticks = SDL_GetTicks64();
            //printf("Frame: %i\n", FrameCount);
            ticksLast = ticks;
            screenshot(tmpstr);
            vidTime = 0;
            memset(sim_crt->analog, 0, CRT_INPUT_SIZE);
            doNTSC(Quest->io_sync, Quest->io_video);
        }else{
            doNTSC(Quest->io_sync, Quest->io_video);
        }
    //}
    return;
}

void sim_run(){
    Quest->reset = !(main_time>10);
    Quest->io_SerialIn = true;

    Quest->io_Keys_R = (main_time>10) && (main_time<20);
    Quest->io_Keys_G = (main_time>20) && (main_time<30);
    Quest->io_Keys_S = false;
    Quest->io_Keys_W = false;

    Quest->io_Keys_M = false;
    Quest->io_Keys_P = false;
    Quest->io_Keys_I = false;
    Quest->io_Keys_L = false;

    // Quest->io_keypad_col = 0xFF;
    // switch((~Quest->io_keypad_row) & 0xf){
    //     case 0x01:
    //         Quest->io_keypad_col = (~keypad) & 0x000f;
    //     break;
    //     case 0x02:
    //         Quest->io_keypad_col = ((~keypad) >> 4) & 0x000f;
    //     break;
    //     case 0x04:
    //         Quest->io_keypad_col = ((~keypad) >> 8) & 0x000f;
    //     break;
    //     case 0x08:
    //         Quest->io_keypad_col = ((~keypad) >> 12) & 0x000f;
    //     break;
    // }
    //printf("0x%01X, 0x%01X\n", ~Quest->io_keypad_col, ~Quest->io_keypad_row);
    
    Quest->io_KeyHeld_ = !keyWait;
    if(keyWait && Quest->io_ParallelN) keyWait = false;
    Quest->io_Parallel = keyIn;

    doFrame();

    Quest->io_rom_din = rom[Quest->io_rom_addr];

    Quest->io_ram_din = ram[Quest->io_ram_addr];
    if(Quest->io_ram_wr && main_time > 11) ram[Quest->io_ram_addr] = Quest->io_ram_dout;

    VSync_Edge = Quest->io_Pixie_VSync;
    HSync_Edge = Quest->io_Pixie_HSync;
    Video_Last = Quest->io_video;

    Quest->io_Debug_d1 = Quest->io_ram_addr >= 0x766 && Quest->io_ram_addr < 0x9d8 && !Quest->io_CPU_MRD;
    Quest->io_Debug_d2 = Quest->io_ram_addr >= 0xcb8 && Quest->io_ram_addr < 0xDB9 && !Quest->io_CPU_MRD;

    main_time++;
    Quest->clk = 1;
    Quest->eval();

    #ifdef TRACE
        if(trace){
            main_trace++;
            m_trace->dump(main_trace*((DOT_ns/2)*1000));
        }
    #endif

    main_time++;
    Quest->clk = 0;
    Quest->eval();

    #ifdef TRACE
        if(trace){
            main_trace++;
            m_trace->dump(main_trace*((DOT_ns/2)*1000));
        }
    #endif
}

void sim_end()
{
    printf("Ended.\n");
    Quest->final();
    saveFile("test.bin", ram, 0x8000);
    #ifdef TRACE
        m_trace->close();
    #endif
}
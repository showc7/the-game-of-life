#include <GL/freeglut.h>

#include "gpu.h"
#include "screen.h"
#include <memory.h>
#include <stdio.h>

#ifdef DEBUG
#include <stdio.h>
#endif

#define swap(t,a,b){t _t=a; a=b; b=_t;}

#define ARRAY_WIDTH		10
#define ARRAY_HEIGHT	10

#define CUBE_SIDE		5

float * first, * second;
float * dev_first, * dev_second;
int * dev_width, * dev_height;

int _width = ARRAY_WIDTH;
int _height = ARRAY_HEIGHT;

void show(float * field, int width, int height)
{
	printf("====================\n");
	for(int i=0;i<width;i++)
	{
		for(int j=0;j<height;j++)
			if(field[i*width+j] != 0) printf("*");
			else printf(" ");
		
		printf("\n");
	}
}

void Init_GPU()
{
	#ifdef DEBUG
		puts("Init_GPU");	
	#endif
	
	first = (float *) malloc(sizeof(float) * _width * _height);
	second = (float *) malloc(sizeof(float) * _width * _height);
	
	memset(first,0,sizeof(float) * _width * _height);
	memset(second,0,sizeof(float) * _width * _height);
	
	first[2*_width+5] = 1;		//
	first[2*_width+6] = 1;		//
	first[3*_width+6] = 1;		// fill in the field
	first[3*_width+7] = 1;		//
	first[1*_width+7] = 1;		//
	
	show(first,_width,_height);
	InitCudaArrays(&dev_first,&dev_second,&dev_width,&dev_height,_width,_height);
	CopyDataToCudaDevice(dev_first,dev_second,first,dev_width,dev_height,_width,_height);
}

void transfer_gpu()
{
	#ifdef DEBUG
		printf("transfer_gpu\n\tdev_first: %p\n\tdev_second %p\n",dev_first,dev_second);	
	#endif
	int threads = ARRAY_WIDTH;
	int blocks = ARRAY_HEIGHT;
	
	RunCudaDevice(threads,blocks,dev_first,dev_second,dev_width,dev_height,_width,_height);
	GetDataFromCudaDevice(first,dev_second,_width,_height);
	show(first,_width,_height);
	CudaSwapArrays(&dev_first,&dev_second);
}


void timer(int = 0)
{
	#ifdef DEBUG
		puts(".");
	#endif
	transfer_gpu();
	
	draw_screen(first,_width,_height);
	draw();
	glutTimerFunc(100, timer, 0); // shold be 200 ms
}

void Run()
{	
	#ifdef DEBUG
		puts("run");	
	#endif
	draw();
	timer();
	glutMainLoop();
}

int main(int argc, char** argv)
{
	#ifdef DEBUG
		puts("main started secsessfuly");
	#endif
	Init_GPU();	

	int screen_width = ARRAY_WIDTH * CUBE_SIDE, screen_height = ARRAY_HEIGHT * CUBE_SIDE;
	#ifdef DEBUG
		printf("screen_width -> %d | screen_height -> %d",screen_width,screen_height);
	#endif
	SetSettings();

	InitializeFreeGlut(argc,argv,screen_width,screen_height);
	
	Run();

	FreeCudaDevice(dev_first,dev_second,dev_width,dev_height,_width,_height);

	return 0;
}

/*
 *
 * compiling:
 * nvcc -lglut -LGLEW life.cuda.cu -o life -g -G
 * 
 * -g -G  - debug options
 * 
 * for it's work:
 * export LD_LIBRARY_PATH=:/usr/local/cuda/lib
 * export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/libnvvp/
 * 
 * cuda-gdb
 */

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

#include <GL/freeglut.h>
#include <GL/gl.h>
#include <GL/glext.h>
#include <time.h>
#include <fstream>

#define cell_size			5
#define uchar				unsigned char
#define screen_width 		150
#define screen_height 		150

#define FIELD_WIDTH			10
#define FIELD_HEIGHT		10
#define NUMBER_OF_THREADS	10

//int width = screen_width*cell_size; //770; //1024;
//int height = screen_width*cell_size; //770; //768;

float * state_first;	// on PC
float * state_second;	// arrays

float * dev_first_state;	// on Card
float * dev_second_state;	// arrays

int * dev_width;
int * dev_height;

int width = FIELD_WIDTH;
int height = FIELD_HEIGHT;

uchar4 color1,color2;

void draw()
{
	glClearColor(0.0, 0.0, 0.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT);
	glDrawPixels(width, height, GL_RGBA, GL_UNSIGNED_BYTE, screen);
	glFlush();
}

void key(unsigned char key, int x, int y)
{
	switch (key)
	{
	case 27:
		printf("handled escape\nExit application\n");
		glutLeaveMainLoop();
		break;
	case ' ':
		transfer_cpu();
		draw_field();
		break;
	default:
		break;
	}
	draw();
}

void timer(int = 0)
{
	transfer_cpu();
	
	draw_field();
	draw();
	glutTimerFunc(200, timer, 0);
}

void start()
{
	gen();
	draw_field();
//	transfer_cpu();
	timer();
}

__global__ void kernel(float * first, float * second , int * width, int * height)
{
	int id = threadIdx.x + blockIdx.x * blockDim.x;
	
	*(second + id) = 0;

	if(id <= (*width)*(*height))
	{
		int num = 0;
		
		// change to num += ...
		
		/*
		if(*(first + id + 1) == 1) num++;
		if(*(first + id - 1) == 1) num++;
		if(*(first + id + *height) == 1) num++;
		if(*(first + id - *height) == 1) num++;
		if(*(first + id + *height + 1) == 1) num++;
		if(*(first + id + *height - 1) == 1) num++;
		if(*(first + id - *height + 1) == 1) num++;
		if(*(first + id - *height - 1) == 1) num++;
		*/
		
		num += *(first + id + 1);
		num += *(first + id - 1);
		num += *(first + id + *height);
		num += *(first + id - *height);
		num += *(first + id + *height + 1);
		num += *(first + id + *height - 1);
		num += *(first + id - *height + 1);
		num += *(first + id - *height - 1);
		
		switch(num)
		{
			case 3 : *(second + id) = 1; break;
			case 2 : if(*(first + id) == 1) *(second + id) = 1; break;
			default : *(second + id) = 0; break;
		}
		
	}
}

void GetDataFromCudaDevice(int width, int height)
{
	cudaMemcpy(state_first,dev_second_state,sizeof(float)*width*height,cudaMemcpyDeviceToHost);
}

void CopyDataToCudaDevice(int width, int height)
{
	cudaMemcpy(dev_first_state,state_first,sizeof(float)*width*height,cudaMemcpyHostToDevice);
	cudaMemset(dev_second_state,0,sizeof(float)*width*height);
	
	cudaMemcpy(dev_width,&width,sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_height,&height,sizeof(int),cudaMemcpyHostToDevice);
}

void InitCudaArrays(int width, int height)
{
	cudaError_t cudaStatus;

	// Choose which GPU to run on, change this on a multi-GPU system.
    cudaStatus = cudaSetDevice(0);
    if (cudaStatus != cudaSuccess)
	{
        fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
		return;
	}

	cudaMalloc((void**)&dev_width,sizeof(int));
	cudaMalloc((void**)&dev_height,sizeof(int));

	cudaMalloc((void**)&dev_first_state,sizeof(float)*width*height);
	cudaMalloc((void**)&dev_second_state,sizeof(float)*width*height);
}
// runs cuda device and returns result
void RunCudaDevice()
{
	cudaError_t cudaStatus;

	int threads = NUMBER_OF_THREADS;
	int blocks = (width*height)/(NUMBER_OF_THREADS + 1);
	
	kernel <<<threads,blocks>>> (dev_first_state,dev_second_state,dev_width,dev_height);
//	kernel <<<10,10>>> (dev_first_state,dev_second_state,dev_width,dev_height);

	cudaDeviceSynchronize();

	// cudaDeviceSynchronize waits for the kernel to finish, and returns
    // any errors encountered during the launch.
    cudaStatus = cudaDeviceSynchronize();
    if (cudaStatus != cudaSuccess)
	{
        fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching addKernel!\n", cudaStatus);
		return;
	}

	GetDataFromCudaDevice(FIELD_WIDTH,FIELD_HEIGHT);
}

void FreeCudaDevice(int width, int height)
{
	cudaFree(dev_first_state);
	cudaFree(dev_second_state);
	
	cudaFree(dev_width);
	cudaFree(dev_height);
}

void FillField()
{
	/*
	 *	
	 *	01010
	 *	00110
	 *	00100
	 *	00000
	 *	
	 */
	
//	state_first[9*width+9] = 1;

	state_first[2*width+5] = 1;
	state_first[2*width+6] = 1;
	state_first[3*width+6] = 1;
	state_first[3*width+7] = 1;
	state_first[1*width+7] = 1;

/*
	state_first[7*width+1] = 1;
	state_first[7*width+2] = 1;
	state_first[8*width+2] = 1;
	state_first[8*width+3] = 1;
	state_first[6*width+3] = 1;
*/
/*
	state_first[7*width+7] = 1;
	state_first[7*width+8] = 1;
	state_first[8*width+7] = 1;
	state_first[8*width+8] = 1;
*/
}
// allocate memory and initialize array with '0'
void InitArrays(int width, int height)
{
	state_first = (float *) malloc(sizeof(float)*width*height);
	state_second = (float *) malloc(sizeof(float)*width*height);
	
	memset(state_first,0,sizeof(float)*width*height);
	memset(state_second,0,sizeof(float)*width*height);
}

void ShowArray(int width, int height)
{
	puts("-----------------");
	for(int i=0;i<width;i++)
	{
		for(int j=0;j<height;j++)
		{
			if(state_first[i*width+j] != 0)printf("*");
			else printf(" ");
		//	printf("%1.0f",state_first[i*width+j]);
		}
		printf("\n");
	}
	puts("-----------------");
}

void CudaSwapArrays()
{
	float * t = dev_first_state;
	dev_first_state = dev_second_state;
	dev_second_state = t;
	
//	cudaMemset(dev_second_state,0,sizeof(float)*width*height); //checking
}

void InitializwFreeGlut()
{
	// Initialize freeglut
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_SINGLE | GLUT_RGBA);
	glutInitWindowSize(width, height);
	glutCreateWindow("Life");
	glutDisplayFunc(draw);
	glutKeyboardFunc(key);
	glutSetOption(GLUT_ACTION_ON_WINDOW_CLOSE, GLUT_ACTION_CONTINUE_EXECUTION);
}

void init_colors()
{
	color1.x = 127;
	color1.y = 255;
	color1.z = 0;
	color1.w = 0;

	color2.x = 255;
	color2.y = 255;
	color2.z = 255;
	color2.w = 255;
}

int main()
{
	InitArrays(FIELD_WIDTH,FIELD_HEIGHT);
	
	FillField();
	
	ShowArray(FIELD_WIDTH,FIELD_HEIGHT);
	
	InitCudaArrays(FIELD_WIDTH,FIELD_HEIGHT);
	CopyDataToCudaDevice(FIELD_WIDTH,FIELD_HEIGHT);
	
	RunCudaDevice();
	ShowArray(FIELD_WIDTH,FIELD_HEIGHT);
	
	for(int i=0;i<30;i++)
	{
		CudaSwapArrays();
		RunCudaDevice();
		ShowArray(FIELD_WIDTH,FIELD_HEIGHT);
	}
	
	FreeCudaDevice(FIELD_WIDTH,FIELD_HEIGHT);
	
	ShowArray(FIELD_WIDTH,FIELD_HEIGHT);

//	char ch;
//	scanf("%c",&ch);
}

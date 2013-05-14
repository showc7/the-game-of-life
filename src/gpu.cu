#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>

#include "gpu.h"

__global__ void transfer_kernel(float * first, float * second , int * width, int * height)
{
	int id = threadIdx.x + blockIdx.x * blockDim.x;
	
	*(second + id) = 0;

	if(id <= (*width)*(*height))
	{
		int num = 0;
		
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

void GetDataFromCudaDevice(float * state_first, float * dev_second_state, int width, int height)
{
	#ifdef DEBUG
		puts("GetDataFromCudaDevice");
	#endif
	cudaMemcpy(state_first,dev_second_state,sizeof(float)*width*height,cudaMemcpyDeviceToHost);
}

void CopyDataToCudaDevice(float * dev_first_state, float * dev_second_state, float * state_first, int * dev_width, int * dev_height, int width, int height)
{
	#ifdef DEBUG
		puts("CopyDataToCudaDevice");
	#endif
	cudaMemcpy(dev_first_state,state_first,sizeof(float)*width*height,cudaMemcpyHostToDevice);
	cudaMemset(dev_second_state,0,sizeof(float)*width*height);
	
	cudaMemcpy(dev_width,&width,sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_height,&height,sizeof(int),cudaMemcpyHostToDevice);
}

int InitCudaArrays(float ** dev_first_state, float ** dev_second_state, int ** dev_width, int ** dev_height, int width, int height)
{
	#ifdef DEBUG
		puts("InitCudaArrays");
	#endif
	cudaError_t cudaStatus;

	// Choose which GPU to run on, change this on a multi-GPU system.
    cudaStatus = cudaSetDevice(0);
    if (cudaStatus != cudaSuccess)
	{
        fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
		return 1;
	}

	cudaMalloc((void**)&*dev_width,sizeof(int));
	cudaMalloc((void**)&*dev_height,sizeof(int));

	cudaMalloc((void**)&*dev_first_state,sizeof(float)*width*height);
	cudaMalloc((void**)&*dev_second_state,sizeof(float)*width*height);
	
	return 0;
}

void RunCudaDevice(int threads, int blocks, float * dev_first_state, float * dev_second_state, int * dev_width, int * dev_height, int width, int height)
{
	#ifdef DEBUG
		puts("RunCudaDevice");
	#endif
	cudaError_t cudaStatus;

//	int threads = NUMBER_OF_THREADS;
//	int blocks = (width*height)/(NUMBER_OF_THREADS + 1);
	
	transfer_kernel <<<threads,blocks>>> (dev_first_state,dev_second_state,dev_width,dev_height);

	cudaDeviceSynchronize();

	// cudaDeviceSynchronize waits for the kernel to finish, and returns
    // any errors encountered during the launch.
    cudaStatus = cudaDeviceSynchronize();
    if (cudaStatus != cudaSuccess)
	{
        fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching addKernel!\n", cudaStatus);
		return;
	}

//	GetDataFromCudaDevice(width,height);
}
void FreeCudaDevice(float * dev_first_state, float * dev_second_state, int * dev_width, int * dev_height, int width, int height)
{
	cudaFree(dev_first_state);
	cudaFree(dev_second_state);
	
	cudaFree(dev_width);
	cudaFree(dev_height);
}

void CudaSwapArrays(float ** dev_first_state, float ** dev_second_state)
{
	#ifdef DEBUG
		puts("CudaSwapArrays");
	#endif
	float * t = *dev_first_state;
	*dev_first_state = *dev_second_state;
	*dev_second_state = t;
}


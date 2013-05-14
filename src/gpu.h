#ifndef GPU_H
#define GPU_H

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include "gpu.h"

__global__ void transfer_kernel(float * first, float * second , int * width, int * height);
void GetDataFromCudaDevice(float * state_first, float * dev_second_state, int width, int height);
void CopyDataToCudaDevice(float * dev_first_state, float * dev_second_state, float * state_first, int * dev_width, int * dev_height, int width, int height);
int InitCudaArrays(float ** dev_first_state, float ** dev_second_state, int ** dev_width, int ** dev_height, int width, int height);
void RunCudaDevice(int threads, int blocks, float * dev_first_state, float * dev_second_state, int * dev_width, int * dev_height, int width, int height);
void FreeCudaDevice(float * dev_first_state, float * dev_second_state, int * dev_width, int * dev_height, int width, int height);
void CudaSwapArrays(float ** dev_first_state, float ** dev_second_state);

#endif

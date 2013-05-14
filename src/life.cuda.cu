/*
 *
 * compiling:
 * nvcc -lglut -LGLEW life.cuda.cu -o life
 * 
 * for it's work:
 * export LD_LIBRARY_PATH=:/usr/local/cuda/lib
 * export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/libnvvp/
 * 
 * cuda-gdb
 */

#include <stdio.h>

#define uchar unsigned char
#define NUMBER_OF_THREADS	512

uchar * dev_array1;
uchar * dev_array2;

uint * dev_size_x;
uint * dev_size_y;

uint sizeX,sizeY;

// bad -> fix it

__global__ void kernel2(float * field1, float * field2, uchar4 * screen, int sizex, int sizey)
{
//	int id = threadIdx.x + blockIdx.x*blockDim.x + threadIdx.y + blockIdx.y*blockDim.y;
	int id = threadIdx.x+threadIdx.y;
	
	int numberofneighbours=0;

	numberofneighbours += *(field1 + id + 1);
	numberofneighbours += *(field1 + id - 1);
	numberofneighbours += *(field1 + id + sizey);
	numberofneighbours += *(field1 + id - sizey);
	numberofneighbours += *(field1 + id + sizey + 1);
	numberofneighbours += *(field1 + id + sizey - 1);
	numberofneighbours += *(field1 + id - sizey - 1);
	numberofneighbours += *(field1 + id + sizey + 1);
	
//	(screen + id)->x = numberofneighbours;
//	(screen + id)->x = 1;
//	*(field2 + id) = 1;
//	if(*(field1 + id) == 1) *(field2 + id) = 1;
	/*
	switch(numberofneighbours)
	{
		case 3 :	*(field2 + id) = 1;
					(screen + id)->x = 0;
					(screen + id)->y = 250;
					(screen + id)->z = 0;
					(screen + id)->w = 0;
				break;
				
		case 2 :	if(*(field1 + id) == 1)
					{
						*(field2 + id) = 1;
						(screen + id)->x = 0;
						(screen + id)->y = 250;
						(screen + id)->z = 0;
						(screen + id)->w = 0;
					}
					else
					{
						*(field2 + id) = 0;
						(screen + id)->x = 0;
						(screen + id)->y = 0;
						(screen + id)->z = 0;
						(screen + id)->w = 0;
					}
				break;
				
		default :	*(field2 + id) = 0;
					(screen + id)->x = 0;
					(screen + id)->y = 0;
					(screen + id)->z = 0;
					(screen + id)->w = 0;
				break;
	}
	*/
}

__global__ void kernel(uchar * array1, uchar * array2, uint size_x, uint size_y)
{
//	int id = threadIdx.x*blockIdx.x+blockDim.x + threadIdx.y*blockIdx.y+blockDim.y;
	int id = threadIdx.x+threadIdx.y;
	
	if(id < size_x*size_y)
	{
		int numberofneighbours=0;
		
		int num = 0;
		
		// заменить на num += ...
		
		if(*(array1 + id + 1) == 1) num++;
		if(*(array1 + id - 1) == 1) num++;
		if(*(array1 + id + size_y) == 1) num++;
		if(*(array1 + id - size_y) == 1) num++;
		if(*(array1 + id + size_y + 1) == 1) num++;
		if(*(array1 + id + size_y - 1) == 1) num++;
		if(*(array1 + id - size_y + 1) == 1) num++;
		if(*(array1 + id - size_y - 1) == 1) num++;
		
		switch(num)
		{
			case 3 : *(array2 + id) = 1; break;
			case 2 : if(*(array1 + id) == 1) *(array2 + id) = 1; break;
			default : *(array2 + id) = 0; break;
		}
		
	}
}

void initCuda(uchar * array1, uchar * array2, uint size_x, uint size_y)
{
	sizeX = size_x;
	sizeY = size_y;
	
	cudaMalloc((void**)&dev_array1,sizeof(uchar)*size_x*size_y);
	cudaMalloc((void**)&dev_array2,sizeof(uchar)*size_x*size_y);
	
	cudaMalloc((void**)&dev_size_x,sizeof(uint));
	cudaMalloc((void**)&dev_size_y,sizeof(uint));
	
	cudaMemcpy(dev_array1,array1,sizeof(uchar)*size_x*size_y,cudaMemcpyHostToDevice);
	
	cudaMemcpy(dev_size_x,&size_x,sizeof(uchar),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_size_y,&size_y,sizeof(uchar),cudaMemcpyHostToDevice);
	
	cudaMemset(dev_array2,0,size_x*size_y);
}

void get_result(uchar * array)
{
	cudaMemcpy(array,dev_array2,sizeX*sizeY*sizeof(uchar),cudaMemcpyDeviceToHost);
}

void cuda_run()
{
	int threads = NUMBER_OF_THREADS;
	int blocks = sizeX*sizeY/threads+1;
	
//	kernel <<<blocks,threads>>>(dev_array1,dev_array2,dev_size_x,dev_size_y);
	kernel <<<blocks,threads>>>(dev_array1,dev_array2,sizeX,sizeY);
}

void FreeCuda()
{
	cudaFree(dev_array1);
	cudaFree(dev_array2);
	cudaFree(dev_size_x);
	cudaFree(dev_size_y);
}

void check(uchar * array1, uchar * array2, uint * size_x, uint * size_y)
{
	int num=0;
	puts("<=================>\n");
	
	printf("%u %u\n",*size_x,*size_y);
	
	puts("<=================>\n");
	
	for(int i=0;i<(*size_x * (*size_y));i++)
	{
		num = 0;
		
		if(*(array1 + i + 1) == 1) num++;
		if(*(array1 + i - 1) == 1) num++;
		if(*(array1 + i + *size_y) == 1) num++;
		if(*(array1 + i - *size_y) == 1) num++;
		if(*(array1 + i + *size_y + 1) == 1) num++;
		if(*(array1 + i + *size_y - 1) == 1) num++;
		if(*(array1 + i - *size_y + 1) == 1) num++;
		if(*(array1 + i - *size_y - 1) == 1) num++;
		
	//	*(array2 + i) = num;
		
		switch(num)
		{
			case 3 : *(array2 + i) = 1; break;
			case 2 : if(*(array1 + i) == 1) *(array2 + i) = 1; break;
			default : *(array2 + i) = 0; break;
		}
		
	}
	
	puts("<=================>\n");
}

#define cell_size 5
#define uchar unsigned char
#define screen_width 20
#define screen_height 20

int width = screen_width*cell_size; //770; //1024;
int height = screen_width*cell_size; //770; //768;
/*
int main()
{
//	uchar field1[screen_width][screen_height];
//	uchar field2[screen_width][screen_height];

	uchar field1[screen_width*screen_height];
	uchar field2[screen_width*screen_height];

	for(int i=0;i<screen_width;i++)
	{
		for(int j=0;j<screen_height;j++)
		{
			field1[i+j*screen_width] = 0;
			field2[i+j*screen_width] = 0;
		}
	}

	field1[0+0*screen_width] = 1;
	field1[0+1*screen_width] = 1;
	field1[0+2*screen_width] = 1;
//	field1[1][0] = 1;
	field1[1+1*screen_width] = 1;
	field1[3+3*screen_width] = 1;
	field1[4+3*screen_width] = 1;
	field1[10+5*screen_width] = 1;
	field1[10+6*screen_width] = 1;
	field1[11+5*screen_width] = 1;
	field1[11+6*screen_width] = 1;
//	field1[10][7] = 1;
	
	for(int i=0;i<screen_width;i++)
	{
		for(int j=0;j<screen_height;j++)
		{
			if(field1[i+j*screen_width] == 1) printf("*");
			else printf(".");
		//	printf("%c ",field1[i][j]);
		}
		printf("\n");
	}

	sizeX = 20;
	sizeY = 20;

//=======================================================================
/*
	check(field1,field2,&sizeX,&sizeY);

	for(int i=0;i<screen_width;i++)
	{
		for(int j=0;j<screen_height;j++)
		{
			if(field2[i+j*screen_width] == 1) printf("*");
			else printf("%i",(int) field2[i+j*screen_width]);
		//	printf("%c ",field2[i][j]);
		}
		printf("\n");
	}
*/
//=======================================================================
/*
	initCuda(&field1[0],&field2[0],screen_width,screen_height);
	cuda_run();
	get_result(&field2[0]);

	puts("\n<==========>\n\n");

	for(int i=0;i<screen_width;i++)
	{
		for(int j=0;j<screen_height;j++)
		{
			if(field2[i+j*screen_width] == 1) printf("*");
			else printf("%i",(int) field2[i+j*screen_width]);
		//	printf("%c ",field2[i][j]);
		}
		printf("\n");
	}

	FreeCuda();

	return 0;
}
*/
int main()
{
	float * field1;
	field1 = (float *) malloc(sizeof(float)*screen_width*screen_height);
	uchar4 * screen;
	screen = (uchar4 *) malloc(sizeof(uchar4)*screen_width*screen_height);
	
	float * dev_field1;
	float * dev_field2;
	uchar4 * dev_screen;
	
	*(field1 + 10) = 1;
	field1[40] = 1;
	field1[41] = 1;
	field1[59] = 1;
	field1[60] = 1;
	
	field1[90] = 1;
	field1[91] = 1;
	field1[92] = 1;
	
	for(int i=0;i<=400;i++)
	{
		printf("%i",(int) *(field1+i));
		if(i % 19 == 0) printf("\n");
	}
	printf("\n");
	cudaMalloc((void **)&dev_field1,sizeof(float)*screen_width*screen_height);
	cudaMalloc((void **)&dev_field2,sizeof(float)*screen_width*screen_height);
	cudaMalloc((void **)&dev_screen,sizeof(uchar4)*screen_width*screen_height);
	
	cudaMemcpy(dev_field1,field1,sizeof(uchar4)*screen_width*screen_height,cudaMemcpyHostToDevice);
	
	cudaMemset(dev_field2,8,sizeof(float)*screen_width*screen_height);
	
	kernel2<<<10 , 10>>>(dev_field1,dev_field2,dev_screen,20,20);
	
	float * field2;
	field2 = (float *) malloc(sizeof(float)*screen_width*screen_height);
	
	cudaMemcpy(field2,dev_field2,sizeof(float)*screen_width*screen_height,cudaMemcpyDeviceToHost);
	
	cudaMemcpy(screen,dev_screen,sizeof(uchar4)*screen_width*screen_height,cudaMemcpyDeviceToHost);
	
	cudaFree(dev_field1);
	cudaFree(dev_field2);
	cudaFree(dev_screen);
	
	for(int i=0;i<400;i++)
	{
		printf("%i",(int) (screen+i)->x);
		if(i % 19 == 0) printf("\n");
	}
	printf("\n");
	
	for(int i=0;i<400;i++)
	{
		printf("%4i",(int) *(field2+i));
		if(i % 19 == 0) printf("\n");
	}
	printf("\n");
	
	free(field1);
	free(field2);
	free(screen);
}

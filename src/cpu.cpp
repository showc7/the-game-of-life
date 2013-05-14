#include "cpu.h"

void transfer_cpu(int * first, int * second, int width, int height)
{
	for(int i=0;i<width*height;i++)
	{
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

void CPUInitArrays(int ** first, int ** second, int width, int height)
{
	*first = (int *) malloc(sizeof(int) * width * height);
	*second = (int *) malloc(sizeof(int) * width * height);
}

void SwapCPUArrays(int ** first, int ** second)
{
	int * temp = *first;
	*first = *second;
	*second = temp;
}

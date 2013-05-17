#include "cpu.h"

void transfer_cpu(int * first, int * second, int width, int height)
{
	for(int i=0;i<width*height;i++)
	{
		/*
		num += *(first + id + 1);
		num += *(first + id - 1);
		num += *(first + id + *height);
		num += *(first + id - *height);
		num += *(first + id + *height + 1);
		num += *(first + id + *height - 1);
		num += *(first + id - *height + 1);
		num += *(first + id - *height - 1);
		*/
		if(i+1 < screen_width && field1[i+1][j] == 1) num++;
		if(i-1 >= 0 && field1[i-1][j] == 1) num++;
		if(j+1 < screen_height && field1[i][j+1] == 1) num++;
		if(j-1 >= 0 && field1[i][j-1] == 1) num++;
		if(i+1 < screen_width && j+1 < screen_height && field1[i+1][j+1] == 1) num++;
		if(i-1 > 0 && j+1 < screen_height && field1[i-1][j+1] == 1) num++;
		if(i+1 < screen_width && j-1 > 0 && field1[i+1][j-1] == 1) num++;
		if(i-1 > 0 && j-1 > 0 && field1[i-1][j-1] == 1) num++;
		
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

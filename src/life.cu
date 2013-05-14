/*
 *	THE GAME OF LIFE
 */


/*
 *
 * compiling:
 * nvcc -lglut -LGLEW life.cu -o life
 * 
 * for it's work:
 * export LD_LIBRARY_PATH=:/usr/local/cuda/lib
 * export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/libnvvp/
 *
 * cuda-gdb
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <GL/freeglut.h>
#include <GL/gl.h>
#include <GL/glext.h>
#include <time.h>
#include <fstream>

#define cell_size 5
#define uchar unsigned char
#define screen_width 150
#define screen_height 150

int width = screen_width*cell_size; //770; //1024;
int height = screen_width*cell_size; //770; //768;

uchar4 * screen = NULL;
uchar field1[screen_width][screen_height];
uchar field2[screen_width][screen_height];

uchar4 color1,color2;

void draw(void)
{
	glClearColor(0.0, 0.0, 0.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT);
	glDrawPixels(width, height, GL_RGBA, GL_UNSIGNED_BYTE, screen);
	glFlush();
}

void draw_cube(int x, int y, int a, uchar4 color)
{
	for(int i=0;i<a;i++)
		for(int j=0;j<a;j++)
		{
			screen[(x+j)*width+y+i] = color;
		}
}

void draw_field()
{
	for(int i=0;i<screen_width;i++)
		for(int j=0;j<screen_height;j++)
		{
			if(field1[i][j] == 1)
				draw_cube(i*cell_size,j*cell_size,cell_size,color1);
			if(field1[i][j] == 0)
				draw_cube(i*cell_size,j*cell_size,cell_size,color2);
		}
}

void transfer_cpu()
{
	int num=0;
	
	for(int i=0;i<screen_width;i++)
		for(int j=0;j<screen_height;j++)
		{
			num = 0;
			
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
				case 3 : field2[i][j] = 1; break;
				case 2 : if(field1[i][j] == 1) field2[i][j] = 1; break;
				default : field2[i][j] = 0; break;
			}
		}
	
	for(int i=0;i<screen_width;i++)
		for(int j=0;j<screen_height;j++)
			field1[i][j] = field2[i][j];
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

void init_screen()
{
	screen = (uchar4 *) malloc(width * height * sizeof(uchar4));
	memset(screen, 0, width * height * sizeof(uchar4));
}

void field_to_zero(uchar * field)
{
	memset(field,0,height/cell_size*width/cell_size);
}

void gen()
{
	field1[0][0] = 1;
	field1[0][1] = 1;
	field1[0][2] = 1;
	
	field1[100][10] = 1;
	field1[100][11] = 1;
	field1[100][12] = 1;
	
	field1[7][10] = 1;
	field1[8][9] = 1;
	field1[8][8] = 1;
	field1[9][9] = 1;
	field1[9][10] = 1;
	
	
	field1[4][1] = 1;
	field1[2][2] = 1;
	field1[3][2] = 1;
	field1[3][3] = 1;
	field1[4][3] = 1;
	
	field1[40][10] = 1;
	field1[38][11] = 1;
	field1[39][11] = 1;
	field1[39][12] = 1;
	field1[40][12] = 1;
	
	field1[70][90] = 1;
	field1[70][91] = 1;
	field1[70][92] = 1;
	field1[69][89] = 1;
	field1[69][90] = 1;
	field1[69][91] = 1;
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

int main(int argc, char** argv)
{
	// Initialize freeglut
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_SINGLE | GLUT_RGBA);
	glutInitWindowSize(width, height);
	glutCreateWindow("Life");
	glutDisplayFunc(draw);
	glutKeyboardFunc(key);
	glutSetOption(GLUT_ACTION_ON_WINDOW_CLOSE, GLUT_ACTION_CONTINUE_EXECUTION);

	init_screen();
	
	// Initialization of colors
	init_colors();
	
	// Start of the program
	start();
	
	// Display Image
	glutMainLoop();

	// Free resources
	free(screen);
	screen = NULL;

	return 0;
}

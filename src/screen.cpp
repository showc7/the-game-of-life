#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

#include <GL/freeglut.h>
#include <GL/gl.h>
#include <GL/glext.h>
#include <GL/glut.h>
#include <time.h>
#include <fstream>

#include "screen.h"

#define CUBE_LEN	5
#define R			0
#define G			255
#define B			0
#define W			0

typedef struct uchar4
{
	unsigned char x,y,z,w;
}uchar4;

int width, height;
uchar4 * screen = NULL;

void uchar4_cpy(uchar4 * dest, const uchar4 * source)
{
	dest->x = source->x;
	dest->y = source->y;
	dest->z = source->z;
	dest->w = source->w;
}

void draw_cube(int pos, int len, uchar4 color)
{
	#ifdef DEBUG
		puts("draw_cube");
	#endif
	pos *= 5;
	for(int i=0;i<len;i++)
		uchar4_cpy(&screen[pos + i],&color);
}

void draw_screen(float * field, int field_width, int field_height)
{
	#ifdef DEBUG
		puts("draw_screen");
	#endif
	uchar4 color_f = {0,255,0,0};
	uchar4 color_b = {0,0,0,0};
	
	for(int i=0;i<field_width*field_height;i++)
	{
		#ifdef DEBUG
			printf(",");
		#endif
		if(field[i] == 0) draw_cube(i,CUBE_LEN,color_b);
		else draw_cube(i,CUBE_LEN,color_f);
		printf(",");
	}
	printf("\n");
	/*
	for(int i=0;i<width;i++)
		for(int j=0;j<height;j++)
		{
			screen[j*width+i].x  = color.x;
			screen[j*width+i].y  = color.y;
			screen[j*width+i].z  = color.z;
			screen[j*width+i].w  = color.w;
			/*
			screen[(j*width+i)*3+0] = 255;
  			screen[(j*width+i)*3+1] = 0;
  			screen[(j*width+i)*3+2] = 0;
  			screen[(j*width+i)*3+3] = 0;
  			*/
//		}
}

void draw()
{
	#ifdef DEBUG
		puts("draw");
	#endif
	glClearColor(0.0, 0.0, 0.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT);
	glDrawPixels(width, height, GL_RGBA, GL_UNSIGNED_BYTE, screen);
//	glFlush();
	
	// in double buffer mode so we swap to avoid a flicker
	glutSwapBuffers();

	// instruct event system to call 'drawfunc' again
	glutPostRedisplay();
}
/*
void draw_cube(int x, int y, int a, uchar4 color)
{
	for(int i=0;i<a;i++)
		for(int j=0;j<a;j++)
			screen[(x+j)*width+y+i] = color;
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
*/
void key(unsigned char key, int x, int y)
{
	#ifdef DEBUG
		puts("key");
	#endif
	switch(key)
	{
		case 27:
			puts("handled escape\nExit application");
			glutLeaveMainLoop();
			break;
		default:
			puts("unknown key");
			break;
	}
	draw();
}
/*
void start()
{
	gen();
	draw_field();
	
	timer();
	
	glutMainLoop();
}
*/

void SetSettings()
{
	#ifdef DEBUG
		puts("SetSettings");
	#endif
	width = 700;
	height = 700;
	screen = (uchar4 *) malloc(sizeof(uchar4) * width * height);
	memset(screen,50,sizeof(uchar4) * width * height);
}

void SetSettings(int _width, int _height)
{
	#ifdef DEBUG
		puts("SetSettings(params)");
	#endif
	width = _width;
	height = _height;
	screen = (uchar4 *) malloc(sizeof(uchar4) * width * height);
	memset(screen,0,sizeof(uchar4) * width * height);
}

void InitializeFreeGlut(int argc, char ** argv, int width, int height)
{
	#ifdef DEBUG
		puts("InitializeFreeGlut");
	#endif
	// Initialize freeglut
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_SINGLE | GLUT_RGBA);
//	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB);
	glutInitWindowSize(width, height);
	glutCreateWindow("Life");
	glutDisplayFunc(draw);
	glutKeyboardFunc(key);
	glutSetOption(GLUT_ACTION_ON_WINDOW_CLOSE, GLUT_ACTION_CONTINUE_EXECUTION);
}

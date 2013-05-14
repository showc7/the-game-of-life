#ifndef SCREEN_H
#define SCREEN_H

void InitializeFreeGlut(int argc, char ** argv, int width, int height);
void draw();
void key(unsigned char key, int x, int y);
void SetSettings();
void SetSettings(int _width, int _height);
void draw_screen(float * field, int field_width, int field_height);

#endif

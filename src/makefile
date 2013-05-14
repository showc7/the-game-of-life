DEBUG=

all: objects

objects: screen gpu main
	nvcc $(DEBUG) -lglut -LGLEW main.cpp gpu.o screen.o -o bin/program
#	nvcc $(DEBUG) -lglut -LGLEW main.o gpu.o screen.o

main: exports mkdirs main.cpp
	nvcc $(DEBUG) -c -lglut -LGLEW main.cpp -o main.o

screen: exports mkdirs screen.cpp screen.h
	nvcc $(DEBUG) -c -lglut -LGLEW screen.cpp -o screen.o

gpu: exports mkdirs gpu.cu gpu.h
	nvcc $(DEBUG) -c gpu.cu -o gpu.o

exports: mkdirs mkdirs
	export LD_LIBRARY_PATH=:/usr/local/cuda/lib
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/libnvvp/

mkdirs:
	mkdir -p bin

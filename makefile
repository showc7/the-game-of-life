all:	target

target:	exports
	nvcc -lglut -LGLEW src/life.cu -o bin/life

cuda:	exports
	nvcc src/life.cuda.cu -o bin/lf

check: exports
	nvcc -g -G src/check.cuda.cu -o bin/check

remove:
	rm -f bin/life

exports: mkdirs
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/libnvvp/
	export LD_LIBRARY_PATH=:/usr/local/cuda/lib

mkdirs:
	mkdir -p bin

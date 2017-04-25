#! /bin/bash -f
docker run -v $HOME:/home/app/work/home -p 8888:8888 -p 4005:4005 --rm -it drmeister/cando

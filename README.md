# docker-studio-petclinic

## To build:
```
docker build -t graphwalker/studio-petclinic .
```


## To run:
```
docker pull graphwalker/studio-petclinic
docker run -ti --rm -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/.Xauthority:/home/developer/.Xauthority --net=host --pid=host --ipc=host graphwalker/studio-petclinic
```

# PHP 8.0 Docker Image


### Description

A pre-build Docker image and compose file for running PHP 8.0 FPM

### Docker

1. [Install Docker](https://docs.docker.com/v17.09/engine/installation/#supported-platforms)
2. Run the following commands to build and run the container, as there's a lot of installation candidates, this process can take some time

```bash
docker build -t php80 .
docker run -d -p {{ LOCAL_PORT_TO_USE }}:80 -it --rm --name php-80 php80
```
Now navigate to localhost:{{ LOCAL_PORT_TO_USE }}

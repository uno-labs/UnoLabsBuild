# UnoLabsBuild
Build scripts


Install docker and start next image:

 docker run --name unolabs_build -it -v /storage/Docker/unolabs_build:/storage/ ubuntu:20.04 /bin/bash
 
 Where '/storage/Docker/unolabs_build' path to you host output directory
 
 Into the docker:
 
 apt-get update && apt-get install wget -y
 cd /storage/
 wget https://raw.githubusercontent.com/uno-labs/UnoLabsBuild/dev/build_all.sh
 chmod +x ./build_all.sh
 ./build_all.sh
 
 
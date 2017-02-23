# Xorg+Docker+GLX+NVIDIA+postAtom

Attention: Do not start this on your Host with running Xorg. 

Build with 

docker build -t postatom .

and run

docker run --privileged -p 10000:10000 postatom

Connect with Xpra Client 

XPRA_PASSWORD=heimgeh1 xpra attach tcp:YourDockerHost:10000 --username=testing



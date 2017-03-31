# Docker+Xorg(incl. openGL)+NVIDIA+XPRA+postAtom

Attention: Do not start this on your Host with running Xorg. 

Build with 

docker build -t postatom .

and run e.g.
```sh
docker run --device=/dev/nvidiactl --device=/dev/nvidia-uvm --device=/dev/nvidia7 --device=/dev/tty60 -p 10050:10050 -e XPRA_PASSWORD=Nextpass -e USERNAME=testing -h postatom-docker postatom
```
possible vars:
XPRA_PASSWORD, xpra password
USERNAME, username for running xpra in linux system
XPRAPORT, xpra port number
SCREEN_RESULTION, resolution for virtual screen, default 4096x2160 (4k)

You have to use a free tty where Xorg can run on. 

Connect with Xpra Client 

```sh
XPRA_PASSWORD=Nextpass xpra attach ssl:HOSTNAME:10050 --ssl-server-verify-mode=none
```
The switch --ssl-server-verify-mode=none is necessary, because we used a self signed Cert.

If there is no nvenc encoding, visulization gives the best results with --encoding=jpeg

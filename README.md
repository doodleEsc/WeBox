# WeBox

## Build
binary: https://drive.google.com/file/d/1Vg2pCBuDwvEdxvP6xVUhTF5a4usGKm03/view

```shell
git clone https://github.com/doodleEsc/WeBox.git
cd WeBox
cp path/to/WeBox.tar.gz ./
tar zxvf WeBox.tar.gz
sudo docker build -t wine:0.1 -f Dockerfile_wine .
sudo docker build --build-arg root_password={YOUR_ROOT_PASSWORD} -t webox:0.1 .

```
## RUN

```shell
sudo docker run --name webox -d -p 5905:5905 -v path/to/app:/root/app -e VNCPASS={YOUR_VNC_PASSWORD} webox:0.1

```

Modify program parameters
```
sudo docker run --name webox -d -p 5905:5905 -v path/to/app:/root/app -e VNCPASS={YOUR_VNC_PASSWORD} -e CALLBACK="callBackUrl=http://127.0.0.1:9528/wxbot/callback\&port=9527\&decryptImg=1" webox:0.1

```

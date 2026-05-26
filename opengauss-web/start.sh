export CANGJIE_STDX_PATH=$(pwd)/cangjie-stdx-linux-x64-1.1.0.1/linux_x86_64_cjnative/dynamic/stdx
export LD_LIBRARY_PATH=$CANGJIE_STDX_PATH:$LD_LIBRARY_PATH
sudo docker-compose up -d
cjpm run

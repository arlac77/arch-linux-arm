
export GOPATH=~/go
export PATH=$PATH:~/go/bin

mkdir -p $GOPATH

WD=$GOPATH/src/github.com/hashicorp/consul
mkdir -p $WD

(
 cd $WD
 git clone https://github.com/hashicorp/consul.git .
 make
)

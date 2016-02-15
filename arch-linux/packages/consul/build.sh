#!/usr/bin/env bash

rm -rf consul.*tar*pkg src custom.db.tar.gz

makepkg -f

REPO=mfelten_de@mfelten.de:/home/mfelten_de/docroot/arch-linux/packages

scp $REPO/custom.db.tar.gz . 
repo-add custom.db.tar.gz *.xz
scp *.xz custom.db* $REPO 



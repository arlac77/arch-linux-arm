pacman -Syu
pacman -S btrfs-progs
pacman -S git
pacman -S llvm
pacman -S clang
pacman -S nodejs
pacman -S mercurial
pacman -U mercurial-3.3.2-1-armv7h.pkg.tar.xz

pacman -S go

cat <EOF >>/etc/ssh/sshd_config
PermitRootLogin yes
PubkeyAcceptedKeyTypes +ssh-dss
EOF

cat <EOF >>/etc/ssh/ssh_config
PubkeyAcceptedKeyTypes +ssh-dss
EOF

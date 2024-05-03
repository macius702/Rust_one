#!/bin/bash
source ~/.bashrc
whereis dfx
echo $PATH
/home/Matiki/.local/share/dfx/bin/dfx start --background --clean --host 0.0.0.0:4943
cd d
/home/Matiki/.local/share/dfx/bin/dfx deploy
/bin/bash
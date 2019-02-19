#!/bin/bash
curr_dir=$(pwd)
mkdir -p ~/.vim/
if [ -e ~/.vim/youcompleteme ]
then
    cd "~/.vim/youcompleteme"
    git pull
    git submodule update --init --recursive
else
    cd ~/.vim/
    git clone https://github.com/Valloric/YouCompleteMe.git youcompleteme
    cd ./youcompleteme
    git submodule update --init --recursive
fi
cd ~/.vim/youcompleteme
chmod u+x ./install.py
python3 ./install.py --clang-completer --ts-completer
cd $curr_dir


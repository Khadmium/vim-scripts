#!/bin/bash
curr_dir=$(pwd)

PLUG_NAME="youcompleteme"
mkdir -p ~/.vim/
if [ -e "$HOME/.vim/$PLUG_NAME" ]
then
    cd "$HOME/.vim/$PLUG_NAME"
    git pull
    git submodule update --init --recursive
else
    cd "$HOME/.vim/"
    git clone https://github.com/Valloric/YouCompleteMe.git "$PLUG_NAME"
    cd "./$PLUG_NAME"
    git submodule update --init --recursive
fi
cd "$HOME/.vim/$PLUG_NAME"
chmod u+x ./install.py
python3 ./install.py "$@"
cd $curr_dir


#!/bin/bash
curr_dir=$(pwd)
PLUG_NAME="vim-go"
mkdir -p ~/.vim/
if [ -e "$HOME/.vim/$PLUG_NAME" ]
then
    cd "$HOME/.vim/$PLUG_NAME"
    git pull
    git submodule update --init --recursive
else
    cd "$HOME/.vim/"
    git clone https://github.com/fatih/vim-go.git "$PLUG_NAME"
    cd "./$PLUG_NAME"
    git submodule update --init --recursive
fi
cd $curr_dir



module PluginsList
    LIST = [
        "mileszs/ack.vim",
        "scrooloose/nerdtree",
        "majutsushi/tagbar",
        "vim-scripts/vcscommand.vim",
        # [ "valloric/youcompleteme", 'python3 ./install.py'],
        "sjl/badwolf",
        "vim-scripts/OmniCppComplete",
        "qpkorr/vim-bufkill",
        "mattn/emmet-vim",
        "tpope/vim-eunuch",
        "octol/vim-cpp-enhanced-highlight",
        "mxw/vim-jsx",
        "leafgarland/typescript-vim",
        "gustafj/vim-ttcn.git",
        "aklt/plantuml-syntax.git",
        "tpope/vim-abolish",
        "itchyny/lightline.vim",
        "w0rp/ale",
        "tpope/vim-commentary",
        # "tpope/vim-rbenv.git",
        # "tpope/vim-bundler.git",
        "Khadmium/vim-illuminate.git",
    ]
    DEV_LIST = [
        "h1mesuke/vim-unittest"
    ]
    user_dir = File.expand_path("~");
    UPLUGS_DIR = File.join(user_dir,".vim/uplugs")
    DEV_UPLUGS_DIR = File.join(user_dir, ".vim/dev_uplugs")
    REPO = "https://github.com/Khadmium/vim-scripts.git"
    GITHUB_PAGE = "https://github.com/"
    SRC_DIR = File.join(user_dir, "vim-scripts/")
end

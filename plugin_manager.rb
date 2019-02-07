#!/usr/bin/env ruby

require 'fileutils'
require './plugins_list'
require 'set'

def get_author_and_directory(item)
    current_item = item
    index = current_item.index('/')
    if index == -1
        return nil
    end
    fst = current_item[0...index]
    snd = current_item[index+1...current_item.length]
    snd_len = snd.length
    snd_part = ".git"
    snd_part_len = snd_part.length
    snd = snd[0...(snd_len - snd_part_len)] if snd.end_with?(snd_part)
    puts ">>>> plugin description: {author: " + fst + ", directory:  " + snd + " }"
    return fst, snd
end


def ensure_plugin_in_dir(args)
    url_part = args[:url_part]
    plugin_dir = args[:plugin_dir]
    curr_dir = Dir.pwd
    if Dir.exist?(plugin_dir)
        puts(">>>> updating plugin: " + url_part)
        install_non_existing_plugin(args)
    else
      puts(">>>> installing plugin: " + url_part)
      update_existing_plugin(args)
    end
    Dir.chdir(curr_dir)
end

def install_non_existing_plugin(args)
    additional = args[:additional]
    additional_exec_dir = args[:additional_exec_dir]
    plugin_dir = args[:plugin_dir]
    Dir.chdir(plugin_dir)
    system('git pull') or raise RuntimeError, "failed execute command: git pull"
    Dir.chdir(File.expand_path(additional_exec_dir)) if !additional_exec_dir.nil?
    if !additional.nil?
        system(additional) or raise RuntimeError, "failed additional command"
    end
end

def update_existing_plugin(args)
    directory = args[:directory]
    url_part = args[:url_part]
    additional = args[:additional]
    additional_exec_dir = args[:additional_exec_dir]
    plugin_dir = args[:plugin_dir]
    Dir.chdir(directory);
    system("git clone "+ PluginsList::GITHUB_PAGE + url_part)
    if !additional_exec_dir.nil?
        Dir.chdir(File.expand_path(additional_exec_dir))
    else
        Dir.chdir(plugin_dir)
    end
    if !additional.nil?
        system(additional_exec_dir) or raise RuntimeError, "failed additional command"
    end
end


def update_plugins(plugins_list, plugs_dir)
    plugs_dir_expanded = File.expand_path(plugs_dir)
    plugins_list.each do |item|
        args = {:directory => plugs_dir_expanded}
        if item.kind_of?(Array)
            raise RangeError, "no plugin name provided" if item.empty?
            plug_name = item[0]
            additional = item[1]
            exec_dir = item[2]
            _, directory = get_author_and_directory(plug_name);
            args[:plugin_name] = directory
            args[:url_part] = plug_name
            args[:plugin_dir] = File.join(plugs_dir_expanded, directory)
            if !additional.nil?
                args[:additional] = additional
                if !exec_dir.nil?
                    args[:additional_exec_dir] = FileUtils.expand_path(exec_dir)
                end
            end
        else
            _, directory = get_author_and_directory(item);
            args[:plugin_name] = directory
            args[:url_part] = item
            args[:plugin_dir] = File.join(plugs_dir_expanded, directory)
        end
        ensure_plugin_in_dir(args)
    end
end

$_vim_paths = {
    :autoload => File.expand_path("~/.vim/autoload"),
    :bundle => File.expand_path("~/.vim/bundle"),
    :pathogen => File.expand_path("~/.vim/autoload/pathogen.vim"),
    :neovim_config_dir => File.expand_path("~/.config/nvim/"),
    :neovim_config => File.expand_path("~/.config/nvim/init.vim"),
    :vimrc_path => File.expand_path("~/.vimrc")
}

def update_vimrc(uplugs_dir, dev_uplugs_dir, src_dir, repo)
    uplugs_dir_expanded = File.expand_path(uplugs_dir)
    dev_uplugs_dir_expanded = dev_uplugs_dir.nil? ? nil : File.expand_path(dev_uplugs_dir)
    FileUtils.mkdir_p($_vim_paths[:autoload])
    FileUtils.mkdir_p(uplugs_dir_expanded)
    FileUtils.mkdir_p(dev_uplugs_dir_expanded) if !dev_uplugs_dir_expanded.nil?
    FileUtils.mkdir_p($_vim_paths[:bundle])
    if File.exists?($_vim_paths[:neovim_config])
        File.delete($_vim_paths[:neovim_config])
    end
    result = system("curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim")
    result or raise RuntimeError, "Cannot download new pathogen version"
    src_dir_expanded = File.expand_path(src_dir)
    source_repo = File.join(src_dir_expanded, "vim-scripts");
    pwd = Dir.pwd
    if !Dir.exist?(source_repo)
        Dir.chdir(src_dir_expanded)
        system("git clone " + repo) or raise RuntimeError, "cannot clone reference vim-scripts repo"
    else
        Dir.chdir(source_repo)
        system("git pull") or raise RuntimeError, "cannot update reference vim-scripts repo"
    end
    vimrc_path = File.join(source_repo, ".vimrc")
    FileUtils.cp(vimrc_path, $_vim_paths[:vimrc_path])
    content_of_init = "set runtimepath^=~/.vim runtimepath+=~/.vim/after\n" +
                      "let &packpath = &runtimepath\n" +
                      "src_dir_expanded ~/.vimrc\n"
    FileUtils.mkdir_p($_vim_paths[:neovim_config_dir]);
    if !File.exists?($_vim_paths[:neovim_config])
        File.open($_vim_paths[:neovim_config], "w") do |file|
            file.write(content_of_init);
        end
    end
    Dir.chdir(pwd)
end

def remove_unlisted_plugins(plugs_list, plugs_dir)
    plugins_set = Set.new
    plugs_list.each do |item|
        dir = nil
        if item.kind_of?(Array)
            _, dir = get_author_and_directory(item[1])
            plugins_set.add(dir)

        else
            _, dir = get_author_and_directory(item)
        end
        puts '>>>> plugin to preserve: ' + dir
        plugins_set.add(dir)
    end
    Dir.foreach(File.expand_path(plugs_dir)) do |directory|
        next if directory == '.' || directory == '..'
        directory_path = File.join(plugs_dir, directory)
        next if !File.directory?(directory_path)
        next if plugins_set.member?(directory)
        puts ">>>> removing plugin: " + directory
        FileUtils.rm_rf(directory_path)
    end
end

def main
    src_dir = PluginsList::SRC_DIR
    dev_plugs_dir = PluginsList::DEV_UPLUGS_DIR
    plugins_list = PluginsList::LIST
    repo = PluginsList::REPO
    plugs_dir = PluginsList::UPLUGS_DIR
    update_vimrc(plugs_dir, $1 == "--use-dev" ? dev_plugs_dir : nil, src_dir, repo)
    update_plugins(plugins_list, plugs_dir)
    if $1 == "--use-dev"
        plugins_list = PluginsList::DEV_LIST
        plugs_dir = PluginsList::DEV_UPLUGS_DIR
        update_plugins(plugins_list, plugs_dir)
    else
        FileUtils.rm_rf(PluginsList::DEV_UPLUGS_DIR);
    end
    remove_unlisted_plugins(PluginsList::LIST, PluginsList::UPLUGS_DIR)
    if $1 == "--use-dev"
        remove_unlisted_plugins(PluginsList::DEV_LIST, PluginsList::DEV_UPLUGS_DIR)
    end
end

main if __FILE__ == $0

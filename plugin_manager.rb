#!/usr/bin/env ruby

require 'fileutils'
require 'plugins_list'

def get_author_and_directory(item)
    current_item = item
    index = current_item.index('/')
    if index == -1
        return Nil
    else
        fst = current_item[0..index]
        snd = current_item[index+1..current_item.length]
        return fst, snd
    end
end

def ensure_plugin_in_dir(args)
    directory = args[:directory]
    plugin_name = args[:plugin_name]
    url_part = args[:url_part]
    additional = args[:additional]
    additional_exec_dir = args[:additional_exec_dir]
    dir_to_install = File.join(directory, plugin_name)
    curr_dir = Dir.pwd
    if Dir.exist?(dir_to_install)
        puts(">>>> updating plugin: " + url_part)
        Dir.chdir(dir_to_install)
        system('git pull') or raise RuntimeError, "failed execute command: git pull"
        Dir.chdir(File.expand_path(additional_exec_dir)) if !additional_exec_dir.nil?
        if !additional.nil?
            system(additional) or raise RuntimeError, "failed additional command"
        end
    else
      puts(">>>> installing plugin: " + url_part)
      Dir.chdir(directory);
      system("git clone https://github.com/" + url_part)
      if !additional_exec_dir.nil?
          Dir.chdir(File.expand_path(additional_exec_dir))
      else
        Dir.chdir(dir_to_install)
      end
      if !additional.nil?
          system(additional_exec_dir) or raise RuntimeError, "failed additional command"
      end
    end
    Dir.chdir(curr_dir)
end


def update_plugins(plugins_list, plugs_dir)
    plugins_list.each do |item|
        if item.kind_of?(Array)
            raise RangeError, "no plugin name provided" if item.empty?
            plug_name = item[0]
            additional = item[1]
            exec_dir = item[2]
            _, directory = get_author_and_directory(plug_name);
            args = {
              :directory => plugs_dir, :plugin_name => directory,
              :url_part => plug_name
            }
            if !additional.nil?
                args[:additional] = additional
                args[:additional_exec_dir] = exec_dir if !exec_dir.nil?
            end
            ensure_plugin_in_dir(args)
            next
        end
        _, directory = get_author_and_directory(plug_name);
        args = {
          :directory => plugs_dir, :plugin_name => directory,
          :url_part => item
        }
    end
end

def update_vimrc(uplugs_dir, dev_uplugs_dir, src_dir, repo)
    FileUtils.mkdir_p(File.expand_path("~/.vim/autoload"))
    FileUtils.mkdir_p(File.expand_path(uplugs_dir))
    FileUtils.mkdir_p(File.expand_path(dev_uplugs_dir))
    FileUtils.mkdir_p(file.expand_path("~/.vim/bundle"))
    if File.exists?(File.expand_path("~/.vim/autoload/pathogen.vim"))
        File.delete(File.expand_path("~/.vim/autoload/pathogen.vim"))
    end
    result = system("curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim")
    result or raise RuntimeError, "Cannot download new pathogen version"
    source = File.expand_path(src_dir)
    source_repo = File.join(source, "vim-scripts");
    pwd = Dir.pwd
    if !Dir.exist?(source_repo)
        Dir.chdir(source)
        system("git clone " + repo) or raise RuntimeError, "cannot clone reference vim-scripts repo"
    else
        Dir.chdir(source_repo)
        system("git fetch") or raise RuntimeError, "cannot update reference vim-scripts repo"
    end
    vimrc_path = File.join(source_repo, ".vimrc")
    FileUtils.cp(vimrc_path, File.expand_path("~/.vimrc"))
    content_of_init = "set runtimepath^=~/.vim runtimepath+=~/.vim/after\n" +
                      "let &packpath = &runtimepath\n" +
                      "source ~/.vimrc\n"
    FileUtils.mkdir_p(File.expand_path("~/.config/nvim/"));
    if !File.exists?("~/.config/nvim/init.vim")
        File.open("~/config/nvim/init/vim", "w") do |file|
            file.write(content_of_init);
        end
    end
    Dir.chdir(pwd)
end

def main
    plugins_list = PluginsList.LIST
    plugs_dir = PluginsList.UPLUGS_DIR
    update_plugins(plugins_list, plugs_dir)
    if $1 == "--use-dev"
        plugins_list = PluginsList.DEV_LIST
        plugs_dir = PluginsList.DEV_UPLUGS_DIR
        update_plugins(plugins_list, plugs_dir)
    else
        FileUtils.rm_rf(PluginsList.DEV_UPLUGS_DIR);
    end
end

main if __FILE__ == $0

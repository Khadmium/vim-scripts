var fs = require('fs');
var os = require('os');
var path = require('path');
var childProcess = require('child_process')
var process = require('process')

var HOME_DIR_PATH = process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE

var PLUGINS_LIST = [
    "mileszs/ack.vim",
    "scrooloose/nerdtree",
    "majutsushi/tagbar",
    "vim-scripts/vcscommand.vim",
    // ["valloric/youcompleteme", 'python3 ./install.py'],
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
    // "tpope/vim-rbenv.git",
    // "tpope/vim-bundler.git",
    "Khadmium/vim-illuminate.git"
];

var PLUGINS_DEV_LIST = [
    "h1mesuke/vim-unittest"
];

var UPLUGS_DIR_PATH = path.join(HOME_DIR_PATH, ".vim", "uplugs");
//var DEV_UPLUGS_DIR_PATH = path.join(HOME_DIR_PATH, ".vim", "dev_uplugs");
var GITHUB_URL = "https://github.com/";
var VIM_SOURCE_VIMRC_PATH = path.join(HOME_DIR_PATH, "vim-scripts", "vim-scripts", ".vimrc");
var VIM_VIMRC_DIR_PATH = HOME_DIR_PATH;

function createPluginDetails(pluginItem) {
    var separatorIndex = pluginItem.indexOf("/");
    var pluginName = pluginItem.substring(separatorIndex + 1);
    var endIndex = pluginName.indexOf(".git");
    endIndex = (endIndex === -1) ? pluginName.length : endIndex;
    pluginName = pluginName.substring(0, endIndex);
    return {
        pluginAuthor: pluginItem.substring(0,separatorIndex),
        pluginName: pluginName,
        pluginPath: path.join(UPLUGS_DIR_PATH, pluginName),
        pluginUrlPart: pluginItem
    };
}

var RESULT_CODE_INSTALLED = 1;
var RESULT_CODE_UPDATED = 2;
var RESULT_CODE_FAIL = 0;

function CompletionStatus(length) {
    function createArrayOfNullElements(length) {
        return Array(length).fill(null);
    }
    if(! this instanceof CompletionStatus) {
        return new CompletionStatus(initializer);
    }
    this._pluginsUpdatedCount = 0;
    this._pluginsInstalledCount = 0;
    this._pluginsProcessedCount = 0;
    this._pluginsFailCount = 0;
    this._pluginsCount = length;
    this._completionResults = createArrayOfNullElements(length);
}

CompletionStatus.prototype.getPluginsUpdatedCount = function() {
    return this._pluginsUpdatedCount;
}

CompletionStatus.prototype.getPluginsInstalledCount = function() {
    return this._pluginsInstalledCount;
}

CompletionStatus.prototype.getPluginsProcessedCount = function() {
    return this._pluginsProcessedCount;
}

CompletionStatus.prototype.getPluginsCount = function() {
    return this._pluginsCount;
}

CompletionStatus.prototype.getCompletionResult = function(index) {
    return this._completionResults[index];
}

CompletionStatus.prototype.completePluginInstallation = function(index, resultData) {
    this._completionResults[index] = {resultCode: RESULT_CODE_INSTALLED, resultData: resultData};
    this._pluginsInstalledCount++;
    this._pluginsProcessedCount++;
}

CompletionStatus.prototype.completePluginUpdate = function(index, resultData) {
    this._completionResults[index] = {resultCode: RESULT_CODE_UPDATED, resultData: resultData};
    this._pluginsUpdatedCount++;
    this._pluginsProcessedCount++;
}

CompletionStatus.prototype.completePluginFail = function(index, resultData) {
    this._completionResults[index] = {resultCode: RESULT_CODE_FAIL, resultData: resultData};
    this._pluginsFailCount++;
    this._pluginsProcessedCount++;
}

CompletionStatus.prototype.isEveryPluginProcessed = function() {
    return this._pluginsProcessedCount === this._pluginsCount;
}

CompletionStatus.prototype.isEveryPluginProcessedSuccessfuly = function() {
    return this._pluginsFailCount == 0;
}
var EMPTY_FUNCTION = function() {};
CompletionStatus.prototype.getSuccessCompletionFunction = function() {
    if("_successCompletionFunction" in this) {
        return this._successCompletionFunction;
    }
    return EMPTY_FUNCTION;
}

CompletionStatus.prototype.setSuccesCompletionFunction = function(value) {
    this._successCompletionFunction = value;
}

function createResultDataWithFailInfo(message, pluginName) {
    return {pluginName: pluginName, reason: message};
}

function createResultDataWithProcessingInfo(pluginName) {
    return {pluginName: pluginName};
}


function handlePluginInstallationOrUpdate(pluginDetails, completionStatus) {
    function failDueToStatsReadError(pluginPath) {
        var errorMessage =
            createResultDataWithFailInfo(
                'cannot receive info about filesystem entry: "' + pluginPath + '"',
                pluginDetails.pluginName);
        handlePluginFail(pluginDetails, completionStatus, errorMessage);
    }
    function failDueToFactThatFsEntryIsNotDirectory(pluginPath) {
        var errorMessage =
            createResultDataWithFailInfo(
                'filesystem entry is not directory: "' + pluginPath + '"',
                pluginDetails.pluginName);
        handlePluginFail(pluginDetails, completionStatus, errorMessage);
    }
    var pluginName = pluginDetails.pluginName;
    var pluginPath = pluginDetails.pluginPath;
    fs.access(pluginPath, function(error) {
        if(error) {
            handlePluginInstallation(pluginDetails, completionStatus);
            return;
        }
        fs.lstat(pluginPath, function(error, stats) {
            var errorMsg;
            if(error) {
                failDueToStatsReadError(pluginPath);
                return;
            }
            if(!stats.isDirectory()) {
                failDueToFactThatFsEntryIsNotDirectory(pluginPath)
            }
            handlePluginUpdate(pluginDetails, completionStatus)
        });
    });
}


function handlePluginUpdate(pluginDetails, completionStatus) {
    var pluginPath = pluginDetails.pluginPath;
    function failDueToGitUpdateCommandError(command) {
        var errorMessage =
            createResultDataWithFailInfo(
                'fail in execute command: "' + command + '" in: ' + pluginPath,
                pluginDetails.pluginName);
        handlePluginFail(pluginDetails, completionStatus, errorMessage);
    }
    function completePluginUpdate(error) {
        if(error) {
            failDueToGitUpdateCommandError('git pull');
            return;
        }
        completionStatus.completePluginUpdate(pluginDetails.index,
                                              {pluginName: pluginDetails.pluginName});
        completeAndSummarizePluginManagerActionsIfAllExecuted(completionStatus);
    }
    childProcess.exec('git pull' , {cwd: pluginPath}, completePluginUpdate);
}

function handlePluginInstallation(pluginDetails, completionStatus) {
    function failDueToGitPullError(command) {
        var pluginPath = pluginDetails.pluginPath;
        var errorMessage =
            createResultDataWithFailInfo(
                'cannot perform pull operation: "' + command + '" in: ' + UPLUGS_DIR_PATH,
                pluginDetails.pluginName);
        handlePluginFail(pluginDetails, completionStatus, errorMessage);
    }
    function failDueToGitSubmoduleInitError(command) {
        var pluginPath = pluginDetails.pluginPath;
        var errorMessage =
            createResultDataWithFailInfo(
                'cannot perform submodule init: "' + command + '" in: ' + pluginPath,
                pluginDetails.pluginName);
        handlePluginFail(pluginDetails, completionStatus, errorMessage);
    }

    var gitPullCommand = "git clone " + GITHUB_URL + pluginDetails.pluginUrlPart;
    childProcess.exec(gitPullCommand, {cwd: UPLUGS_DIR_PATH}, function(error) {
        if(error) {
            failDueToGitPullError(gitPullCommand);
            return;
        }
        var submoduleInitCommand = "git submodule update --init --recursive";
        var handleCompletion = function(error) {
            if(error) {
                failDueToGitSubmoduleInitError(submoduleInitCommand);
                return;
            }
            completionStatus.completePluginInstallation(pluginDetails.index,
                                                        {pluginName: pluginDetails.pluginName});
            completeAndSummarizePluginManagerActionsIfAllExecuted(completionStatus);
        }
        childProcess.exec(submoduleInitCommand,
                          {cwd: pluginDetails.pluginPath},
                          handleCompletion);
    });
}



function handlePluginFail(pluginDetails, completionStatus, error) {
    completionStatus.completePluginFail(pluginDetails.index, error);
    completeAndSummarizePluginManagerActionsIfAllExecuted(completionStatus);
}

function completeAndSummarizePluginManagerActionsIfAllExecuted(completionStatus) {
    if(completionStatus.isEveryPluginProcessed()) {
        completeAndSummarizePluginManagerActions(completionStatus);
    }
}


function completeAndSummarizePluginManagerActions(completionStatus) {
    var i, completionResult, resultCode,
        pluginCount = completionStatus.getPluginsCount();
    for(i = 0; i != pluginCount; i++) {
        completionResult = completionStatus.getCompletionResult(i);
        resultCode = completionResult.resultCode;
        switch(resultCode) {
            case RESULT_CODE_INSTALLED:
                console.log("Plugin " + completionResult.resultData.pluginName + " installed successfuly.");
                break;
            case RESULT_CODE_UPDATED:
                console.log("Plugin " + completionResult.resultData.pluginName + " updated sucessfuly. ");
                break;
            case RESULT_CODE_FAIL:
                console.log("Plugin " + completionResult.resultData.pluginName +
                            " processing failed due to: " + completionResult.resultData.reason);
                break;
            default:
                throw Error("unknown result code from plugin at index:" + i.toString());
        }
    }
    console.log("Statistics for plugins: ");
    console.log("Plugins updated: " + completionStatus.getPluginsUpdatedCount());
    console.log("Plugins installed: " + completionStatus.getPluginsInstalledCount());
    console.log("Plugins processed: " + completionStatus.getPluginsProcessedCount());
    if(completionStatus.isEveryPluginProcessedSuccessfuly()) {
        console.log("Removing unlisted plugins from plugin folder.");
        completionStatus.getSuccessCompletionFunction()();
    }
}

function removeUnusedPlugins(processedPlugins) {
    var processedPluginsSet = new Set(processedPlugins);
    fs.readdir(UPLUGS_DIR_PATH, function(error, items){
        function handleRemovingPluginCompletion(isError, isRemoved, item, msg) {
            pluginsToCheckRemove--;
            if(isError) {
                console.log("Problem with discovering potential unused plugin. "+
                            item +' Description: "' + msg + '"');
            }
            if(isRemoved) {
                console.log("Removed plugin: " + item);
            }
            if(pluginsToCheckRemove != 0) {
                return;
            }
            console.log("Plugin Manager finished!!!");
        }
        var i, length = items.length, currentPath,
            item, pluginsToCheckRemove = length;
        if(error) {
            console.log("Cannot read directory: " + UPLUGS_DIR_PATH);
            return;
        }
        for(i = 0; i != length; i++) {
            item = items[i]
            currentPath = path.join(UPLUGS_DIR_PATH, item);
            fs.lstat(currentPath, function(error, stats){
                var msg;
                if(error) {
                    handleRemovingPluginCompletion(true, item, "Cannot read stats for filesystem entry");
                }
                if(!stats.isDirectory()) {
                    msg =  "Entry is not directory. " +
                        "Try remove conflicting entry to hide this warning"
                    handleRemovingPluginCompletion(true, item, msg);
                    return;
                }
                if(processedPluginsSet.has(item)) {
                    handleRemovingPluginCompletion(false);
                    return;
                }
                var handleRemovingPluginCompletionInExecFunc = function(error) {
                    handleRemovingPluginCompletion(!!error, item);
                }
                childProcess.exec("rm -rf " + item,
                                  {cwd: UPLUGS_DIR_PATH},
                                  handleRemovingPluginCompletionInExecFunc);
            });

        }
    });
}


var NEOVIM_VIMRC_PATH_ARRAY = [HOME_DIR_PATH, '.config', 'nvim', 'init.vim'];
function ensureNvimStandardDirectoryLayoutSync() {
    var dirsToCreate = NEOVIM_VIMRC_PATH_ARRAY.slice(1, NEOVIM_VIMRC_PATH_ARRAY.length - 1);
    var startDirectory = NEOVIM_VIMRC_PATH_ARRAY[0];
    var i, length = dirsToCreate.length, currentPath = startDirectory;
    for(i = 0; i != length; i++) {
        currentPath = path.join(currentPath, dirsToCreate[i]);
        if(!fs.existsSync(currentPath)) {
            fs.mkdirSync(currentPath);
            continue;
        }
        if(fs.lstatSync(currentPath).isDirectory()) {
            continue;
        }
        console.log("Updating vimrc failed: '" + currentPath + "' is not directory");
        return false
    }
    return true;
}


var NEOVIM_INIT_FILE_CONTENT = "set runtimepath^=~/.vim runtimepath+=~/.vim/after\n" +
                               "let &packpath = &runtimepath\n" +
                               "source ~/.vimrc\n";
function updateAndCopyVimrcToStandardPaths(successCompletionFunc) {
    var filesUpdatedCounter = 0;
    var vimrcPath = path.join(VIM_VIMRC_DIR_PATH, ".vimrc");
    function completeWhenCounterReached() {
        filesUpdatedCounter++;
        if(filesUpdatedCounter == 2) {
            successCompletionFunc();
        }
    }
    function completeVimrcCopy(error) {
        if(error) {
            console.log("Erorr during copy .vimrc file to standard location.");
        }
        completeWhenCounterReached();
    }
    var nvimInitFilePath = path.join.apply(path,NEOVIM_VIMRC_PATH_ARRAY);
    function completeNvimInitWrite(error) {
        if(error) {
            console.log("Error during writting to " + nvimInitFilePath);
            console.log(error);
        }
        completeWhenCounterReached();
    }
    fs.copyFile(VIM_SOURCE_VIMRC_PATH, vimrcPath, completeVimrcCopy);
    var isNvimPathProvided = ensureNvimStandardDirectoryLayoutSync();
    if(!isNvimPathProvided) {
        console.log("layout not created");
        return;
    }
    if(fs.existsSync(nvimInitFilePath)) {
        console.log("nvim init file already exists.");
        completeWhenCounterReached();
    }
    fs.writeFile(nvimInitFilePath, NEOVIM_INIT_FILE_CONTENT, completeNvimInitWrite);
}

function initializeVimDirectoryStructure() {
    var currentError;
    var vimDirPath = path.join(HOME_DIR_PATH, '.vim');
    fs.mkdirSync(vimDirPath);
    var vimAutoloadDirPath = path.join(vimDirPath, 'autoload');
    fs.mkdirSync(vimAutoloadDirPath);
    var vimUplugsDirPath = UPLUGS_DIR_PATH;
    fs.mkdirSync(vimUplugsDirPath);
    var vimBundleDirPath = path.join(vimDirPath, 'bundle');
    fs.mkdirSunc(vimBundleDirPath);
    var pathogenInstallCommand = 'curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim';
    var execCode = childProcess.execSync(pathogenInstallCommand);
}


function runPluginManager() {
    var hasDevOption = process.argv.some(function(arg) {return arg === '--useDev'});
    var shouldInitDirectoryStructure =
        process.argv.some(function(arg){return arg == '--init'});
    if(shouldInitDirectoryStructure) {
        initializeVimDirectoryStructure();
    }
    var isCompleted = false;
    var selectedPlugins;
    if(hasDevOption) {
        selectedPlugins = PLUGINS_LIST.concat(PLUGINS_DEV_LIST);
    } else {
        selectedPlugins = PLUGINS_LIST;
    }
    var completionStatus = new CompletionStatus(selectedPlugins.length);

    var detailsPluginCollection = selectedPlugins.map(createPluginDetails);
    var processedPlugins =
        detailsPluginCollection
            .map(function(pluginDetails) { return pluginDetails.pluginName;});

    completionStatus.setSuccesCompletionFunction(function() {
        removeUnusedPlugins(processedPlugins);
    });
    var handlePluginInstallationOrUpdateForItem = function(pluginDetails, index) {
        pluginDetails.index = index;
        handlePluginInstallationOrUpdate(pluginDetails, completionStatus);
    };
    detailsPluginCollection.forEach(handlePluginInstallationOrUpdateForItem);
}

function main() {
    updateAndCopyVimrcToStandardPaths(runPluginManager);
}

main();

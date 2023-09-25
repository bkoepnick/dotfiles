#Set $PATH and environment variables to use Fink
#source /sw/bin/init.sh

export PS1="[ \d \t \h:\W ] $ "
export CLICOLOR=1
#export LSCOLORS=exfxcxdxbxegedabagacad

export HISTSIZE=10000
export HISTFILESIZE=100000

# Update column and row number after each command to match window size
#shopt -s checkwinsize

export PATH=".:/usr/local/opt/:/usr/local/git/:/Users/koepnick/scripts/:/Users/koepnick/scripts/bash/:/Users/koepnick/rosetta_local/interactive_solution/:$PATH"

# pip
export PATH="$PATH:/Users/koepnick/Library/Python/2.7/bin/"

#Rosetta
export PATH="$PATH:/Users/koepnick/rosetta_local/rosetta/source/bin/"

#Foldit
export FOLDIT_DEV_PATH="/Users/koepnick/rosetta_local/interactive/"
export FOLDIT_DEV_BIN_PATH="$FOLDIT_DEV_PATH/source/xcode_8/DerivedData/rosetta-interactive/Build/Products/Release/";
export FOLDIT_BUILD_PATH="/Users/koepnick/rosetta_local/local_build/"
export FOLDIT_CURRENT_PATH="$FOLDIT_BUILD_PATH/current"

alias terminal_static="$FOLDIT_CURRENT_PATH/terminal_static \
	-resources $FOLDIT_CURRENT_PATH/cmp-resources/resources \
	-database $FOLDIT_CURRENT_PATH/cmp-database/database \
	-renderless \
	-boinc_url http://fold.it"

alias game_static_sh=$terminal_static

#alias foldit="$FOLDIT_CURRENT_PATH/Foldit.app/Contents/MacOS/Foldit \
alias foldit="$FOLDIT_CURRENT_PATH/game_static.app/Contents/MacOS/game_static \
	-out:level 500 \
	-out:levels game.application.server.Server:Debug \
	-interactive_game novice \
	-dont_update -dont_quickstart \
	-resources $FOLDIT_CURRENT_PATH/cmp-resources/resources \
	-database $FOLDIT_CURRENT_PATH/cmp-database/database"

alias foldit_trim="$FOLDIT_CURRENT_PATH/game_static.app/Contents/MacOS/game_static \
	-out:level 500 \
	-interactive_game novice \
	-dont_update -dont_quickstart \
	-in:use_truncated_termini 1 \
	-resources $FOLDIT_CURRENT_PATH/cmp-resources/resources \
	-database $FOLDIT_CURRENT_PATH/cmp-database/database"

alias terminal_static_dev="$FOLDIT_DEV_BIN_PATH/terminal_static \
	-resources $FOLDIT_DEV_PATH/resources \
	-database $FOLDIT_DEV_PATH/database \
	-renderless \
	-boinc_url http://fold.it"

#PyMOL
#alias pymol="/Applications/MacPyMOL.app/Contents/MacOS/MacPyMOL -k -r /Users/koepnick/scripts/pymol/obj_arrows.py"
#alias pymol="/Applications/PyMOL.app/Contents/MacOS/PyMOL -Q"
function pymol() {
	/Applications/PyMOL.app/Contents/MacOS/PyMOL $@ > /dev/null &
}

# ImageMagick
export MAGICK_HOME="/Applications/ImageMagick-7.0.10"
export PATH="$MAGICK_HOME/bin:$PATH"
export DYLD_LIBRARY_PATH="$MAGICK_HOME/lib/"

# always run coot in this temp directory, so it doesn't leave tmp droppings all over the place
alias coot="mkdir -p /Users/koepnick/temp/coot/; cd /Users/koepnick/temp/coot; /usr/local/bin/coot"

#export PYTHONHOME="/opt/local/Library/Frameworks/Python.framework/Versions/2.7"
export PYTHONPATH=".:/usr/lib:/opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/:/Users/koepnick/rosetta_local/lib/:/Users/koepnick/scripts/javier_pymol_scripts/:/Users/koepnick/scripts/module/:/Users/koepnick/lib/:$PYTHONPATH"

export ROSETTA_INTERACTIVE_PATH="/Users/koepnick/rosetta_local/interactive/"

# CMake
export PATH="/Applications/CMake.app/Contents/bin:$PATH"

# Emscripten
# I think maybe this changes default python, etc.? Maybe best to source manually when needed...
#source "/Applications/emsdk/emsdk_env.sh"

# Chromium depot_tools (e.g. gclient)
#export PATH="/Applications/Chromium/depot_tools/:$PATH"

# Homebrew
#eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="/opt/homebrew/bin/:$PATH"

# psql
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Ruby
#export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/3.1.0/bin/:$PATH"
# Ruby with Rosetta
#export PATH="/usr/local/opt/ruby/bin:$PATH"

# Docker
export DOCKER_DEFAULT_PLATFORM=linux/amd64

alias join_pdf="/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/MacOS/join -o"

alias mount_digs="sshfs -o defer_permissions,follow_symlinks,reconnect,volname=digs,cache=no ipdusername@share:/home/ipdusername ~/digs"

alias histogram="histogram.sh"

function hist() {
	history| grep "${1}" | tail -n 20
}

function title() {
    echo -ne "\033]0;"$*"\007"
}

function newdir() {
	DIR=$1; 
	mkdir ${DIR}; cd ${DIR};
}

function fetch_cif(){
    #curl -O http://www.rcsb.org/pdb/files/$1.pdb
    curl -O http://files.rcsb.org/download/${1}-sf.cif
}

function fetch_pdb() {
	#curl -O http://www.rcsb.org/pdb/files/$1.pdb
	curl -O http://files.rcsb.org/download/${1}.pdb
}

function fetch_map() {
	curl -O http://www.ebi.ac.uk/pdbe/coordinates/files/${1}.ccp4
}

function fetch_mtz() {
	curl -O http://www.ebi.ac.uk/pdbe/coordinates/files/${1}_map.mtz	
}

# suppress stupid mac warning about zsh being the default shell
export BASH_SILENCE_DEPRECATION_WARNING=1


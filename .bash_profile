source ~/.bashrc

##
# Your previous /Users/koepnick/.bash_profile file was backed up as /Users/koepnick/.bash_profile.macports-saved_2021-09-05_at_13:56:08
##

# MacPorts Installer addition on 2021-09-05_at_13:56:08: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/koepnick/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/koepnick/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/koepnick/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/koepnick/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


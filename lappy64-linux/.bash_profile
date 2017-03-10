# .bash_profile

# if [ ${SHLVL} -eq 1 ]; then
#     ((SHLVL+=1)); export SHLVL
#     exec screen -R -e "^Ee" ${SHELL} -l
# fi

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

export PATH=$PATH:$HOME/bin

# For rcs via sudo:
export LOGNAME=afilipi

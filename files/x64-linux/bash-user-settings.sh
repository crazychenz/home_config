# Configure aliases fpr the terminal colors.
COLOR_LIGHT_BROWN="$(tput setaf 178)"
COLOR_LIGHT_PURPLE="$(tput setaf 135)"
COLOR_LIGHT_BLUE="$(tput setaf 87)"
COLOR_LIGHT_GREEN="$(tput setaf 78)"
COLOR_LIGHT_YELLOW="$(tput setaf 229)"
COLOR_YELLOW="$(tput setaf 184)"
COLOR_RESET="$(tput sgr0)"
COLOR_GREEN="$(tput setaf 83)"
COLOR_ORANGE="$(tput setaf 208)"
COLOR_RED="$(tput setaf 167)"
COLOR_GRAY="$(tput setaf 243)"

# Helper for showing colors in user specific terminal window+profile.
# Inspired by:
# https://www.lihaoyi.com/post/BuildyourownCommandLinewithANSIescapecodes.html
function show_colors {
    python <<PYTHON_SCRIPT
import sys
for i in range(0, 16):
    for j in range(0, 16):
        code = str(i * 16 + j)
        sys.stdout.write(u"\u001b[38;5;" + code + "m " + code.ljust(4))
    print u"\u001b[0m"
PYTHON_SCRIPT
}

# Define colors for git branch/checkout depending on state.
# Inspired by:
# https://coderwall.com/p/pn8f0g
function git_branch {
  git rev-parse --is-inside-work-tree &> /dev/null
  if [ "$?" -eq "0" ]; then
    local git_status="$(git status 2> /dev/null)"
    local on_branch="On branch ([^${IFS}]*)"
    local on_commit="HEAD detached at ([^${IFS}]*)"

    if [[ ! $git_status =~ "working tree clean" ]]; then
        COLOR=$COLOR_RED
    elif [[ $git_status =~ "Your branch is ahead of" ]]; then
        COLOR=$COLOR_YELLOW
    elif [[ $git_status =~ "nothing to commit" ]]; then
        COLOR=$COLOR_LIGHT_GREEN
    else
        COLOR=$COLOR_ORANGE
    fi

    if [[ $git_status =~ $on_branch ]]; then
        local branch=${BASH_REMATCH[1]}
        echo -e "$COLOR($branch) "
    elif [[ $git_status =~ $on_commit ]]; then
        local commit=${BASH_REMATCH[1]}
        echo -e "$COLOR($commit) "
    fi
  fi
}
export -f git_branch

# Fetch the date in a canonical format.
function get_prompt_date {
    echo -e "$COLOR_GRAY$(date +%Y-%m-%d-%H:%M:%S)"
}
export -f get_prompt_date

# Get docker identity. Useful for doing `docker exec`, `docker stop`, etc.
# Note: This used to rely on /proc/1/cpuset, but with newer dockers we
#       now rely on volume mounting the output of --cidfile from `docker run`.
# Inspired by:
# https://stackoverflow.com/questions/20995351
function get_docker_ident {
    echo ""
}
export -f get_docker_ident

# Note: Without \[ \] properly placed, wrapping will not work correctly.
# More info found at: https://robotmoon.com/256-colors/
USERHOST_PSENTRY='\[$COLOR_LIGHT_BLUE\]\u\[$COLOR_GRAY\]@\[$COLOR_GREEN\]\h '
PS1="${debian_chroot:+($debian_chroot)}$USERHOST_PSENTRY"
PS1="$PS1\$(get_docker_ident)"
PS1="$PS1\$(git_branch)"
PS1="$PS1\$(get_prompt_date)"
WORKINGDIR='\[$COLOR_LIGHT_YELLOW\]\w'
PROMPT_DELIM='\[$COLOR_RESET\]\$ '
export PS1="$PS1\n$WORKINGDIR$PROMPT_DELIM"

export KUBECONFIG=~/node0.yaml
export EDITOR=vim
export PROMPT_COMMAND='history -a'
eval $(ssh-agent -s)
alias myip='dig +short myip.opendns.com @resolver1.opendns.com'

reload_vscode_ipc() {
  export VSCODE_IPC_HOOK_CLI=$(ls -tr /run/user/$UID/vscode-ipc-* | tail -n 1)
}; reload_vscode_ipc

alias vi=nvim

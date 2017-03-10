# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
[ -z "$PS1" ] && return

# dump horrid defaults:
unset PROMPT_COMMAND
shopt -u progcomp
unset command_not_found_handle

export PS1='${BB_ENV_EXTRAWHITE:+: BBS; }: \u@\h; '
export PS2='${BB_ENV_EXTRAWHITE:+: BBS; }:; '

stty -echoctl		    	# Don't echo control characters like ^C.
stty start undef stop undef	# Clear for interractive history searching.

alias vi='nvi'
export EDITOR=nvi
export VISUAL=nvi
alias ls='ls -F'
alias l.='ls -Fd .*'
alias ll='ls -aFl'
alias more=less
export PDFVIEWER=acroread
export LESS=-FiX
export PAGER=less
export MANWIDTH=80
alias diff="diff -u"
alias rcsdiff="rcsdiff -u"
alias colordiff="colordiff -u"
alias cdl='command colordiff | less -R'
alias ediff="emacs -diff"
alias more=${PAGER:-more}
alias crib="${PAGER} ~/.cribsheet"
alias vidiff=editdiff
alias dirs='dirs -v'

alias gdiff="git diff --no-index"
gcdiff() {
    local tmp=$(mktemp -d -p /tmp gcdiff.XXXXXXXXXX)
    local i
    for((i=$#; i>2; i=$#)) {
	local args="${args}${1:+ $1}"
	shift
    }
    local cid1=${1:?}
    local cid2=${2:?}
    git show ${cid1} >${tmp}/${cid1}
    git show ${cid2} >${tmp}/${cid2}
    (
	cd ${tmp}
	git diff --no-index ${args} ${cid1} ${cid2}
    )
    rm -r ${tmp}
}


export PARINIT='rTbgqR B=.,?_A_a Q=_s>|'

DEF_INFOPATH=
DEF_INFOPATH=${DEF_INFOPATH}${DEF_INFOPATH:+:}/usr/share/info
INFOPATH=${DEF_INFOPATH}

DEF_PATH=
DEF_PATH=${DEF_PATH}${DEF_PATH:+:}/home/afilipi/bin
DEF_PATH=${DEF_PATH}${DEF_PATH:+:}/opt/libreoffice3.6/program
DEF_PATH=${DEF_PATH}${DEF_PATH:+:}/sbin:/bin
DEF_PATH=${DEF_PATH}${DEF_PATH:+:}/usr/sbin:/usr/bin
DEF_PATH=${DEF_PATH}${DEF_PATH:+:}/usr/kerberos/sbin:/usr/kerberos/bin
DEF_PATH=${DEF_PATH}${DEF_PATH:+:}/usr/local/sbin:/usr/local/bin
# reset_path() {
#     OPATH=${PATH}
#     PATH=${DEF_PATH}
# }
# reset_path

export HISTSIZE=10000
export HISTFILESIZE=${HISTSIZE}
export HISTTIMEFORMAT="%F %X  "

#HISTCONTROL=ignoredups          # Reduce redundancy in the history file.
#HISTIGNORE="\&:fg:bg:ls:pwd:cd ..:cd ~-:cd -:cd:jobs:set -x"
#HISTIGNORE="${HISTIGNORE}:ls -l:ls -l:%1:%2:top:alpine:shutdown*"
HISTIGNORE="&"			# same as HISTCONTROL=ignoredups
HISTIGNORE="${HISTIGNORE}:fg:bg:ls:pwd"
HISTIGNORE="${HISTIGNORE}:top:alpine:shutdown*:reboot*:poweroff*"

set -o notify		        # Asynchronous job status notification.
shopt -s checkhash              # Use hash table for exec'ing commands.
shopt -s lithist                # Retain newlines in command history.
shopt -s cmdhist                # save long commands in a single line
shopt -s histappend

unset MAILCHECK

export LC_ALL=C

export MANWIDTH=80

export CVSROOT=/home/afilipi/repo-cvs

hexpr() {
    printf "%#010x\n" "$@"
}

bexpr () {
    for ((i=31; i>=0; i--)); do
	if ((i>9)); then
	    printf "%s" $((i/10))
	else
	    printf " "
	fi
	if (( i>0 && i%4==0 )); then
	    printf " "
	fi
    done
    printf "\n"
    for ((i=31; i>=0; i--)); do
	printf "%s" $((i%10))
	if (( i>0 && i%4==0 )); then
	    printf " "
	fi
    done
    printf "\n"
    for ((i=31; i>=0; i--)); do
	printf "="
	if (( i>0 && i%4==0 )); then
	    printf " "
	fi
    done
    printf "\n"
    for n; do
	eval "n=\$(($n))"
	for ((i=31; i>=0; i--)); do
	    printf "%d" $(( (n & (1<<i)) ? 1 : 0))
	    if (( i>0 && i%4==0 )); then
		printf "."
	    fi
	done
	printf "\n"
    done
}

ssh-rm () {
    if [ $# = 0 ]; then
	echo "usage: ssh-rm [hostname|known_hosts_line_number]..." 1>&2
	return 1
    fi
    for i; do
	case $i in
	    [0-9]*)
		sed -i "${i}d" ~/.ssh/known_hosts
		;;
	    *)
		ssh-keygen -R ${i%:*}
		;;
	    esac
    done
}

ssh-find-agent()
{
    local i
    local agents
    if [ -O ${SSH_AUTH_SOCK} ]; then
	agents=${SSH_AUTH_SOCK} 
    fi
    unset SSH_AUTH_SOCK
    shopt -s nullglob
    for i in /tmp/ssh-*/agent.*; do
	if ! [ -O $i ]; then
	    continue
	fi
	agents+=" $i"
    done
    for i in ${agents}; do
	local nkeys
	SSH_AUTH_SOCK=$i ssh-add -l >/dev/null 2>&1
	case $? in
	    0)
		nkeys=$(SSH_AUTH_SOCK=$i ssh-add -l | wc -l)
		echo "# export SSH_AUTH_SOCK=$i # ${nkeys} keys"
		;;
	    1)
		echo "# export SSH_AUTH_SOCK=$i # no keys"
		continue
		;;
	    2)
		echo "# export SSH_AUTH_SOCK=$i # cannot connect"
		continue
		;;
	    *)
		echo "# export SSH_AUTH_SOCK=$i # unexpected error"
		continue
		;;
	esac

	if ! [[ ${SSH_AUTH_SOCK} ]]; then
	    export SSH_AUTH_SOCK=$i
	fi
    done
    echo "export SSH_AUTH_SOCK=${SSH_AUTH_SOCK}   # selected"
    ssh-add -l | awk '{printf ("    %s %s\n", $4, $3)}'
}

ksercon()
{
    local tty=${1:-USB0}
    xterm -geom 80x26 -n "tty${tty}" -T "tty${tty}" -bg darkslategrey \
	-e screen -R -S "sercon-${tty}" kermit -y ~/.kermrc-${tty} &
    disown $!
}

sercon()
{
    local tty=${1:-USB0}
    local spd=${2:-115200}
    xterm -geom 80x26 -n "tty${tty}" -T "tty${tty}" -bg darkslategrey \
	-e screen -R -S "sercon-${tty}" /dev/tty${tty} ${spd} &
    disown $!
}

swrk()
{
    screen -c ~/.screenrc.wrk${1:+.$1}
}

cd() 
  { 
    case $* in
	"")
	    builtin cd && echo \# ${PWD} \<- ${OLDPWD}\; 1>&2;
	    ;;
	*)
	    builtin cd "$*" && echo \# ${PWD} \<- ${OLDPWD}\; 1>&2;
	    ;;
    esac
  }

# Define a function to format roff manpage source and view it.
rman()
  {
    case $# in
      0)
        echo "usage: rman page.man" 1>&2
        return 0
        ;;
      *)
        groff -man -Tascii "$@" | ${PAGER:-more}
    esac
  }


rfc() {
    local base_url=http://www.ietf.org
    case $# in
	0)
	    w3m ${base_url}/rfc.html
	    ;;
	1)
	    w3m ${base_url}/rfc/rfc$1.txt
	    ;;
	*)
	    echo "usage: rfc [rfc number]" 1>&2
	    return 1
	    ;;
    esac
}


wrmnt () {
    local wrl
    wrl=/home
    # Old (zest) way:
    wrl=${wrl}/f11-eurotech-helios-eval/wr_wb32wrlx302_intel_p4
    wrl=${wrl}/fs/WindRiver-wrlx302-intel-sandbox

    # New (klettur) way:
    # wrl=${wrl}/LiveUSB/modules/f11/wrlinux302/pentium4
    # wrl=${wrl}/mod_f11_wrlinux302_workbench32_pentium4/fs
    # wrl=${wrl}/WindRiver-wrlx302-intel-sandbox


    sudo -v
    if [ "$1" != off ] && mount | egrep -q -e '\b/WindRiver\b'; then
	echo "/WindRiver is already mounted."
	return 1
    fi
    case $1 in
	sandbox|sb)
	    sudo mount -o bind ${wrl} /WindRiver
	    ;;
	off)
	    sudo umount /WindRiver
	    return 0
	    ;;
	*)
	    echo "ERROR: unimplemented" 1>&2
	    return 1
	    ;;
    esac
    echo "using: ${wrl##*/}" 1>&2
}

btmp() {
    case ${1} in
	on)
	    if [ -n "${BASE}" ]; then
		echo "btmp: \${BASE} already set: ${BASE}" 1>&2
		return 1
	    fi
	    BASE=${HOME}/btmp
	    mkdir -p ${BASE}
	    sudo mount -t tmpfs -o uid=afilipi,gid=afilipi,mode=0755 tmpfs ${BASE}
#	    if [ -n "${LDAT_CACHE_DIR}" ]; then
#		LDAT_CACHE_DIR=${BASE}/${LDAT_CACHE_DIR##*/}
#	    fi
	    ;;
	off)
	    if [ -z "${BASE}" ]; then
		echo "btmp: \${BASE} not set." 1>&2
		return 1
	    fi
	    sudo umount ${BASE}
	    unset BASE
	    if [ -n "${LDAT_CACHE_DIR}" ]; then
		unset LDAT_CACHE_DIR
	    fi
	    ;;
	keep)
	    echo "btmp: unimplemented!" 1>&2
	    # rsync --delete
	    return 1
	    ;;
	sync)
	    echo "btmp: unimplemented!" 1>&2
	    return 1
	    ;;
	*)
	    echo "usage: btmp on|off|sync|keep" 1>&2
	    return 1
	    ;;
    esac
}

fix_file_url() {
    # file:///%5C%5CAds-dc01%5Csoftware%5CAsBuilt%5C910999-92378%20CTMX3001.docx
    local x
    x="${1:?no URL given}"
    x="${x//%/\\x}"
    # x="$(printf "$x" | sed -e 's,\\,/,g' -e 's,/////,///,')"
    x="$(printf "$x" |
	sed -e 's,\\,/,g' \
	    -e 's,file://///,/,' \
	    -e 's,^/Ads-,/ads-,' \
	    -e 's,/software,/Software,'
	)"
    echo $x
}

fix_file_name() {
    # e.g. '(610124-7307A)_Vector uController Debug Cable-good.pdf'
    local x
    x="${1:?no file name given}"
    x="${x//[()]/}"
    x="${x// /_}"
    x="${x//\\/}"
    mv "$1" $x
}

vmcfg() {
    case ${1} in
	vbox)
	    sudo modprobe -r kvm
	    sudo modprobe -r kvm_intel
	    sudo /etc/init.d/vboxdrv start
	    ;;
	kvm)
	    sudo /etc/init.d/vboxdrv stop
	    sudo modprobe kvm_intel
	    sudo modprobe kvm
	    ;;
	*)
	    echo "usage: vmcfg vbox|kvm"
	    return 1
	    ;;
    esac
}

prj_rm4 ()
{
    if [ ${1:-not_set} = not_set ]; then
	echo 'usage: prj_rm prj_dir' 1>&2
	return 1
    fi
    realpath $1 >/dev/null || return $?
    local prj_dir=$(realpath $1)
    if [ ${prj_dir} = $(realpath ${HOME}) ]; then
	echo "ERROR: $1 == ${prj_dir}, i.e your HOME" 1>&2
	return 1
    fi
    (
	if [ ${PWD} != ${prj_dir} ]; then
	    builtin cd ${prj_dir}
	fi
	if ! [ -e filesystem ]; then
	    echo "ERROR: ${prj_dir} is not a WRL4 project!" 1>&2
	    return 1
	fi
	if [ -e config.log ]; then
	    echo "cleaning ${prj_dir}"
	    rm -rf $(command ls -d ./.??* * |
		grep -vEe '^(dist|include|packages|poky|templates|tools|.cfg|.scc|.git)')
	    rm -f {dist,packages,templates,tools}/README syslinux.cfg
	    rmdir --ignore-fail-on-non-empty {dist,packages,templates,tools}
	    if [ -s include ] && ! grep -qv '^#' include; then
		rm -f include
	    fi
	else
	    echo "ERROR: ${prj_dir} is not a WRL project!" 1>&2
	    return 1
	fi
    ) || return $?
    if [ ${PWD} != ${prj_dir} ]; then
	echo "removing ${prj_dir}"
	rmdir ${prj_dir} || 
	    tree --noreport ${prj_dir} | sed -e 's/^/    /'
    else
	echo "retaining ${prj_dir}"
	tree --noreport ${prj_dir} | sed -e 's/^/    /'
    fi
}

prj_rm5 ()
{
    if [ ${1:-not_set} = not_set ]; then
	echo 'usage: prj_rm prj_dir' 1>&2
	return 1
    fi
    realpath $1 >/dev/null || return $?
    local prj_dir=$(realpath $1)
    if [ ${prj_dir} = $(realpath ${HOME}) ]; then
	echo "ERROR: $1 == ${prj_dir}, i.e your HOME" 1>&2
	return 1
    fi
    (
	if [ ${PWD} != ${prj_dir} ]; then
	    builtin cd ${prj_dir}
	fi
	if ! [ -e bitbake ]; then
	    echo "ERROR: ${prj_dir} is not a WRL5 project!" 1>&2
	    return 1
	fi
	if ! [ -e config.log ]; then
	    echo "ERROR: ${prj_dir} is not a WRL project!" 1>&2
	    return 1
	fi
	dev_files=
	dev_files="${dev_files} bitbake_build/conf/.git"
	dev_files="${dev_files} layers/local/.git"
	keepers=
	for i in ${dev_files}; do
	    if [ -e $i ]; then
		keepers="${keepers:+${keepers} }$i"
	    fi
	done
	if [ -n "${keepers}" ]; then
	    echo "ERROR: project directory contains a development files/directories:"
	    echo "ERROR:     ${prj_dir}"
	    for i in ${keepers}; do
		echo "ERROR:         $i"
	    done
	    return 1
	fi 1>&2
	echo "cleaning ${prj_dir}"
	rm -rf *
    ) || return $?
    if [ ${PWD} != ${prj_dir} ]; then
	echo "removing ${prj_dir}"
	rmdir ${prj_dir} || 
	    tree --noreport ${prj_dir} | sed -e 's/^/    /'
    else
	echo "retaining ${prj_dir}"
	tree --noreport ${prj_dir} | sed -e 's/^/    /'
    fi
}

prj_env ()
{
    if [ ${WIND_BASE:-not_set} = not_set ]; then
        echo "ERROR: WIND_BASE is not set." 1>&2
        return 1
    fi
    if [ ${1:-not_set} = not_set ]; then
	echo 'usage: prj_env prj_dir' 1>&2
	return 1
    fi
    realpath $1 >/dev/null || return $?
    local prj_dir=$(realpath $1)
    if [ -e ${prj_dir}/config.log ]; then
	PATH=$(
	    echo $PATH |
		tr ':' '\n' | grep -v host-cross |
		tr '\n' ':' | sed -e 's/:$//'
	)
	PATH=${prj_dir}/host-cross/i586-wrs-linux-gnu/bin:${PATH}
	PATH=${prj_dir}/host-cross/bin:${PATH}
    else
	echo "ERROR: ${prj_dir} is not a WRL project!" 1>&2
	return 1
    fi
    return 0
}

grr ()
{
    if ! [ -d .git ]; then
	echo "ERROR: must be run from a git repo"
	return 1
    fi
    if [ -h .git/rr-cache ]; then
	return 0
    fi
    if [ -d .git/rr-cache ]; then
	rm -r .git/rr-cache
    fi
    ln -s ~/.git-rr-cache .git/rr-cache
}

ssh-push ()
{
    if [ $# = 0 ]; then
	echo "usage: ssh-push hostname" 1>&2
	return 1
    fi
    tar --owner=root --group=root -C ~/.ssh.dyn -c . |
	SSH_AUTH_SOCK= ssh ${1%:*} \
	    "rm -rf .ssh; mkdir -p .ssh; tar -C .ssh -xv"
}

old_partno ()
{
    local new_partno
    local old_partno
    new_partno=${PWD##*/}
    case ${new_partno} in
	??????-?????[-_]*)
	    ;;
	*)
	    echo "ERROR: not a release directory!" 1>&2
	    return 1
	    ;;
    esac
    new_partno=${new_partno%%_*}
    old_partno=$(
	# No ell ('l')
	echo ${new_partno} |
	    sed \
		-e h -e 's/\(.*\)\(.\)/\2/' \
		-e 'y/123456789abcdefghijkmnopqrstuvwxyz/0123456789abcdefghijkmnopqrstuvwxy/' \
		-e x -e 's/\(.*\)\(.\)/\1/' \
		-e G -e 's/\n//'
    )
    echo ${old_partno}
}

cp_old_ser ()
{
    local old_partno=$(old_partno)
    echo cp "../${old_partno}*/*.doc" ${PWD##*/}.doc
         cp  ../${old_partno}*/*.doc  ${PWD##*/}.doc
}

open ()
{
    for i in "$@"; do
	xdg-open "$i" &
    done
}

history ()
{
    HISTTIMEFORMAT="%F %X;  " builtin history "$@" | sed -e 's/^/:/'
}

# Old function for working with debian ARM images:
modrd()
{
    export rgz=${1:-ramdisk.gz}
    (
	set -e

	dir=$(mktemp -d)
	img=${dir}/ramdisk
	mnt=${dir}/mnt

	trap "rm -rf ${dir}" EXIT

	gunzip < ${rgz} > ${img}
	mkdir ${mnt}
	(
	    sudo mount -o loop ${img} ${mnt}
	    trap "cd /tmp; sudo umount ${mnt}" EXIT
	    cd ${mnt}
	    PS1=": ${rgz}; " bash
	)
	gzip -v9 ${img}
	sudo mv -bi ${img}.gz ${rgz} 
    )
    unset rgz
}

# Old function for picking my ARM cross-compiler toolchain:
xcc()
{
    local toolsby
    local basedir
    local i
    local newpath
    local opts
    export CROSS_COMPILE

    while :; do
	case ${1:-status} in
	    332|oabi)
		toolsby="ADS offical 3.3.2 from handhelds.org"
		basedir=/usr/local/arm/3.3.2
		CROSS_COMPILE=arm-linux-
		;;
	    411)
		toolsby="ADS offical 4.1.1 from wantstofly.org (no linbc)"
		basedir=/opt/crosstool/gcc-4.1.1
		CROSS_COMPILE=arm-unknown-linux-gnueabi-
		;;
	    411bsp)
		# builds kernels and apps just fine.
		# kernel crashes on TCP!
		toolsby="marvell.com: BSP 7.2.2.3 (LV)"
		basedir=/usr/local/arm/arm-linux-4.1.1
		CROSS_COMPILE=arm-iwmmxt-linux-gnueabi-
		;;
	    423|eabi)
		# builds kernels and apps just fine.
		toolsby="codesourcery.com: 2008q1-126 (arm-none-linux-gnueabi)"
		basedir=/usr/local/arm/arm-2008q1-linux-gnueabi
		CROSS_COMPILE=arm-none-linux-gnueabi-
		;;
	    off)
		toolsby="Debian Native"
		PATH=${DEF_PATH}
		unset CROSS_COMPILE
		break
		;;
	    status)
		break
		;;
	    *)
		echo "usage: xcc [332|oabi|411||411bsp|423|eabi|off|status]"
		return
		;;
	esac

	newpath=
	sep=
	for i in sbin bin; do
	    if [ -d ${basedir}/$i ]; then
		newpath=${newpath}${newpath:+:}${basedir}/$i
	    fi
	done
	PATH=${newpath}:${DEF_PATH}

	INFOPATH=${basedir}/info${DEF_INFOPATH:+:}${DEF_INFOPATH}

	break
    done
    ${CROSS_COMPILE}gcc --version | head -1
}

wrcfgchk() { (
	set -e
	builtin cd ${prj_dir:?}
	builtin cd bitbake_build/conf/bitbake_build/tmp/sysroots/intel-atom/usr/src/kernel
	builtin cd meta/cfg/*/intel-atom
	cfgs="specified_non_hdw.cfg invalid.cfg mismatch.cfg"
	wc -l ${cfgs}
	read -p "<press enter>"
	less ${cfgs}
) }


err_on() {
    set -o errtrace
    trap '(
	_ret=$?
	_cmd=${BASH_COMMAND}
	if [[ $- = *x* ]]; then
	    _xcmd="set -x; unset _xcmd"
	    set +x
	fi
	echo "BASH_COMMAND: ${_cmd}"
	echo "RETURNED:     ${_ret}"
	eval "${_xcmd:-:}"
	unset _ret _cmd
    )' ERR
}
err_off() {
    trap - ERR
    set +o errtrace
}


# for bitbake development:
lslogs()
{
    for i in $(command ls -t $(find . -type l)); do
	pid=$(readlink $i | awk -F. '{print $NF}')
	command ls -1t *.${pid}
	echo
    done | sed -e '/^log/!s/^/  /' | ${PAGER}
}
pdlogs()
{
    pushd tmp/work/*/${1:?package_name}-*/temp && lslogs
}

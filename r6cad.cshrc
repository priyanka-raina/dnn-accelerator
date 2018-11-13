# @(#) Murmann group .csrhc
# Adapted from Leland Systems .cshrc version 3.0.6
# Modified by Paul Wang Lee, 5/9/2004
# Modified by PWL to fit group Linux systems 11/1/2005
#
# Commands in the .cshrc file are executed after /etc/csh.cshrc
# and before those in the .login file.  This file is read each time
# you directly or indirectly start a shell process.
#
# This file is used by both tcsh and csh.  See the man page for
# tcsh for a list of the many options that the shell supports.
#
# tcsh reads files in the following order:
#    /etc/csh.cshrc	(system file, for all shells)
#    /etc/csh.login	(system file, for login shells only)
#    ~/.cshrc		(user file, for all shells)
#    ~/.login		(user file, for login shells only)

#------#
# Path #
#------#

# User path customizations go AFTER the endif line.

# First, set up a default path (site_path).  The local default
# should be set for you in /etc/csh.cshrc.  If none is set, we
# set a resonable default base system path here.

# Modified to reflect path on 'analog'. -PWL-
if ( ! $?site_path ) then
    set site_path=( \
	/bin /usr/local/bin /usr/bin \
	/usr/local/sbin /usr/sbin /sbin \
	/usr/pubsw/bin \
	/usr/X11R6/bin /usr/bin/X11 \
	/usr/etc \
	/usr/openwin/bin \
	/usr/games \
	)
endif

# Now we actually set the path.
# We add your home directory and bin directory to the system list.
# You may add additional path customizations here.
set path=( $site_path ~/bin ~ .)


#------------#
# All Shells #
#------------#

#umask 027		# file protection no read or write for others
			# umask 022 is no write but read for others
umask 002

limit coredumpsize 0	# don't write core dumps
set noclobber		# don't overwrite existing file w/ redirect
set rmstar		# prompt before executing rm *
alias cp 'cp -i'	# prompt before overwriting file
alias mv 'mv -i'	# prompt before overwriting file
alias rm 'rm -i'	# prompt before removing file

if (! $?prompt) exit    # exit if noninteractive -- starts faster

# Everything below this line is only for interactive shells

id

#-------------------------#
# Environmental Variables #
#-------------------------#

# Environmental variables are used by both shell and the programs
# the shell runs.

# EDITOR sets the default editor
setenv EDITOR "emacs"
setenv VISUAL "$EDITOR"

#---------------------------------------#
# Shell-Dependent Variables and Aliases #
#---------------------------------------#

# tcsh is a near superset of csh.  Since this file is read by
# both shells, we only set those items particular to tcsh if
# tcsh is running.  Similarly, we handle csh-only settings here.

if ($?tcsh) then	# tcsh settings
    set prompt="%m:%~%# "	# set prompt to hostname:cwd>
    set autolist=ambiguous	# display possible completions
    set nobeep			# do not beep if completions exist
    set listmax=50		# ask if completion has >50 matches
    set symlinks=ignore		# treat symlinks as real
    set pushdtohome		# pushd w/o arguments defaults to ~
    alias back 'cd -'		# chdir to previous directory

else			# csh settings
    set filec			# allow Esc filename completion
    set host=`hostname | sed -e 's/\..*//'`
    alias setprompt 'set prompt="${host}:$cwd:t%"'
    alias cd 'chdir \!* && setprompt'	# ensure prompt has cwd
    setprompt			# set the prompt
endif

#-----------------#
# Shell Variables #
#-----------------#

# variables customize the shell.  See the man page for the full list.

set history=100		# number of history commands to save
set notify		# immediate notification when jobs finish
set ignoreeof		# disable ctrl-d from logging out
			# experienced users may want to delete this

# cdpath and fignore are time-savers, but can be confusing to novices
	# cdpath contains a search path for the cd command
#set cdpath=(. .. ~)
	# fignore contains suffixes to ignore for file completion
#set fignore=(\~ .o)

#---------------#
# Shell Aliases #
#---------------#

# Aliases provide a means to add commands and personalize your shell.

# Command aliases
alias .. 'cd ..'			# go up one directory
alias quiet '\!* >& /dev/null &'	# run a command with no output
alias orig 'cp -p \!:1 \!:1.orig'	# backup file

# Aliases which add or alter functionality
alias lpr 'lpr -h'		# suppress banner page (saves paper)
alias jobs 'jobs -l'		# also show process id's
alias dir 'ls -alg'		# show group, size information
#alias kinit 'kinit -t'		# obtain a token when getting a ticket
#alias ls 'ls -F'		# show file types
#alias enscript enscript -2rGh	# print 2up, rotated, fancy banner
#alias ftp ncftp 		# ncftp is a nicer ftp
#alias talk ytalk		# ytalk is a nicer talk

# Typo Protection: a forgiving shell is a friendly shell
#alias figner finger
#alias mroe more

#-------------#
# Completions #
#-------------#

# Programmable completion is one of the nicest features of tcsh.

if ($?tcsh) then

# shell variable and alias commands
complete set 'p/1/s/=/'		# set <shell variable>=
complete printenv 'p/1/e/'	# printenv <Environmental variable>
complete unsetenv 'p/1/e/'	# unsetenv <Environmental variable>
complete setenv 'p/1/e/'	# setenv <Environmental variable>

# common commands
complete elm 'c@=@F:'$HOME'/Mail/@'	# let elm -f =[TAB] work

# common user subcommands for the AFS fs command
complete fs 'p/1/(setacl listacl listquota examine help mkmount \
		rmmount checkservers flush)/'

endif

#-------------------#
# Terminal Settings #
#-------------------#

# turn off needless delays for special characters
stty cr0 nl0 -tabs ff0 bs0

# establish common bindings for terminal functions
stty intr '^C' erase '^?' kill '^U' quit '^\'

# set up common output settings
stty ixany -istrip

# disable the shell's own commandline editing for shell-mode in emacs
if ($?EMACS) then
    if ($EMACS == t) then
	unset edit
	stty -nl -onlcr -echo
    endif
endif

#------------------#
# Other scripts    #
#------------------#
setenv MANPATH /usr/share/man

# LICENSE SETTINGS
if ($?LM_LICENSE_FILE) then
    setenv LM_LICENSE_FILE ${LM_LICENSE_FILE}:1717@cadlic0.stanford.edu
else
    setenv LM_LICENSE_FILE 1717@cadlic0.stanford.edu
endif

#------------------#
# Load Modules     #
#------------------#

module load base/1.0

# Cadence
module load ic/6.17.701
setenv CDS_LOAD_ENV CSF
setenv CDS_USE_PALETTE

module load mmsim/15.10.514

module load incisive/14.20.003

#module load edi/14.1

# Synopsys
module load hspice/K-2015.06-3
setenv HSP_ADE_INTEG_HOME $HSP_HOME/interface

module load finesim/2012.12-SP3-2
#setenv FINESIM_ADEKIT_LOCATION

module load starrc/G-2012.06-SP3-3
setenv RCXT_HOME_DIR $SYNOPSYS_STARRC_DIR

module load vcs/K-2015.09-SP2-7

module load dc_shell/J-2014.09-SP3

module load icc/J-2014.09-SP3

module load pts/H-2012.12-SP2

# Mentor
module load calibre/2013.2

module load afs/2017.1
setenv AFS_ROOT /cad/mentor/2017.1/bda_root
set path=($path $AFS_ROOT/bin)
set path=($path /home/praina/local/bin)

# Mathworks
module load matlab/2018b-murmann

# TN28 Memory Compiler
#setenv MC2_INSTALL_DIR /tsmc28/libs/2016.10.07/tsn28hpld127spsram_20120200_130a_cec/TSMCHOME/sram/Compiler/tsn28hpld127spsram_20120200_130a/MC2_2012.02.00.c
#set path=($path $MC2_INSTALL_DIR/bin)
#setenv MC_HOME /tsmc28/libs/2016.10.07/tsn28hpld127spsram_20120200_130a_cec/TSMCHOME/sram/Compiler/tsn28hpld127spsram_20120200_130a/
# LICENSE SETTINGS
#if ($?LM_LICENSE_FILE) then
#    setenv LM_LICENSE_FILE ${LM_LICENSE_FILE}:/tsmc28/license/MC2_2012.02.00.c/license.dat
#else
#    setenv LM_LICENSE_FILE /tsmc28/license/MC2_2012.02.00.c/license.dat
#endif

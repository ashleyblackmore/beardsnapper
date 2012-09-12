#!/bin/bash
#
# ~BEARDSNAPPER~
#
# Idea taken from Víctor Martínez: https://github.com/knoopx
# Incorporates changes by iHiD (https://gist.github.com/3207743)
# Find this script on github at https://github.com/ashleyblackmore/beardsnapper
# Warning: this has only been tested on Ubuntu!

function pause() {
    read -p "$*"
}

func_apt-get() {
    sudo apt-get install streamer
}

func_pacman() {
    pacman -S streamer
}

func_yum() {
    yum install streamer
}

func_up2date() {
    up2date --install streamer
}

haveProg() {
    [ -x "$(which $1)" ]
}

echo 'WARNING: This will append to the end of your post-commit file, if it already exists. Back out'
echo 'now if you do not want this to occur.'
echo
echo 'If your camera resolution is not 1280x720, please change it in this script before continuing!'
echo
echo 'Additionally, this script _may_ require sudo/root user privilege, in order to install streamer.'
pause 'Press [Enter] key to continue...'

if haveProg apt-get ; then func_apt-get
elif haveProg pacman ; then func_pacman
elif haveProg yum ; then func_yum
elif haveProg up2date ; then func_up2date
else
    echo 'No package manager found. Please install streamer before executing this script again.'
fi

mkdir -p ~/.git_templates/hooks
bsnap=~/.git_templates/hooks/post-commit
touch $bsnap

echo -e '#!/bin/bash' > $bsnap
echo -e 'forked_image () {' >> $bsnap
echo -e '    mkdir -p ~/Pictures/beardsnaps' >> $bsnap
echo -e '    streamer -q -s 1280x720 -c /dev/video0 -b 16 -o ~/Pictures/beardsnaps/$(date +%s)_$(basename $PWD).jpeg &' >> $bsnap
echo -e '}' >> $bsnap
echo -e '' >> $bsnap
echo -e 'forked_image &' >> $bsnap

chmod +x $bsnap

git config --global init.templatedir '~/.git_templates'

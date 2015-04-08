#!/bin/bash
#
# ~BEARDSNAPPER~
#
# Idea taken from Víctor Martínez: https://github.com/knoopx
# Incorporates changes by iHiD (https://gist.github.com/3207743)
# Find this script on github at https://github.com/ashleyblackmore/beardsnapper
# Warning: this has only been tested on Ubuntu!

func_pause() {
    read -p "$*"
}

func_apt-get() {
    sudo apt-get install streamer
}

func_pacman() {
    sudo pacman -Syu streamer
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

echo 'WARNING: this will make a new git hooks dir - back out now if you do not want this to occur.'
echo
echo 'If your camera resolution is not 1920x1080, please change it in this script before continuing!'
echo
echo 'Additionally, this script requires sudo/root user privilege, in order to install streamer.'
func_pause 'Press [Enter] key to continue...'

if haveProg apt-get ; then func_apt-get
elif haveProg pacman ; then func_pacman
elif haveProg yum ; then func_yum
elif haveProg up2date ; then func_up2date
else
    echo 'No package manager found. Please install streamer before executing this script again.'
fi

mkdir -pv ~/.git/hooks/post-commit.d/
BSNAP=~/.git/hooks/post-commit.d/beardsnapper
touch $BSNAP

echo -e '#!/bin/bash -x' > $BSNAP
echo -e 'forked_image () {' >> $BSNAP
echo -e '    mkdir -p ~/Pictures/beardsnaps' >> $BSNAP
echo -e '    PICTURE_NAME=~/Pictures/beardsnaps/$(date +%s)_$(basename $PWD).jpeg' >> $BSNAP
echo -e '    export BSNAP_IMAGE_DIR=/media/ablackmore/beardsnaps' >> $BSNAP
echo -e '    streamer -q -s 1920x1080 -c /dev/video0 -j 100 -b 16 -o $BSNAP_IMAGE_DIR/$(date +%s)_$(basename $PWD).jpeg &' >> $BSNAP
echo -e '    echo "Beardsnap saved to $BSNAP_IMAGE_DIR/"' >> $BSNAP
echo -e '}' >> $BSNAP
echo -e '' >> $BSNAP
echo -e 'set -x' >> $BSNAP
echo -e 'forked_image &' >> $BSNAP

chmod +x $BSNAP

git config --global init.templatedir '~/.git'

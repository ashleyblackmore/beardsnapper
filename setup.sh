#!/bin/bash
#
# ~BEARDSNAPPER~
#
# Inspired by Víctor Martínez: https://github.com/knoopx
# Template checks are based on code from Ionica Bizau https://github.com/IonicaBizau
# Incorporates changes by iHiD (https://gist.github.com/3207743)
#
# Find this script on github at https://github.com/ashleyblackmore/beardsnapper
#
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

if ! haveProg sed ; then
    echo 'Could not find perl Please install before executing this script again.'
fi


if haveProg apt-get ; then func_apt-get
elif haveProg pacman ; then func_pacman
elif haveProg yum ; then func_yum
elif haveProg up2date ; then func_up2date
else
    echo 'No package manager found. Please install streamer before executing this script again.'
fi

git_templates_dir=$(git config --global --get init.templatedir);
if [ $? -ne 0 ]; then
    # Create a new global templatedir if there are none
    git_templates_dir="${HOME}/.git-templates"
    git config --global init.templatedir "$git_templates_dir" && echo "Set new global git template dir at ${git_templates_dir}"
fi
git_hooks_dir="${git_templates_dir}/hooks"
post_commit_path="${git_hooks_dir}/post-commit"

mkdir -p "$git_hooks_dir"

BSNAP_HOOK=$(cat <<EOF
### beardsnapper hook (begin) ###
# make the image dir
BSNAP_IMAGE_DIR=~/beardsnaps
mkdir -p \$BSNAP_IMAGE_DIR

forked_image () {
    # take a picture from the webcam
    streamer -q -s 1920x1080 -c /dev/video0 -j 100 -b 16 -o \$BSNAP_IMAGE_DIR/\$(date +%s)_\$(basename \$PWD).jpeg &
    echo "Beardsnap saved to \$BSNAP_IMAGE_DIR/"
}

forked_image &
### beardsnapper hook (end) ###
EOF
);

if [ ! -f "$post_commit_path" ]; then
    printf "#!/bin/sh\n%s" "$BSNAP_HOOK" > "$post_commit_path" \
        && chmod +x "$post_commit_path" \
        && echo "Successfully set up beardsnapper hook at ${post_commit_path}." \
        && exit 0
else
    # Remove any previous git-stats hook code blocks
    sed -i '/### beardsnapper hook (begin) ###/,/### beardsnapper hook (end) ###/d' $post_commit_path
    printf "%s\n" "$BSNAP_HOOK" >> "$post_commit_path" \
        && echo "Successfully set up beardsnapper hook at ${post_commit_path}." \
        && exit 0
fi

git config --global init.templatedir '~/.git'

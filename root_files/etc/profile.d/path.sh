# If it exists and is a directory & if it is not already in your $PATH
# then export it to your $PATH.

FOLDERTOADD="/opt/bin"

if [[ -d "$FOLDERTOADD" && -z $(echo $PATH | grep -o "$FOLDERTOADD") ]]
then
    export PATH="${PATH}:$FOLDERTOADD"
fi

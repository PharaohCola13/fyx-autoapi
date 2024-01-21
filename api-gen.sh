#!/bin/bash

#> file: ./entrypoint.sh
#> synopsis: Generates skeleton docstrings for code
#> author: PharaohCola13 <academic@sriley.dev>

WDIR=$INPUT_DIR
ODIR=$(realpath $WDIR/../docsrc)
IGNORE=$(realpath $WDIR/.ignore)

DETAIL="detail: "
RETURN="return (type): "
METHOD="method: "
FNTEST="test-method:"

FILE="file: "
SYNOPSIS="synopsis: "
AUTHOR="author: "

TITLE="API Reference"

repeat(){
    for ((i = 0; i < $2; i++)); do echo -n "$1"; done
}

topwrite() {
    [ "$(wc -l < $2)" -gt 0 ] || printf '\n' >> $2
    if [ $(cat $2 | grep -c "$FILE") -eq 0 ]; then
        sed -i -e "1i$1> $FILE $2" $2
    fi
    if [ $(cat $2 | grep -c "$SYNOPSIS") -eq 0 ]; then
        sed -i -e "2i$1> $SYNOPSIS" $2
    fi
    if [ $(cat $2 | grep -c "$AUTHOR") -eq 0 ]; then
        sed -i -e "3i$1> $AUTHOR $FYX_USERNAME <$FYX_EMAIL>" $2
    fi
}

IGSTR=""
if [[ -e $IGNORE ]]; then
    echo -e ".ignore file detected"
    while read -r line; do
        Line="$(echo $line | tr -d '\r')"
        IGSTR+="-not -regex $WDIR/$Line.* "
    done < "$IGNORE"
fi

OUT=$(eval "find $WDIR $IGSTR -type f -print")
DIR=($OUT)

for i in ${DIR[@]}; do
    j=${i##*/}
    case ${j#*.} in 
        "py")
            c="#"
            topwrite $c $i
            ./style/style_py.sh $WDIR $i 'gen'
        ;;
        "r")
            c="#"
            topwrite $c $i
            ./style/style_r.sh $WDIR $i 'gen'
        ;;
        "rs")
            c="//"
            topwrite $c $i
            ./style/style_rust.sh $WDIR $i 'gen'
        ;;
        "pro")
            c=";"
            topwrite $c $i
            ./style/style_idl.sh $WDIR $i 'gen'
        ;;
        *)
            continue
        ;;
    esac
done


#!/bin/bash

#> file: ./entrypoint.sh
#> synopsis: Generates skeleton docstrings for code
#> author: PharaohCola13 <academic@sriley.dev>

WDIR=$INPUT_DIR
ODIR=$(realpath $WDIR/../docsrc)
IGNORE=$(realpath $WDIR/.ignore)
APIDOC=$(echo $ODIR/api-reference.rst)

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

if [ ! -e $ODIR ]; then
    mkdir $ODIR
fi
if [ ! -e $ODIR/../docs ]; then
    mkdir $ODIR/../docs
fi

if [ ! -e $APIDOC ]; then
    touch $APIDOC
fi

if [ ! -e $ODIR/index.rst ]; then
    touch $ODIR/index.rst
    HEADER="Application Documentation"
    echo -e "\n$(repeat "-" ${#HEADER})\n$HEADER\n$(repeat "-" ${#HEADER})" >> $ODIR/index.rst
    echo -e ".. toctree::\n\tapi-reference.rst" >> $ODIR/index.rst
fi 


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

echo -e "$(repeat "*" ${#TITLE})\n$TITLE\n$(repeat "*" ${#TITLE})" > $APIDOC

for i in ${DIR[@]}; do
    j=${i##*/}
    echo -e "\n$(repeat "-" ${#j})\n$j\n$(repeat "-" ${#j})" >> $APIDOC
    case ${j#*.} in
        "py")
            ./style/style_py.sh $WDIR $i 'ref'
        ;;
        "r")
            ./style/style_r.sh $WDIR $i 'ref'
        ;;
        "rs")
            ./style/style_rust.sh $WDIR $i 'ref'
        ;;
        "pro")
            ./style/style_idl.sh $WDIR $i 'ref'
        ;;
        *)
            continue
        ;;
    esac
done

if [ ! -e $ODIR/conf.py ]; then
    echo -e "import os\nimport sys" > $ODIR/conf.py
    echo -e "sys.path.insert(0, os.path.abspath('../'))" >> $ODIR/conf.py
    echo -e "project = ''" >> $ODIR/conf.py
    echo -e "copyright = '$(date +%Y), $FYX_USERNAME'" >> $ODIR/conf.py
    echo -e "author = '$FYX_USERNAME'" >> $ODIR/conf.py
    echo -e "version = ''" >> $ODIR/conf.py
    echo -e "release = ''" >> $ODIR/conf.py
    
    echo -e "html_title = ''" >> $ODIR/conf.py
    echo -e "html_theme = 'sphinx_rtd_theme'" >> $ODIR/conf.py
    
fi

python3 -m sphinx -T -E -b latex $ODIR $ODIR/../docs/
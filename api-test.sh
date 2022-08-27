#!/bin/bash

#> file: ./entrypoint.sh
#> synopsis: Generates skeleton docstrings for code
#> author: PharaohCola13 <academic@sriley.dev>

WDIR=$INPUT_DIR
ODIR=$(realpath $WDIR/../tests)
IGNORE=$(realpath $WDIR/.ignore)

DETAIL="detail: "
RETURN="return (type): "
METHOD="method: "
FNTEST="test-method:"

FILE="file: "
SYNOPSIS="synopsis: "
AUTHOR="author: "

TITLE="API Reference"

if [ ! -d $ODIR ]; then
    mkdir $ODIR
fi

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

#generate testing files [Python/R]
#rm -r $WDIR/../testthat
for i in ${DIR[@]}; do
    j=${i##*/}
    case ${j#*.} in 
        'r')
            if [ ! -d $ODIR/testthat ]; then
                mkdir $ODIR/testthat
            fi
            TNAME=$ODIR/testthat/test_$j
            if [ ! -e $TNAME ]; then
                touch $TNAME
                echo "library(testthat)" > $TNAME
                topwrite '#' $TNAME

                while read -r line; do
                    lzw=$(echo -e "$line" | tr -d '[:space:]')
                    case $lzw in 
                    *"<-function"*)
                        func=${lzw/<-function/}
                        func=${func/{/}
                        FUNCTION=$(echo -e "${func}" | tr -d '[:space:]')

                        A=$(echo $line | cut -d "(" -f2 | cut -d ")" -f1)
                        IFS=',' read -a array <<< "$A"

                        N=$(grep -Fn "$line" $i | cut -d ":" -f1)
                        M=$(($N + 4 + ${#array[@]}))
                        FULLMETH=$(sed -n "$N,$M{/$FNTEST/{=;p}}" $i)
                        TESTMETH=$(echo -e $FULLMETH | cut -d ":" -f2 | tr -d ' ' | tr -d '\n')
                        echo -e "testthat::test_that(\"\", {\n\ttestthat::$TESTMETH( \n\t\t$FUNCTION,\n\n\t\t)\n})" >> $TNAME
                    ;;
                    *)
                        continue
                    esac
                done < "$i"
            fi
        ;;
        'py')
            if [ ! -d $ODIR/test ]; then
                mkdir $ODIR/test
            fi

            if [ ! -e $ODIR/test/test_$j ]; then
                touch $ODIR/test/test_$j
            fi
        ;;
    esac 
done

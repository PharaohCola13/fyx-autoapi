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
    echo -e $i
    j=${i##*/}
    case ${j#*.} in 
        'r' | 'py')
            topwrite '#' $i
            while IFS= read -rs line; do
                lzw=$(echo -e "$line" | tr -d '[:space:]')
                case $lzw in 
                $"class"*)
                    A=$(echo $line | cut -d "(" -f2 | cut -d ")" -f1)
                    IFS=',' read -a array <<< "$A"

                    N=$(grep -Fn "$line" $i | cut -d ":" -f1)
                    M=$(($N + 3 + ${#array[@]}))

                    if [[ -z $(sed -n "$N,$M{/$METHOD/{=;p}}" $i) ]]; then
                        sed -i "/$line/a #> $METHOD" $i
                    fi

                    if [[ -z $(sed -n "$N,$M{/$DETAIL/{=;p}}" $i) ]]; then
                        sed -i "/$line/a #> $DETAIL" $i
                    fi
                ;;
                *"<-function"* | $"def"*)
                    A=$(echo $line | cut -d "(" -f2 | cut -d ")" -f1)
                    IFS=',' read -a array <<< "$A"

                    N=$(grep -Fn "$line" $i | cut -d ":" -f1)
                    M=$(($N + 4 + ${#array[@]}))
                    if [[ -z $(sed -n "$N,$M{/$FNTEST/{=;p}}" $i) ]]; then
                        sed -i "/$line/a #> $FNTEST" $i
                    fi

                    if [[ -z $(sed -n "$N,$M{/$RETURN/{=;p}}" $i) ]]; then
                        sed -i "/$line/a #> $RETURN" $i
                    fi

                    for val in $(echo "${array[@]} " | tac -s ' '); do
                        if [ $(echo "$val" | grep -c "=" ) -ne 0 ]; then
                            default=$(echo "$val" | cut -d "=" -f2 | tr -d "\"")
                            val=$(echo "$val" | cut -d "=" -f1)
                            ARGS="param type \[$default\] $val:"
                        else
                            ARGS="param type $val:"
                        fi

                        if [[ -z $(sed -n "$N,$M{/$ARGS/{=;p}}" $i) ]]; then
                            sed -i "/$line/a #> $ARGS" $i
                        fi
                    done

                    if [[ -z $(sed -n "$N,$M{/$DETAIL/{=;p}}" $i) ]]; then
                        sed -i "/$line/a #> $DETAIL" $i
                    fi
                esac
            done < "$i"
            ;;
        'rs') 
            topwrite '//' $i
            while read -r line; do
                case $line in 
                $"fn"*)
                    A=$(echo $line | cut -d "(" -f2 | cut -d ")" -f1)
                    IFS=',' read -a array <<< "$A"

                    N=$(grep -Fn "$line" $i | cut -d ":" -f1)
                    M=$(($N + 3 + ${#array[@]}))

                    if [[ -z $(sed -n "$N,$M{/$RETURN/{=;p}}" $i) ]]; then
                        sed -i "/$line/a //> $RETURN" $i
                    fi

                    for val in $(echo "${array[@]} " | tac -s ' '); do
                        type=$(echo "$val" | cut -d ":" -f2)
                        val=$(echo "$val" | cut -d ":" -f1)

                        ARGS="param $type $val:"

                        if [[ -z $(sed -n "$N,$M{/$ARGS/{=;p}}" $i) ]]; then
                            sed -i "/$line/a //> $ARGS" $i
                        fi
                    done

                    if [[ -z $(sed -n "$N,$M{/$DETAIL/{=;p}}" $i) ]]; then
                        sed -i "/$line/a //> $DETAIL" $i
                    fi
                esac
            done < "$i"
            ;;
        *)
            continue
            ;;
    esac
done


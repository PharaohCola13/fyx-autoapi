#!/bin/bash

#> file: ./autodoc.sh
#> synopsis: Generates skeleton docstrings for code
#> author: PharaohCola13 <academic@sriley.dev

DETAIL="detail: "
RETURN="return (type): "


FILE="file: "
SYNOPSIS="synopsis: "
AUTHOR="author: "

topwrite() {
    if [ $(cat $2 | grep -c "$FILE") -eq 0 ]; then
        sed -i "1i$1> $FILE $2" $2
    fi
    if [ $(cat $2 | grep -c "$SYNOPSIS") -eq 0 ]; then
        sed -i "2i$1> $SYNOPSIS" $2
    fi
    if [ $(cat $2 | grep -c "$AUTHOR") -eq 0 ]; then
        AUTHOR="$1> author: $FYX_USERNAME <$FYX_EMAIL>"
        sed -i "3i$AUTHOR" $2
    fi
}

for i in ./*; do
    j=${i##*/}
    case ${j#*.} in 
        'r' | 'py')
            topwrite '#' $i
            while read -r line; do
                case $line in 
                *"function"* | *"def"*)
                    A=$(echo $line | cut -d "(" -f2 | cut -d ")" -f1)
                    IFS=',' read -a array <<< "$A"

                    N=$(grep -Fn "$line" $i | cut -d ":" -f1)
                    M=$(($N + 3 + ${#array[@]}))

                    if [[ -z $(sed -n "$N,$M{/$RETURN/{=;p}}" $i) ]]; then
                        sed -i "/$line/a #> $RETURN" $i
                    fi

                    for val in $(echo "${array[@]} " | tac -s ' '); do
                        if [ $(echo "$val" | grep -c "=" ) -ne 0 ]; then
                            default=$(echo "$val" | cut -d "=" -f2 | tr -d "\"")
                            val=$(echo "$val" | cut -d "=" -f1)
                            ARGS="param (type) $val ($default):"
                        else
                            ARGS="param (type) $val:"
                        fi

                        if [[ -z $(sed -n "$N,$M{/$ARGS/{=;p}}" $i) ]]; then
                            echo "$ARGS"
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
                *"function"*)
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

                        ARGS="param ($type) $val:"

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
        "sh")
            topwrite '#' $i
            ;;
        *)
            continue
            ;;
    esac
done

#!/bin/bash

#> file: ./entrypoint.sh
#> synopsis: Generates skeleton docstrings for code
#> author: PharaohCola13 <academic@sriley.dev>

WDIR=$1
ODIR=$(realpath $WDIR/../docsrc)
IGNORE=$(realpath $WDIR/.ignore)
APIDOC=$(echo $ODIR/api-reference.rst)

DETAIL="detail: "
RETURN="return (type): "
METHOD="method: "
FNTEST="test-method:"

c="//"
case $3 in
'ref')
    while IFS= read -rs line; do
        lzw=$(echo -e "$line" | tr -d '[:space:]')
        case $lzw in
        $"$c>"*[a-z]*":"* )
            if [[ $(echo $lzw | cut -d ":" -f1) != $(echo "$c>$FNTEST" | tr -d '[:space:]' | cut -d ':' -f1) ]]; then
                Line=$(echo $line | cut -d '>' -f2 | sed "s/^[ \t]*//")
                echo -e "\t:${Line}" >> $APIDOC
            fi
        ;;
        $"fn"*)
            func=${lzw/->function/}
            func=${func/fn/}
            func=${func/{/}
            func=$(echo -e "${func}" | tr -d '[:space:]')
            echo -e "\n.. function:: ${func}\n" >> $APIDOC
        ;;
        esac
    done < "$2"
;;
'gen')
    while IFS= read -rs line; do
        lzw=$(echo -e "$line" | tr -d '[:space:]')
        case $lzw in
        $"fn"*)
            A=$(echo $line | cut -d "(" -f2 | cut -d ")" -f1)
            IFS=',' read -a array <<< "$A"

            N=$(grep -Fn "$line" $2 | cut -d ":" -f1)
            M=$(($N + 3 + ${#array[@]}))

            if [[ -z $(sed -n "$N,$M{/$RETURN/{=;p}}" $2) ]]; then
                sed -i "/$line/a //> $RETURN" $2
            fi

            for val in $(echo "${array[@]} " | tac -s ' '); do
                type=$(echo "$val" | cut -d ":" -f2)
                val=$(echo "$val" | cut -d ":" -f1)

                ARGS="param $type $val:"

                if [[ -z $(sed -n "$N,$M{/$ARGS/{=;p}}" $2) ]]; then
                    sed -i "/$line/a //> $ARGS" $2
                fi
            done

            if [[ -z $(sed -n "$N,$M{/$DETAIL/{=;p}}" $2) ]]; then
                sed -i "/$line/a //> $DETAIL" $2
            fi
        esac
    done
esac
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

c="#"
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
        *"<-function"*)
            func=${lzw/<-function/}
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
        *"<-function"*)
            A=$(echo $line | cut -d "(" -f2 | cut -d ")" -f1)
            IFS=',' read -a array <<< "$A"

            N=$(grep -Fn "$line" $2 | cut -d ":" -f1)
            M=$(($N + 4 + ${#array[@]}))
            if [[ -z $(sed -n "$N,$M{/$FNTEST/{=;p}}" $2) ]]; then
                sed -i "/$line/a #> $FNTEST" $2
            fi

            if [[ -z $(sed -n "$N,$M{/$RETURN/{=;p}}" $2) ]]; then
                sed -i "/$line/a #> $RETURN" $2
            fi

            for val in $(echo "${array[@]} " | tac -s ' '); do
                if [ $(echo "$val" | grep -c "=" ) -ne 0 ]; then
                    default=$(echo "$val" | cut -d "=" -f2 | tr -d "\"")
                    val=$(echo "$val" | cut -d "=" -f1)
                    ARGS="param type \[$default\] $val:"
                else
                    ARGS="param type $val:"
                fi

                if [[ -z $(sed -n "$N,$M{/$ARGS/{=;p}}" $2) ]]; then
                    sed -i "/$line/a #> $ARGS" $2
                fi
            done

            if [[ -z $(sed -n "$N,$M{/$DETAIL/{=;p}}" $2) ]]; then
                sed -i "/$line/a #> $DETAIL" $2
            fi
        esac
    done
esac
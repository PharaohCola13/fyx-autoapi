#!/bin/sh


WDIR='./test' #$INPUT_DIR
ODIR=$(realpath $WDIR/../docsrc)
IGNORE=$(realpath $WDIR/.ignore)
APIDOC=$(echo $ODIR/api-reference.rst)

DETAIL="detail: "
RETURN="return (type): "
METHOD="method: "
FNTEST="test-method:"

FILE="file: "
LANG="lang: "
SYNOPSIS="synopsis: "
AUTHOR="author: "

TITLE="API Reference"

repeat(){
    for ((i = 0; i < $2; i++)); do echo -n "$1"; done
}

topwrite() {
    [ "$(wc -l < $2)" -gt 0 ] || printf '\n' >> $2
    if [ $(cat $2 | grep -c "$FILE") -eq 0 ]; then
        sed -i -e "1i$1> $FILE ${2%.*}" $2
    fi
    if [ $(cat $2 | grep -c "$LANG") -eq 0 ]; then
        sed -i -e "2i$1> $LANG $3" $2
    fi
    if [ $(cat $2 | grep -c "$SYNOPSIS") -eq 0 ]; then
        sed -i -e "3i$1> $SYNOPSIS" $2
    fi
    if [ $(cat $2 | grep -c "$AUTHOR") -eq 0 ]; then
        sed -i -e "4i$1> $AUTHOR $FYX_USERNAME <$FYX_EMAIL>" $2
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

case $1 in
    "gen")
        for i in ${DIR[@]}; do
            echo $i
            ii=${i##*/}
            case ${ii#*.} in
                "py") lang="python" ;;
                "r") lang="r";;
                "pro") lang="idl";;
                *) continue ;;
            esac
            c=$(jq ".lang.$lang.comment" ./style.json | tr -d '\"' )
            
            IFS="," test=($(jq ".lang.$lang.function.tag" ./style.json | tr -d '[]\"[:space:]'))
            trash=($(jq ".lang.$lang.function.throwaway" ./style.json | tr -d '[]\"[:space:]'))

            argFormat=$(jq ".lang.$lang.function.arg.format" ./style.json | tr -d "\"")
            argSep=$(jq ".lang.$lang.function.arg.sep" ./style.json | tr -d "\"")

            defaultDiv=${argFormat##*"argName"}
            defaultDiv=${defaultDiv:0:1}
            topwrite $c $i $lang            
            while IFS= read -rs line; do
                for (( j=0; j < ${#test[@]}; j++)); do
                    lzw=$(echo -e "$line" | tr -d '[:blank:]')
                    param=$(echo ${test[$j]} | tr -d '[:blank:]')
                    case $lzw in
                        *"$param"*)   
                            unset IFS
                            if [[ ${argFormat:(-1)} == "!" ]]; then
                                func=${lzw/$param/}
                                for (( k=0; k < ${#trash[@]}; k++)); do
                                    func=${func/$(echo ${trash[$k]} | tr -d '[:blank:]')}
                                done
                                A=$(echo $func | cut -d "," -f2- )
     
                            else
                                A=$(echo $line | cut -d ${argFormat:0:1} -f2  | cut -d ${argFormat:(-2):(-1)} -f1 )
                                       
                            fi
                            IFS=${argSep} read -a array <<< "$A"
                            unset IFS
                            echo ${#array[@]}        

                            N=$(grep -Fn "$line" $i | cut -d ":" -f1)
                            M=$(($N + 4 + ${#array[@]}))

                            if [[ -z $(sed -n "$N,$M{/$FNTEST/{=;p}}" $i) ]]; then
                                echo "IF4"
                                sed -i '/'"$line"'/a '"$c"'> '"$FNTEST" $i
                            fi

                            if [[ -z $(sed -n "$N,$M{/$RETURN/{=;p}}" $i) ]]; then
                                echo "IF3"
                                sed -i '/'"$line"'/a '"$c"'> '"$RETURN" $i
                            fi

                            for val in $(echo "${array[@]}" | tac -s ' '); do
                                if [ $(echo "$val" | grep -c $defaultDiv ) -ne 0 ]; then
                                    default=$(echo "$val" | cut -d $defaultDiv -f2 | tr -d "\"")
                                    val=$(echo "$val" | cut -d $defaultDiv -f1)
                                    ARGS="param type \[$default\] $val:"
                                else
                                    ARGS="param type $val:"
                                fi
                                if [[ -z $(sed -n "$N,$M{/$ARGS/{=;p}}" $i) ]]; then
                                    echo "IF2"
                                    sed -i '/'"$line"'/a '"$c"'> '"$ARGS" $i
                                fi
                            done
                            
                            if [[ -z $(sed -n "$N,$M{/$DETAIL/{=;p}}" $i) ]]; then
                                echo "IOF1"
                                sed -i '/'"$line"'/a '"$c"'> '"$DETAIL" $i
                            fi
                            break
                        ;;    
                        *)
                            continue
                        ;;
                    esac
                done  
            done     < "$i"       
        done
    ;; 
    "ref" ) 
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

        echo -e "$(repeat "*" ${#TITLE})\n$TITLE\n$(repeat "*" ${#TITLE})" > $APIDOC

        for i in ${DIR[@]}; do
            ii=${i##*/}
            echo -e "\n$(repeat "-" ${#ii})\n$ii\n$(repeat "-" ${#ii})" >> $APIDOC
            case ${ii#*.} in
                "py") lang="python" ;;
                "r") lang="r";;
                "pro") lang="idl";;
                *) continue ;;
            esac
            c=$(jq ".lang.$lang.comment" ./style.json | tr -d '\"' )
            test=($(jq ".lang.$lang.function.tag" ./style.json | tr -d '[]\"[:space:]'))
            trash=($(jq ".lang.$lang.function.throwaway" ./style.json | tr -d '[]\"[:space:]'))
            IFS=','
            echo ${test[@]}
            while IFS= read -rs line; do
                lzw=$(echo -e "$line" | tr -d '[:space:]')
                for (( j=0; j < ${#test[@]}; j++)); do
                    param=$(echo ${test[$j]} | tr -d '[:blank:]')
                    case $lzw in
                        $"$c>"*[a-z]*":"* )
                            if [[ $(echo $lzw | cut -d ":" -f1) != $(echo "$c>$FNTEST" | tr -d '[:space:]' | cut -d ':' -f1) ]]; then
                                Line=$(echo $line | cut -d '>' -f2- | sed "s/^[ \t]*//")
                                echo -e "\t:${Line}" >> $APIDOC
                            fi
                            break
                        ;;
                        *"$param"*)          
                            func=${lzw/$param/}
                            echo $func
                            for (( k=0; k < ${#trash[@]}; k++)); do
                                func=${func/$(echo ${trash[$k]} | tr -d '[:blank:]')}
                            done
                            echo -e "\n.. function:: ${func}\n" >> $APIDOC
                            break
                        ;;    
                        *)
                            continue
                        ;;
                    esac
                done
            done < "$i"
        done

    ;; 
    "all" )
        /entrypoint.sh 'gen'
        /entrypoint.sh 'ref'
    ;;
esac 

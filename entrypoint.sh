#!/bin/sh

case $1 in
    "gen")
        /api-gen.sh 
    ;; 
    "ref" ) 
        /api-ref.sh 
    ;; 
    "all" )
        /api-gen.sh
        /api-ref.sh
    ;;
esac 

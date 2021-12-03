DATA="$1"

function common() {
    num0="$(grep -c "^$10" "$DATA")"
    num1="$(grep -c "^$11" "$DATA")"
    if (( num0 > num1 )); then echo 0; else echo 1; fi
}

function uncommon() {
    num0="$(grep -c "^$10" "$DATA")"
    num1="$(grep -c "^$11" "$DATA")"
    if (( num0 == 0 )); then echo 1; else
    if (( num1 == 0 )); then echo 0; else
        if (( num0 > num1 )); then echo 1; else echo 0; fi
    fi; fi
}

first_line="$(head -n1 $DATA)"

function repeat() {
    solution=""
    for i in `seq 1 ${#first_line}`; do
        solution="$solution$($1 $solution)"
    done
    echo $solution
}

echo "ibase=2; $(repeat common) * $(repeat uncommon)" | bc

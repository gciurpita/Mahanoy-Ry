
awk '
/atlas/ {
    while (getline)  {
        if (/^# --/)
            break

        if (! NF)
            continue

        part [$2, $3] = $1
    }
}

# --------------------------------------------------------------------
/pennisula/ {
    label = $0
    while (getline)  {
        if (! NF)
            continue

        frog [$2]++
        side [$3]++
        to [$2, $3] += $1

        print
    }
}

# --------------------------------------------------------------------
END {
    printf "\nTotal\n"
    for (fn in frog)  {
        for (sd in side)  {
            if (to [fn, sd])  
                printf " %6d %6s %s %s\n", to [fn, sd], fn, sd, part[fn, sd]
            total += to [fn, sd]
        }
    }
    printf " %6d\n", total
}' $* << **END**

    #6 LH   #6 RH    #4 LN    #4 RH
    4        4                           stations
                      4        4         stations spurs
             6                           staging
    1                 1        1         loop
 ----------- -------- -------- ------
    5        10       5        5
    25

# ------------------------------------------------------------------------------
lengths
    7.0             atlas
    6.25            peco

# ------------------------------------------------------------------------------
atlas
    500     x25 flex  83           $149.99  $147.15

    505     #6 lh     83    $29.95
    506     #6 rh     83    $29.95

    560     wye       83    $28.95

    561     #4 lh     83    $28.95  $20.21   $20.99
    562     #4 rh     83    $28.95  $20.21   $20.99

    563     #6 lh     83    $28.95  $20.21p  $20.99
    564     #6 rh     83    $28.95  $20.21p  $20.99

    565     #8 rh     83    $29.95  $20.96   $20.99
    566     #8 rh     83    $29.95  $20.96   $20.99

    595     30/22 rh  83    $32.95  $22.46   $22.99
    596     30/22 lh  83    $32.95  $22.46   $22.99

# -- 23/1/22 -------------------------------------------------------------------

pennisula
    2   curve rh
    6   #6 rh   staging ladders

    1   #6 lh   far-side station
    1   #6 rh   far-side station
    2   #4 rh   far-side industries

    2   #4 lh   loop industries
    1   #4 rh

    1   #6 lh   near-side station
    1   #6 rh   near-side station
    2   #4 lh   near-side industries
    1   #4 rh

train world order 000474814
tony's trains     1023020885
**END**

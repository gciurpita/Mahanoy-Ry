
awk '
NF && !/#/ {
    print

    if ("_" != $1)  {
        spots += $2

        for (i = 1; i <= length($1); i++)
            types [substr($1, i, 1)] += $2 /length($1)
    }
}

END {
    spotsOcc = 0.5 * spots
    carTot   = int(0.5 +(3 *spots/2))

    printf "\n"
    printf " %6d %9s  spots\n", spots, ""
    printf " %6d %9s  spots occupied\n", spotsOcc, ""
    printf " %6d %9s  #cars\n", carTot, ""
    printf " %6.1f %9s  min%\n", 100 /carTot, ""

    printf "\n"
    for (type in types)  {
        pct      = 100*types [type]/spots
        pctTot  += pct

      # nCar     = 0.5 +carTot *pct/100
        nCar     =      carTot *pct/100
        nCarTot += nCar

        printf " %6d %5.1f%% %3d %s\n", types [type], pct, nCar, type
    }
    printf "        %5.1f%% %3d\n", pctTot, nCarTot
}' mahanoy.loc

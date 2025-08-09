# simple cnt of # of cars and # of spots

awk '
! NF || /^#/  { next }

match(FILENAME,"IntrRd") {
    intRd [$1]++
    fulName [$1] = substr($0, index($0, $2))
}

# ------------------------------------------------
#   X WM      26538
match (FILENAME, "car")  {
    if (/type/)
        next
    nCar ++

    if ("RDG" == $2)
        rdgCar++
    else if (intRd [$2])
        intCar++
    next
}

# ------------------------------------------------
#   BRX  1  G  Bradley Beer Storage
match (FILENAME, "loc")  {
    if (/_/)
        next
    nLoc ++
    town [$3] ++
    next
}

# ------------------------------------------------
END {

    printf "Layout stats:\n"

    printf " %6d  cars\n", nCar
    printf " %6d    RDG cars\n",     rdgCar
    printf " %6d    IntrChg cars\n", intCar
    printf " %6d    foreign cars\n", nCar - rdgCar - intCar

    printf " %6d  locs\n", nLoc
    for (t in town)
        printf " %6d    %s\n", town [t], t

    pctOcc = 100 *(nCar/3) /nLoc
    printf " %6d%% occupied\n",  pctOcc
    for (t in town)
        printf " %6d    %s\n", 0.5 + town [t] *pctOcc/100, t
}' rdgIntrRds.txt  mahanoy.car mahanoy.loc

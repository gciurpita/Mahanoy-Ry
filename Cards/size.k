# simple cnt of # of cars and # of spots

awk '
! NF || /^#/  { next }

match(FILENAME,"IntrRd") {
    intRd [$1]++
    fulName [$1] = substr($0, index($0, $2))
}

# ------------------------------------------------
# type C   Cement
#   X WM      26538
match (FILENAME, "car")  {
    if (/type/)  {
        typeName [$2] = substr($0, index($0, $3))
        next
    }

    nCar ++
    carType [$1]++

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
    town [$3] ++
    locTown [++nLoc] = $3
    locName [nLoc]   = substr($0, index($0, $4))
    next
}

# ------------------------------------------------
END {

    printf "Layout stats:\n"

    printf " %6d  cars\n", nCar
    printf " %6d    RDG cars\n",     rdgCar
    printf " %6d    IntrChg cars\n", intCar
    printf " %6d    foreign cars\n", nCar - rdgCar - intCar
    printf "\n"

    for (t in carType)
        printf " %6d      %s\n", carType [t], typeName [t]
    printf "\n"

    printf " %6d  locs\n", nLoc
    for (t in town)  {
        printf " %6d    %s\n", town [t], t
        for (n = 1; n <= nLoc; n++)
            if (t == locTown [n])
                printf "%12s %s\n", "", locName [n]
    }
    printf "\n"

    Nset   = 4
    printf " %6d   Nset\n",  Nset
    pctOcc = 100 *(nCar/Nset) /nLoc
    printf " %6d%%  occupied\n",  pctOcc
    for (t in town)
        printf " %6d    %s\n", 0.5 + town [t] *pctOcc/100, t
}' rdgIntrRds.txt  mahanoy.car mahanoy.loc

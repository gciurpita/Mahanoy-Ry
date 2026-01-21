# simple cnt of # of cars and # of spots

awk '
BEGIN {
    Ratio = 3
    nCar  = 0
    nLoc  = 0
}

# ------------------------------------------------
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
    locCars [nLoc]   = $2
    locTown [nLoc]   = $3
    locName [nLoc] = substr($0, index($0, $4))

    nSpots += locCars [nLoc]
  # printf " %6s %d %s %s\n", "", locCars [nLoc], locTown [nLoc], locName [nLoc]
    nLoc++
    next
}

# ------------------------------------------------
function dispLoc () {
    printf "dispLoc:\n"
    for (n = 1; n < nLoc; n++)
        printf " %6s  %d  %s  %s\n", "", locCars [n], locTown [n], locName [n]
}

# ------------------------------------------------
function cars () {
    printf " Cars:\n", nCar

    printf "   Roadnames\n"
    printf " %6d   %2d %% RDG cars\n",     rdgCar, rdgCar *100/nCar
    printf " %6d   %2d %% IntrChg cars\n", intCar, intCar *100/nCar
    printf " %6d   %2d %% foreign cars\n", \
                nCar - rdgCar - intCar, (nCar - rdgCar - intCar) *100/nCar
    printf " %6d\n", nCar
    printf "\n"

    printf "   Types\n"
    cnt = 0
    for (t in carType)  {
        printf " %6d   %s\n", carType [t], typeName [t]
        cnt += carType [t]
    }
    printf " %6d\n", cnt
    printf "\n"
}

# ------------------------------------------------
function locs ()  {
    printf " Locations: nLoc %d, nSpots %s\n", nLoc, nSpots
    total = 0
    for (t in town)  {
        nSpot [t] = 0
      # printf " %6d  %s\n", town [t], t
        for (n = 0; n < nLoc; n++)
            if (t == locTown [n])  {
                printf " %6d   %s\n", locCars [n], locName [n]
                nSpot [t]   += locCars [n]
            }
        printf " %6d\n", nSpot [t]
        printf "\n"
        totSpot += nSpot [t]
    }
    printf " %6d/%2d  Total spots/locations\n", totSpot, nLoc
    printf "\n"
}

# ------------------------------------------------
function sizing () {
    pctOcc = 100 *(nCar/Ratio) /nSpots

    printf " Local Size:\n"
    printf " %6d   Ratio - spotted/train/staged\n",  Ratio
    printf " %6d   Cars\n",  nCar
    printf " %6d   Spots\n", totSpot
    printf " %6d   %% spots occupied\n",  pctOcc
    for (t in town)  {
        occ = 0.5 + nSpot [t] *pctOcc/100
        printf " %6d   %s spots %2d\n", occ, t, nSpot [t]
    }
}

# --------------------------------------------------------------------
END {
  # dispLoc();

    cars()
    locs()
    sizing()

}' $* rdgIntrRds.txt  mahanoy.car mahanoy.loc

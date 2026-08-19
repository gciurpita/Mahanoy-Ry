# simple cnt of # of cars and # of spots

awk '
BEGIN {
    nCar  = 0
    nLoc  = 0
    C     = 0;
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

    if ("N" == $1)  {  // skip cabeese
      # print
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

    nSpot [$3] += locCars [nLoc]
    nSpots     += locCars [nLoc]

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
      # totSpot += nSpot [t]
    }
    printf " %6d/%2d  Total spots/locations\n", nSpots, nLoc
    printf "\n"
}

# ------------------------------------------------
function sizing (HoldPickup) {
    if (C)
        nCar = C

    Ratio = 3

    printf "------------------------------\n"
    printf " Local Size:"
    if (HoldPickup)  {
        printf " Hold/Pickup"
        Ratio = 4
    }
    printf "\n"

    printf " %6d    Cars\n",  nCar
    printf " %6d    Ratio\n", Ratio

    spotted = nCar  / Ratio
    if (HoldPickup) 
        spotted *= 2

    pctOcc  = 100 *spotted/nSpots
    pctSw   = pctOcc
    if (HoldPickup) 
        pctSw   /= 2

    printf " %8.1f  Occupied Spots (nCar/Ratio)\n", spotted
    printf "\n"


    printf " %6d    Spots\n", nSpots
    printf " %6d %%  Occupancy\n", pctOcc
    printf "\n"

  # printf " %8.1f  cars switched\n", (Ratio-2) *nCar/Ratio
  # printf " %8.1f  cars in staging\n", (Ratio-2) *nCar/Ratio
    printf " %8.1f  cars switched\n",   nCar/Ratio
    printf " %8.1f  cars in staging\n", nCar/Ratio
    printf "\n"

    printf "  Train Size\n"
    sum = 0;
    for (t in town)  {
        occ = 0.5 + nSpot [t] *pctOcc/100
        sw  =       nSpot [t] *pctSw/100

        printf " %8.1f", sw
        printf " %3d",   nSpot [t] * pctOcc/100
        printf " %3d",   nSpot [t]
        printf " %s\n",  name  [t]

        sum   += sw
    }
    printf " %8.1f\n", sum
    printf "\n"
}

# --------------------------------------------------------------------
END {
    name ["G"]   = "Gilberton"
    name ["M"]   = "Maizeville"
    name ["MP"]  = "Mahanoy Plane"
    name ["EBR"] = "East Bear Ridge"

  # dispLoc();

    if (! S) {
        cars()
        locs()
    }
    sizing(0)
    sizing(1)
    printf "\n"
}' $* rdgIntrRds.txt  mahanoy.car mahanoy.loc

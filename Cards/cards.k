# script to create routings to each .loc for each .car

awk '
BEGIN {
    dbg= 0
    if (dbg) print "nu:"
    C = L = 0
    N = 4

        Normal    = "\033[0m"
        Bold      = "\033[1m"
        Faint     = "\033[2m"   # no effect
        Standout  = "\033[3m"   # no effect
        Underline = "\033[4m"
        Blink     = "\033[5m"
        Reverse   = "\033[6m"   # no effect

        Black     = "\033[30m"
        Red       = "\033[31m"
        Green     = "\033[32m"
        Yellow    = "\033[33m"
        Blue      = "\033[34m"
        Magenta   = "\033[35m"
        Cyan      = "\033[36m"
        White     = "\033[37m"
}

# ----------------------------------------------------------
filename != FILENAME {
    filename = FILENAME
    if (dbg)
        printf "# -------------------- %s --------------------\n", filename
}

# --------------------------------------
1 < dbg {   print }

# --------------------------------------
NF && match(FILENAME, "car") {
    if (/#/ || /type/ || "N" == $1)
        next

    if (dbg) print

    carType [C]   = $1
    carRoad [C]   = $2
    carNum  [C++] = $3
}

# --------------------------------------
#  BRSX 2  M  Maizeville Freight House

NF && match(FILENAME, "loc") {
    if (dbg) print

    if (/#/)
        next

    locType [L]   = $1
    locSize [L]   = $2
    locTown [L]   = $3
    locName [L++] = substr($0, index($0, $4))

    for (n = 1; n <= length(locType [L-1]); n++)  {
        t = substr(locType [L-1], n, 1)
        nLocType [t]++
        if (2 <dbg) printf "             %d %6s %s %2d\n", \
                            n, locType [L-1], t, locType [t]
    }

    towns [$3]++
}

# ----------------------------------------------------------
function dumpCars ()  {
    printf "dumpCars:\n"
    for (c = 0; c < C; c++)
        printf "   %6s %-8s %6s\n", carType [c], carRoad [c], carNum [c]
}

# --------------------------------------
function dumpLocs ()  {
    printf "dumpLocs:\n"
    for (l = 0; l < L; l++)
        printf "   %2d: %s  %6s %3d  %s\n", \
            l, locTown [l],  locType [l], locSize [l], locName [l]
}

# --------------------------------------
function dumpLocTypes ()  {
    printf "dumpLocTypes:\n"
    for (t in nLocType)
        printf "    %6d  %s\n", nLocType [t], t
}

# ------------------------------------------------
function hyst (N) {
    printf "hyst:\n"

    for (i = 0; i < 20; i++)  {
        for (l = 0; l < L; l++)
            loc [l] = 0

        for (n = 0; n < N; n++)
            loc [int(rand() * L)]++

        for (l = 0; l < L; l++)
            printf " %2d", loc [l]
        printf "\n"
    }
}

# ------------------------------------------------------------------------------
    ## select: H    RDG  66722
	##      10  G 2  Coal Dealer
	##       7  O 3  Mahanoy City
	##       4  M 1  Fisher Foundry
	##       8  O 3  Shamokin
	##      10  G 2  Coal Dealer
	##       7  O 3  Mahanoy City

function dumpCar (c, N)  {
    printf "select: %s %6s %6s\n", carType [c], carRoad [c], carNum [c]

    for (n = 0; n < N; n++)  {
        l = dest [c, n]

        printf " %6d  %-2s  _  %s\n",  \
                dest [c, n], locTown [l],   locName [l]
    }
}

# --------------------------------------------------------------------
function assign (c, N)  {
    type = carType [c]

    if (dbg)  {
        printf "# assign: N %d", N
        printf ", c %2d, %s %6s %d", c, carType [c], carRoad [c], carNum [c]
        printf "\n"
    }
    
#   if (1 < nLocType [type] && 0 < N)  {
#     # printf "# assign: check\n"
#       if (dest [c, N-1] == idx [type])  {
#           ++idx [type]
#           printf "                    # assign: skip %d\n", idx [type]
#       }
#   }

    cntOuter = 100
    cntInner = 40
    do {
        if (0 >= --cntOuter)
            assignError(c, N, type, "outer")
        do {
            if (0 >= --cntInner)
                assignError(c, N, type, "inner")

            if (L <= ++idx [type])
                idx [type] = 0

            if (dbg)
                printf "   L %d, idx [%s] %d\n", L, type, idx [type]

        } while (! match(locType [idx [type]], carType [c]))
    } while (1 < nLocType [type] && 0 < N && dest [c, N-1] == idx [type])

    dest [c, N] = l = idx [type]

    if (dbg)  {
        printf "#  assign: %d", N
        printf "  %2d %s", idx [type], type
        printf "  [%2d] %s %-6s", c, carType [c], carRoad [c]
        printf "  [%2d] %5s %s",  l, locType [l], locName [l]
        printf "\n"
    }
}

# ----------------------------------------------------------
function assignError (c, N, type, fault)  {
    type = carType [c]
    i    = int(idx [type])
    printf "**** Error: %s - car [%d] %s %s %s\n", fault, \
                                c, carType [c], carRoad [c], carNum [c]
    printf "%10s idx %d, loc type %s, name %s\n", "", i, locType [i], locName [i]
    printf "%10s loc %s, type %s\n", "", locName [i], locType [i]
    printf "%10s L %d, type %s, idx %d\n", "", L, type, idx [type]
    printf "\n"
    exit
}

# ----------------------------------------------------------
END  {
    if (dbg)  {
        printf "# -------------------- %s --------------------\n", "END"
        printf "END: C %d, L %d\n", C, L
    }

  # hyst(100)

    # sequentially assign a location for each iteration and car
    for (n = 0; n < N; n++)  {
        for (c = 0; c < C; c++)
            assign(c, n)
        if (dbg)
            printf "\n"
    }

    for (c = 0; c < C; c++)
        dumpCar(c, n)

  # dumpLocs()
  # dumpCars()
  # dumpLocTypes()
}' $*

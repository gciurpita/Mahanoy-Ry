# script to create routings to each .loc for each .car

awk '
BEGIN {
    dbg= 0
    if (dbg) print "nu:"
    C = L = 0

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
    if (/#/ || /type/)
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

        printf " %6d  %s  _  %s\n",  \
                dest [c, n], locTown [l],   locName [l]
    }
}

# --------------------------------------------------------------------
function assign (c, N)  {
    type = carType [c]

    do {
        if (L <= ++idx [type])
            idx [type] = 0
    } while (! match(locType [idx [type]], carType [c]))

    dest [c, N] = l = idx [type]

    if (dbg)  {
        printf "# assign: %d %2d - %s %-6s", N, c, carType [c], carRoad [c]
        printf "  %2d %5s %s\n", l, locType [l], locName [l]
    }
}

# ----------------------------------------------------------
END  {
    if (dbg)  {
        printf "# -------------------- %s --------------------\n", "END"
        printf "END: C %d, L %d\n", C, L
    }

  # hyst(100)

    # sequentially assign a location for each iteration and car
    N = 6
    for (n = 0; n < N; n++)
        for (c = 0; c < C; c++)
            assign(c, n)

    for (c = 0; c < C; c++)
        dumpCar(c, n)

  # dumpLocs()
  # dumpCars()
}' $*

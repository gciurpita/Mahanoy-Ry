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

# ------------------------------------------------
function select (N, c,  type, road, number) {
    type   = carType [c]
    road   = carRoad [c]
    number = carNum [c]

    printf "select: %s %6s %6s\n", type, road, number

    # reset town and location cnts
    for (t in town)
        town [t] = 0

    locCnt = 0
    for (l = 0; l < L; l++)  {
        loc [l] = 0
        if (type == locType [l] || "_" == locType [l])
            locCnt++
    }
    locLmt = N / locCnt

    dbg= 0
    if (dbg)
        printf " select: dbg, c %d, locCnt %d, locLmt %.2f\n", c, locCnt, locLmt

    # ----------------------------
    # select N locations
    for (n = 0; n < N; n++)  {
        while (1)  {
            l = int(rand() * L)         # pick random location

            if ("_" != locType [l] && ! match(locType [l], type))  {
                if (dbg)
                    printf "   wrong type: %s %5s %s\n", \
                        type, locType [l], locName [l]
                continue
            }

            # ----------------------------
            # distributed assignments
            if (dbg)
                printf "  select: c %d, n %d, l %d, loc [] %d\n", \
                    c, n, l, loc [l]

            # skip location if already selected
            if (locLmt < loc [l])  {
                if (dbg)
                    printf "   lmt: loc %d, %s\n", loc [l], locName [l]
                continue
            }

            # get random value and probability
            r = rand()
            p = 1 / (1 +town [locTown [l]])

            # get previous and current town
            am1 = locTown [route [n -1]]
            a   = locTown [l]

            if (dbg)   {
                printf "    %.3f  %.3f  %2d  %d %s (%s)  %s", \
                        r, p, l, town [locTown [l]], a, am1, locName [l]
            }

            # randomly w/in probabilty skip location
            if (1 > p && r > p)  {
                if (dbg) printf " -- p\n"
                continue
            }

            # randonly skip location if town as last
            if (0 < n && am1 == a && r > p/2)  {
                if (dbg) printf " -- a\n"
                continue
            }

            # select this location by breaking out of while loop
            loc [l]++
            if (dbg) printf "\n"
            break
        }

        route [n] = l
        town  [locTown [l]]++
        loc   [l]++
    }

    # ----------------------------
    # report
    for (n = 0; n < N; n++)  {
        l = route [n]
        if (0)  {
            if ("M" == locTown [l])
                printf Red
            else if ("G" == locTown [l])
                printf Blue
        }

        printf " %6d  %s %d  %s\n",  \
                route [n], locTown [l], town [locTown [l]],  locName [l]
        if (0)
            printf Normal
    }

    if (0)  {
        printf "    "
        for (a in town)
            printf " %d", town [a]
        printf "    "
        for (a in town)
            printf " %s", a
        printf "\n"
    }
}

# ----------------------------------------------------------
END  {
    if (dbg)  {
        printf "# -------------------- %s --------------------\n", "END"
        printf "END: C %d, L %d\n", C, L
    }

  # hyst(100)

  # for (i = 0; i < 20; i++)
  #     select(8)

    for (c = 0; c < C; c++)
        select(6, c)

  # dumpLocs()
  # dumpCars()
}' $* | tee cards.out |

# ------------------------------------------------------------------------------
# script to format
awk '
BEGIN {
    x = "F G H R X"
    y = "Flat Gondola Hopper Reefer Box"
    F = split(x, sym, " ")
    F = split(y, fld, " ")
    for (f = 1; f <= F; f++)
        typeName [sym [f]] = fld [f]

    cnt = 0;
    Wid = 350
    hdr()
}

# ------------------------------------------------
function hdr () {
    printf "<html>\n"
    printf "<body>\n"
    printf "<style>\n"
    printf "  td {\n"
    printf "    font-family:Arial;\n"
    printf "    font-size:20px;\n"
    printf "  }\n"
    printf "  th {\n"
    printf "    font-family:Arial;\n"
    printf "    font-size:24px;\n"
    printf "  }\n"
    printf "</style>\n"

    print "<style>"
    print "    @media print {"
    print "        .page, .page-break { break-after: page; }"
    print "    }"
    print "</style>"
}

# ------------------------------------------------
function table (type, road, number, dest, N, side) {
    Col = 4
  # printf "<p>\n"
    printf "<table border=1 cellspacing=0 width=%d align=%s>\n", Wid, side
    printf "    <tr> <th colspan=%d> %s <th> %s &nbsp;&nbsp;&nbsp; %s\n", \
                                        Col, typeName [type], road, number

    for (n = 0; n < N; n++)  {
        printf "    <tr> <td width=20> &nbsp;\n"
        for (c = 1; c < Col; c++)
            printf "         <td width=20> &nbsp;\n"
        printf "        <td> &nbsp;%s\n", dest [n]
    }
    printf "</table>\n"
    printf "\n"
}

# ------------------------------------------------
function genCard () {
    if (cnt)
        if (! (cnt % 8))  {
            print "<table width=100%> <tr><td> </table>"
            print "<div class=\"page-break\"></div>"
        }
    cnt++

    printf "<!-- cnt %d -->\n", cnt
    table(type, road, number, dest, N, "left")
}

# ------------------------------------------------
/dbg/ { exit }

/select/ {
    if (0 < N)
        genCard()

    N      = 0
    type   = $2
    road   = $3
    number = $4
    next
}

# ----------------------------
{
    dest [N++] = substr($0, index($0, $4))
  # print
}

# ------------------------------------------------
END {
    genCard()
}' | tee cards.htm

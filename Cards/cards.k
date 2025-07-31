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
NF && match(FILENAME, "loc") {
    if (dbg) print

    if (/#/)
        next

    locType [L]   = $1
    locSize [L]   = $2
    locArea [L]   = $3
    locName [L++] = substr($0, index($0, $4))

    areas [$3]++
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
            l, locArea [l],  locType [l], locSize [l], locName [l]
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
function select (N, type, road, number) {
    printf "select: %s %6s %6s\n", type, road, number

    for (a in area)
        area [a] = 0

    for (l = 0; l < L; l++)
        loc [l] = 0

    # ----------------------------
    # select N locations
    for (n = 0; n < N; n++)  {
        while (1)  {
            l = int(rand() * L)         # pick random location

            if ("_" != locType [l] && ! match(locType [l], type))  {
                if (dbg)
                    printf " no-match: %s %5s %s\n", \
                        type, locType [l], locName [l]
                continue
            }

            r = rand()
            p = 1 / (1 +area [locArea [l]])

            am1 = locArea [route [n -1]]
            a   = locArea [l]

            if (dbg)   {
                printf "    %.3f  %.3f  %2d  %d %s (%s)  %s", \
                        r, p, l, area [locArea [l]], a, am1, locName [l]
            }

            if (1 > p && r > p)  {
                if (dbg) printf " -- p\n"
                continue
            }

            if (0 < n && am1 == a && r > p/2)  {
                if (dbg) printf " -- a\n"
                continue
            }

            if (dbg) printf "\n"
            break
        }

        route [n] = l
        area [locArea [l]]++
    }

    # ----------------------------
    # report
    for (n = 0; n < N; n++)  {
        l = route [n]
        if (0)  {
            if ("M" == locArea [l])
                printf Red
            else if ("G" == locArea [l])
                printf Blue
        }

        printf " %6d  %s %d  %s\n",  \
                route [n], locArea [l], area [locArea [l]],  locName [l]
        if (0)
            printf Normal
    }

    if (0)  {
        printf "    "
        for (a in area)
            printf " %d", area [a]
        printf "    "
        for (a in area)
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
        select(6, carType [c], carRoad [c], carNum [c])

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
    printf "<!-- cnt %d -->\n", cnt
    if (cnt)
        if (! (cnt % 8))
            print "<hr>\n<div class=\"page-break\"></div>"
    cnt++

    table(type, road, number, dest, N, "left")
}

# ------------------------------------------------
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

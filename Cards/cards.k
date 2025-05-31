
awk '
BEGIN {
    Ncols = 5
    C     = 0
}

# --------------------------------------------------------------------
{
  # print
}

# ------------------------------------------------
! NF || /^#/ {
    next
}

# ------------------------------------------------
match(FILENAME, "car")  {
    if (/type/)  {
      # print
        type [$2] = $3
    }
    else {
        cars    [C]   = substr($0, index($0, $2))
        carType [C]   = $1
        carRR   [C]   = $2
        carNum  [C++] = $3
    }
}

# ------------------------------------------------
match(FILENAME, "loc")  {
  # print

    loc         = $3 " " $4
    towns [loc] = $3
    locs  [loc] = $1

    for (n = 1; n <= length($1); n++)
        nTypes [ substr($1, n, 1) ]++

    nLocs++
}

# --------------------------------------------------------------------
function listCars () {
    printf "cars:\n"
    for (c = 0; c < C; c++)
        printf "    %2d  %s  %s\n", c, carType [c], cars [c]
}

# ------------------------------------------------
function listLocs () {
    printf "locs:\n"
    for (loc in locs)
        printf "    %s\n", loc
}

# --------------------------------------------------------------------
function genCard (carIdx, list, nList)  {
    if (dbg)
        printf "genCard: %2d %s\n", carIdx, cars [carIdx]


    if (! (nCard++ % 3))
        printf "<table border=0> <tr>\n"

    printf " <td width=30%>\n"

    # --------------------------------------
    Ncol = 4
    printf "  <table border=1 cellspacing=0 width=300>\n"
    if (1)
        printf "    <tr> <th colspan=%d> %s <th> %s %s\n", \
            Ncol, type [carType [c]], carRR [c], carNum [c]
    else
        printf "    <tr> <td> %d <th colspan=%d> %s - %s %s\n", \
                carIdx+1, Ncol, type [carType [c]], carRR [c], carNum [c]

    for (n = 0; n < nList; n++)  {
        printf "    <tr> <td width=20> %s\n", "&nbsp;"
        for (col = 1; col < Ncol; col++)
            printf "         <td width=20> %s\n", "&nbsp;"

        printf "        <td> %s\n", list [n]
    }
    printf "  </table>\n"
    printf "\n"

    # --------------------------------------
    if ((nCard % 3))  {
        printf " <td width=3%> &nbsp;\n"
        printf "\n"
    }

    # --------------------------------------
    if (! (nCard % 3))  {
        printf "</table>\n"
        printf "<p>\n"
        printf "\n"
    }
}

# ------------------------------------------------
function endCard ()  {
    printf "</table>\n"
}

# ------------------------------------------------
function route (nLoc) {
    cntMax = 1
    for (c = 0; c < C; c++)  {
        if (! nTypes [carType [c]])
            continue

        dbg = 0
        if (dbg)
            printf "route:  %s\n", cars [c]

        locCnt = 0
        town   = ""
        while (nLoc > locCnt) {
            for (loc in locs)  {
                if (match(locs [loc], carType [c]) || "_" == locs [loc])  {
                    thresh = 1/nLocs

                    if (0 < locCnt && loc == listUse [locCnt-1])     # same loc
                        thresh /= 4
                    else if (towns [loc] == town)
                        thresh /= 3
                    else if (towns [loc] != town)
                        thresh /= 2

                    # ----------------------------
                    # decide
                    if (thresh < rand())
                        continue

                    list [locCnt] = loc
                    town          = towns [loc]
                    locUse [loc]++                  # track # selected

                  # printf "    %-4s", locs [loc]
                    if (dbg)
                        printf "    %s\n", loc

                    if (nLoc <= ++locCnt)
                        break
                }
                else {
                    if (dbg)
                        printf "%40s %-4s %s\n", "**", locs [loc], loc
                }
            }
        }

        genCard(c, list, nLoc)
    }
}

# ------------------------------------------------
END {
    if (0)  {
        listLocs()
        listCars()
    }
    else  {
        route(5)
        endCard()

        if (1)  {
            printf "<pre>\n"

            printf "</pre>\n"
        }

        if (0)  {
            printf "<pre>\n"
            for (loc in locs)
                printf "    %2d  %s\n", locUse [loc], loc
            printf "</pre>\n"
        }

        if (0)  {
            printf "<pre>\n"
            for (t in type)
                printf "   %s  %d\n", t, nTypes [t]
            printf "</pre>\n"
        }
    }
}' $*

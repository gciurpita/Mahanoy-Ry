
awk '
BEGIN {
    dbg   = 0

    Ncard = 2
    NcardPerPage = 8
    Ncol  = 4
    Nloc  = 8
    C     = 0
    L     = 0

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
    if (dbg) print

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
##    BRSX 2  Gliberton freight
match(FILENAME, "loc")  {
    if (dbg) print

    locs     [L]   = $3 " " $4
    towns    [L]   = $3
    locSize  [L]   = $2
    locTypes [L++] = $1

    for (n = 1; n <= length($1); n++)
        nTypes [ substr($1, n, 1) ]++

    locMax += $2
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
    for (l = 0; l < L; l++)
        printf "    %s\n", locs [l]
}

# --------------------------------------------------------------------
function genCard (carIdx, list, nList)  {
    if (dbg)
        printf "genCard: %2d %s\n", carIdx, cars [carIdx]

    # --------------------------------------
    if (! (nCard++ % Ncard))
        printf "<table border=0> <tr>\n"

    printf " <td width=30%>\n"

    # --------------------------------------
    printf "  <table border=1 cellspacing=0 width=400>\n"
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

        gsub("_", " ", list [n])
        printf "        <td> &nbsp;%s\n", list [n]
    }
    printf "  </table>\n"
    printf "\n"

    # --------------------------------------
    if ((nCard % Ncard))  {
        printf " <td width=3%> &nbsp;\n"
        printf "\n"
    }

    # --------------------------------------
    if (! (nCard % Ncard))  {
        printf "</table>\n"
        printf "<p>\n"
        printf "\n"
    }

    # --------------------------------------
  # if (! (nCard % NcardPerPage))
  #     printf "<div style=\"break-after:page\"></div>\n"
}

# ------------------------------------------------
function endCard ()  {
    printf "</table>\n"
}

# ------------------------------------------------
function route (nLocPcard) {
    if (dbg)
        printf "route: nLoc %d\n", nLocPcard

    cntMax = 1
    for (c = 0; c < C; c++)  {
        if (dbg)
            printf "---- ---------------\nroute:  %s\n", cars [c]

        if (! nTypes [carType [c]])
            continue

        cnt = 0
        town   = ""
        while (nLocPcard > cnt) {
            for (l = 0; l < L; l++)  {
                loc = locs [l]

                types = locTypes [l]
                if (match(types, carType [c]) || "_" == types)  {
                    thresh = 1/L

                    if (0 < cnt && loc == listUse [cnt-1])     # same loc
                        thresh /= 4
                    else if (towns [l] == town)
                        thresh /= 3
                    else if (towns [l] != town)
                        thresh /= 2

                    # ----------------------------
                    # decide
                    if (thresh < rand())
                        continue

                    list [cnt] = loc
                    town          = towns [l]
                    locUse [loc]++                  # track # selected

                    if (dbg)
                        printf "    %s\n", loc

                    if (nLocPcard <= ++cnt)
                        break
                }
                else {
                    if (2 <= dbg)
                        printf "%40s %-4s %s\n", "**", locs [l], loc
                }
            }
        }

        genCard(c, list, cnt)
    }
}

# ------------------------------------------------
END {
    if (dbg) printf "End:\n"

    if (0)  {
        listLocs()
        listCars()
    }
    else  {
        route(Nloc)
        endCard()

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

        printf "<p> %d cars, %d maxLoc\n", C, locMax
    }

    printf "<p> <i>version 250604a</i>\n"
    printf "</body>\n"
    printf "</html>\n"
}' $*

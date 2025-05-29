
awk '
BEGIN {
    Ncols = 5
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
        car         = substr($0, index($0, $2))
        cars   [car] = $1
        carRR  [car] = $2
        carNum [car] = $3
    }
}

# ------------------------------------------------
match(FILENAME, "loc")  {
  # print

    loc         = $3 " " $4
    towns [loc] = $3
    locs  [loc] = $1

    nTypes [$1]++
}

# --------------------------------------------------------------------
function listCars () {
    printf "cars:\n"
    for (car in cars)
        printf "    %s  %s %s\n", car, cars [car], type [cars [car]]
}

# ------------------------------------------------
function listLocs () {
    printf "locs:\n"
    for (loc in locs)
        printf "    %s\n", loc
}

# --------------------------------------------------------------------
function genCard (car, list)  {
    if (0 == nCard)
        printf "<table border=0>\n"

    if (! (nCard++ % 3))
        printf "<tr> <td>\n"
    else
        printf "<td>\n"

    # --------------------------------------
    Ncol = 3
    printf "  <table border=1 cellspacing=0 width=300>\n"
    printf "    <tr> <th colspan=%d> %s - %s %s\n", Ncol+1, \
                type [cars [car]], carRR  [car], carNum [car] 

    for (n = 0; n < 4; n++)  {
        printf "    <tr> <td width=20> %s\n", "&nbsp;"
        for (col = 1; col < Ncol; col++)
            printf "         <td width=20> %s\n", "&nbsp;"

        printf "        <td> %s\n", list [n]
    }

    printf "  </table>\n"
}

# ------------------------------------------------
function endCard ()  {
    printf "</table>\n"
}

# ------------------------------------------------
function route () {
    cntMax = 1
    for (car in cars)  {
        if (! nTypes [cars [car]])
            continue

        if (dbg)
            printf "\n  %s  %s\n", car, cars [car]

        locCnt = 0
        town   = ""
        do {
            for (loc in locs)  {
                if (match(locs [loc], cars [car]) || "_" == locs [loc])  {
                    if (0.4 > rand())
                        continue
    
                    if (towns [loc] == town) {
                        if (dbg)
                            printf "%40s %s = %s\n", "***", towns [loc], town
                        continue
                    }

                    list [locCnt] = loc
    
                  # printf "    %-4s", locs [loc]
                    if (dbg)
                        printf "    %s\n", loc
                    if (4 <= ++locCnt)   {
                      # printf ".\n"
                        break
                    }
    
                    town = towns [loc]
                }
                else {
                    if (dbg) printf "%40s %-4s %s\n", "**", locs [loc], loc
                }
            }
        } while (4 > locCnt)

        genCard(car, list)
    }
}

# ------------------------------------------------
END {
    if (0)  {
        listLocs()
        listCars()
    }
    else  {
        route()
        endCard()
    }
}' $* | tee cards.htm

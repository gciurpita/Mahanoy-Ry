
awk '
BEGIN {
    x = "X R S F G H T"
    F = split(x, fld, " ")
}

# ------------------------------------------------
#  select: X    CNJ  12502
#       13  G 4  Warechowski Millworks
#        4  O 1  Mahanoy City
#        6  G 4  Gliberton Freight House
#       11  G 4  Arnold Machine
#        2  M 1  Gregory Machine
#       11  G 4  Arnold Machine

/select/ {
    Ncar++
    name [Ncar] = sprintf("%-6s%6s %s", $3, $4, $2)
    s           = sprintf("%s %s", $3, $4)
    name [Ncar] = sprintf("%-12s %s", s, $2)
    idx   = 0
    next
}

# ------------------------------------------------
{
    loc = substr($0, index($0, $4))
    locs [loc] ++
    geo  [loc] = $2
    dest [Ncar, idx++] = loc

    if (idxMax < idx)
        idxMax = idx
}

# ------------------------------------------------
END {
    if (0)
        for (n = 1; n < Ncar; n++)  {
            printf " %3d: %s\n", n, name [n]
            for (i = 0; i <idxMax; i++)
                printf "       %s\n", dest [n, i]
        }

    if (0)
        for (loc in locs)
            printf "      %s\n", loc

    #--------------------------------------
    # vertically print car names 
    for (i = 1; 1; i++)  {
        flg = 0
        printf "%30s", ""
        for (n = 1; n < Ncar; n++)  {
            c = substr(name [n], i, 1)
            if (!c)
                c = " "
            else
                flg++
            printf " %s", c
        }

        printf "\n"
        if (0 == flg)
            break
    }

    #--------------------------------------
    # sort locations
    Nloc = 0
    for (loc in locs) {
        nameList [Nloc]   = geo [loc] " " loc
        locList  [Nloc++] = loc
    }

    for (i = Nloc; 0 < i; i--)  {
        for (j = 1; j < i; j++)  {
            if (nameList [j-1] > nameList [j])  {
                t              = locList [j]
                locList [j]    = locList [j-1]
                locList [j-1]  = t

                t              = nameList [j]
                nameList [j]   = nameList [j-1]
                nameList [j-1] = t
            }
        }
    }

    if (0)  {
        printf " Nloc %s\n", Nloc
        for (n = 0; n < Nloc; n++)
            printf "  %2d  %-25s  %s\n", n, locList [n], nameList [n]
    }

    #--------------------------------------
    # report assignments
    for (m = 0; m < Nloc; m++)  {
        loc = locList [m]
        cnt = 0
        printf "  %s %25s ", geo [loc], loc

        for (n = 1; n < Ncar; n++)  {
            c = "_"
            carLoc = 0
            for (i = 0; i < idx; i++)  {
                if (match(dest [n, i], loc))  {
                    c = "o"
                    cnt++
                    carLoc++
                }
            }
          # printf " %s", c

            if (0 == carLoc)
                printf " ."
            else if (1 == carLoc)
                printf " %s", "|"
            else if (2 == carLoc)
                printf " %s", "O"
            else
                printf " %d", carLoc
        }

        printf "  %2d", cnt
        printf "\n"
    }
}' cards.out

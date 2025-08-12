
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
        printf "    "
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
    # report assignments
    for (loc in locs)  {
        cnt = 0
        printf "    "
        for (n = 1; n < Ncar; n++)  {
            c = " "
            for (i = 0; i < idx; i++)
                if (dest [n, i] == loc)  {
                    c = "."
                    cnt++
                }
            printf " %s", c
        }
        printf "  %2d %s\n", cnt, loc
    }
}' cards.out


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
    Col = 4
    Wid = 350
    NperPg = 10
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
  # printf "<p>\n"
    printf "<table border=1 cellspacing=0 width=%d align=%s>\n", Wid, side
    printf "    <tr> <th colspan=%d> %s <th> %s &nbsp;&nbsp;&nbsp; %s\n", \
                                        Col, type, road, number
                                     #  Col, typeName [type], road, number

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
        if (! (cnt % NperPg))  {
            print "<table width=100%> <tr><td> </table>"
            print "<div class=\"page-break\"></div>"
        }
    cnt++

    printf "<!-- cnt %d -->\n", cnt
    table(type, road, number, dest, N, "left")
}

# ------------------------------------------------
/dbg/ { exit }

# ------------------------------------------------
##  select: X    PRR  67890

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
##        9  G  _  Gliberton Freight House
##       11  G  _  Bradley Beer Storage
##       12  G  _  Perrin Shirts
##       13  G  _  Wotring Electric
{
    dest [N++] = $2 " " substr($0, index($0, $4))
  # print
}

# ------------------------------------------------
END {
    genCard()
}' $*

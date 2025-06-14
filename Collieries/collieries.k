# svg drawing routines

awk '
# ------------------------------------------------
function anno (x, y, text, font)  {
    if (! font)
        font=10
    printf "  <text x=\"%d\" y=\"%d\"", S*x, S*mapY(y)
    printf " font-family=\"Verdana\""
    printf " font-size=\"%d\"", font
    printf ">%s</text>\n", text
}

# ------------------------------------------------
function annoC (x, y, text, font)  {
    if (! font)
        font = 10
    printf "  <text x=\"%d\" y=\"%d\"", S*x, S*mapY(y)
    printf " font-family=\"Verdana\""
    printf " text-anchor=\"middle\""
    printf " font-size=\"%d\"", font
    printf ">%s</text>\n", text
}

# ------------------------------------------------
function annoR (x, y, text, font)  {
    if (! font)
        font = 10
    printf "  <text x=\"%d\" y=\"%d\"", S*x, S*mapY(y)
    printf " font-family=\"Verdana\""
    printf " text-anchor=\"end\""
    printf " font-size=\"%d\"", font
    printf ">%s</text>\n", text
}

# ------------------------------------------------
function comment (text)  {
    printf " <!-- %s -->\n", text
}

# ------------------------------------------------
#    A rx ry rotate large_arc_flag sweep_flag x y
#    use cw rotations

function arc (x0, y0, a0, a1, rad, col, a, x2, y2, x3, y3)  {
    printf " <!-- arc (%d, %d) a0 %d, a1 %d, rad %.2f -->\n", \
            x0, y0, a0, a1, rad

    y0 = mapY(y0)

    x2 =  S * (x0 + rad * sin(a0 * Pi / 180))
    y2 =  S * (y0 - rad * cos(a0 * Pi / 180))

    x3 =  S * (x0 + rad * sin(a1 * Pi / 180))
    y3 =  S * (y0 - rad * cos(a1 * Pi / 180))

    printf " <!-- arc x (%d, %d)  x2 (%d, %d)  x3 (%d, %d) -->\n", \
        x0, y0, x2, y2, x3, y3

    rot = 0
    lrg = 0
    swp = 1     # cw

    printf "  <path d=\"M %4d %4d", x2, y2
    printf           "  A %4d %4d, %d, %d, %d, %4d %4d\"",\
                            S * rad, S * rad, rot, lrg, swp, x3, y3
    printf         " style=\"stroke:%s; fill:none\"", col
    printf "/>\n"
}

# ------------------------------------------------
function circle (x0, y0, rad, col, a)  {
    printf " <circle cx=\"%d\" cy=\"%d\" r=\"%d\"", S*x0, S*mapY(y0), S*rad
    printf " stroke=\"black\""
    printf " stroke-width=\"1\""
    printf " fill=\"%s\"", col
    printf "/>\n"
}

# ------------------------------------------------
function line (x0, y0, x1, y1, color)  {
    printf "  <line   x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\"", \
        S*x0, S*mapY(y0), S*x1, S*mapY(y1)
    printf " style=\"stroke:%s;stroke-width:1\"", color
    printf " />\n"
}

# ------------------------------------------------
function lineArrow (x0, y0, x1, y1) {
    printf "<line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\"",
        S*x0, S*mapY(y0), S*x1, S*mapY(y1)
    printf "stroke=\"#000\" stroke-width=\"2\""
    printf "marker-end=\"url(#arrowhead)\" />\n"

}

# ------------------------------------------------
function marker () {
  printf "<defs>\n"
  printf "  <marker id=\"arrowhead\" markerWidth=\"10\" markerHeight=\"5\"\n"
  printf "  refX=\"0\" refY=\"2.5\" orient=\"auto\">\n"
  printf "    <polygon points=\"0 0, 10 2.5, 0 5\" />\n"
  printf "  </marker>\n"
  printf "</defs>\n"
}

# --------------------------------------------------------------------
function path (vecY, N, col) {
    printf "<path d=\"M %d %d\n", 0, Ht - vecY [0]
    for (n = 1; n < N; n++) {
        printf "  L %3d %4d\n", n, Ht - vecY [n]
      # printf "  L %3d %8.4f\n", n,      vecY [n]
    }
    printf "\""
    printf " stroke=\"%s\" stroke-width=\"2\" fill=\"none\" />\n", col
}

# ------------------------------------------------
function rect (x0, y0, x1, y1, color, wid, ht)  {
    wid = x1 - x0
    ht  = y1 - y0
    printf " <rect   x=\"%d\" y=\"%d\" width=\"%d\" height=\"%d\"", S*x0, S*y0, S*wid, S*ht
    printf " style=\"fill:none;stroke:%s;stroke-width:1\"", color
    printf " />\n"
}


# ------------------------------------------------
function mapY (y)  {
    return Ht - y
}

# ------------------------------------------------
function svgBegin (wid, ht, scale)  {
    Wid = wid
    Ht  = ht
    S   = scale
    if (Html)  {
        printf "\n"
        printf "<p>"
        printf "<table border=1 cellspacing=0 bgcolor=lightcyan> <tr> <td>\n"
    }

    printf "<svg version=\"1.1\" baseProfile=\"full\"\n"
    printf "     width=\"%d\" height=\"%d\"\n", S*Wid, S*Ht
    printf "     xmlns=\"http://www.w3.org/2000/svg\">\n"

    bgCol = "beige"
    if (bgCol)
        printf "  <rect width=\"100%%\" height=\"100%%\" fill=\"%s\"/>\n", \
            bgCol
}

# ------------------------------------------------
function svgEnd (text)  {
    if (text)
        annoC(Wid/2, Ht - 14/S, text, 14)
    printf "</svg>\n"

    if (H)
        printf "</table>\n"
    printf "\n"
}

# --------------------------------------------------------------------
BEGIN  {
    Pi   = atan2(0, -1)
    Font = 18
    N    = 0
}

# ------------------------------------------------
NF == 0 || $1 == "#"  {
    next
}

# ------------------------------------------------
{
  # print

    id    [N] = $1
    yrBeg [N] = $2
    yrEnd [N] = $3
    tons  [N] = $4
    name  [N] = substr($0, index($0, $5))

    if (maxLen < length(name [N]))
        maxLen = length(name [N])

    if (0 == N)  {
        beg = yrBeg [N]
        end = yrEnd [N]
    }
    else  {
        if (beg > yrBeg [N] && 0 < yrBeg [N])
            beg = yrBeg [N]

        if (end < yrEnd [N] && "?" !=  yrEnd [N])
            end = yrEnd [N]
    }

    comment(sprintf(" %2d, %4s - %4s, (%4d - %4d), %s",
                N, yrBeg [N], yrEnd[N], beg, end, name [N]))

    N++
}

# --------------------------------------------------------------------
END {
    Ht    = Font * (N+5)
    xOff  = 10
    xName = xOff + end-beg + 4*Font
    Wid   = xName + maxLen*Font

    svgBegin(Wid, Ht, 1)

    F1 = 24
    annoC(Wid/2, Ht-F1, "Mahanoy Valley Collieries", F1)

    for (n = 0; n < N; n++)  {
        y  = (N-n+2)*Font
        x0 = xOff + yrBeg [n] - beg
        xN = xOff + yrEnd [n] - beg

        # ----------------------------
        # active collieries 1930
        yrActive = 1930
        if (yrBeg [n] <= yrActive && yrActive <= yrEnd [n])
            ++nActive

        line(x0, y, xN, y, "black")
        anno(xName, y, \
            sprintf("%4s - %4s %s", yrBeg [n], yrEnd [n], name [n]), Font)
    }

    # ----------------------------
    # vertical lines
    y0 = Font * 0.25
    yN = Font * (N + 1 + 0.5)
    x  = "1850 1875 1900 1925 1950"
    F  = split(x, fld, " ")

    for (f = 1; f <= F; f++)  {
        x = xOff + fld [f] - beg
        line(x, y0, x , yN, "gray")
        anno(x, y0, fld [f])
        y0 += Font * 0.5
    }

    svgEnd()

    comment(\
        sprintf(" Wid %d, Ht %d, beg %d, end %d, maxLen %d, Font %d, nAct %d",
                Wid, Ht, beg, end, maxLen, Font, nActive))
}' $* << **END** | tee collieries.svg
#   29  ____ 1911       _       North Laurel
    7   1870 1873   _       West Lehigh
    12  1862 1875   100000  Oak Hollow
    17  1860 1875   50000   Hoffman
    18  1870 1875   50000   Trenton
    6   1862 1875   94027   Delano
    3   1868 1876   300000  East Mahanoy
    14  1869 1877   100000  Beaver
    15  1863 1877   100000  Grant
    36  1870 1879   800000  Barry, McNeil and Yatesville
    11  1874 1883   100000  Webster
    10  1859 1884   400000  Hartford
    9   1864 1884   _       West Lehigh
    39  1871 1888   1000000 Stanton
    37  1880 1890   300000  Laurel Ridge
    4   1862 1895   1800000 Glendon
    23  1871 1896   1800000 Elmwood
    26  1863 1896   2300000 Bear Run
    5   1863 1897   1900000 Schuylkill
    20  1893 1911   2800000 Vulcan
    31  1869 1911   1300000 Furnace
    13  1861 1913   4000000 Primrose
    41  1863 1913   3300000 West Bear Ridge
    8   1883 1917   _       Park #1
    32  1860 1922   9750000 Suffolk
    34  1861 1922   8000000 Knickerbocker
    28  1860 1926   8300000 Draper
    21  1864 1927   4000000 New Boston
    25  1861 1928   9500000 Old St Nicholas
    16  1884 1930   8800000 Buck Mountain
    33  1862 1930   17000000 Ellengowen
    24  1862 1931   9000000 Tunnel Ridge
    2   1858 1932   17300000 North Mahanoy
    22  1888 1932   1000000 Morea
    38  1868 1934   8900000 Lawrence
    19  1885 1936   460435  Park #2
    30  1862 1938   8300000 Gilberton
    27  1863 1939   5700000 Boston Run
    40  1834 1941   600000  East Bear Ridge
    1   1860 1953   11000000 Mahanoy City
    35  1888 1954   27800000 Maple Hill
**END**

# translate ascii track diagram to .svg
#_____________________________________________
#__\______________________________________/___
#    \_______    _____\_________/_____  /
#                                      /
#               ______________________/
#                              ______/
## 345678901234567890123456789012345678901234567890
#
#text  6 4 Brewery
#text 17 4 City Jct Spur-1
#text 32 4 City Jct Spur-2
#text 31 7 City Jct IntrChng

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
function circle (x0, y0, rad, col, stroke, a)  {
    printf " <circle cx=\"%d\" cy=\"%d\" r=\"%d\"", S*x0, S*mapY(y0), S*rad
    printf " stroke=\"%s\"", col
    printf " stroke-width=\"%d\"", stroke
  # printf " fill=\"%s\"", col
    printf " fill=\"%s\"", "none"
    printf "/>\n"
}

# ------------------------------------------------
function line (x0, y0, x1, y1, color, stroke)  {
    if (! stroke)
        stroke = 1
    printf "  <line   x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\"", \
        S*x0, S*mapY(y0), S*x1, S*mapY(y1)
    printf " style=\"stroke:%s;stroke-width:%d\"", color, stroke
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

    bgCol = ""
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

# ------------------------------------------------
function turntable(x, y, rad, color, Stroke)  {
    ttX = x;     ttY = y;     ttRad = rad
    circle(ttX, ttY, ttRad, color, Stroke)

    if (0)  {
        for (a = 0; a < 360; a += 10)  {
            c = cos(a * Pi / 180)
            s = sin(a * Pi / 180)

            _x0 = ttX +c*ttRad;      _y0 = ttY +s*ttRad
            _x1 = ttX +c*ttRad*2;    _y1 = ttY +s*ttRad*2
            line(_x0, _y0, _x1, _y1, color)
        }
    }
}

# ------------------------------------------------
function ttTrk (a, rad, color, stroke)  {
    c = cos(a * Pi / 180)
    s = sin(a * Pi / 180)
    _x0 = ttX +s*ttRad;        _y0 = ttY +c*ttRad
    _x1 = ttX +s*(ttRad+rad);  _y1 = ttY +c*(ttRad+rad);
    line(_x0, _y0, _x1, _y1, color, stroke)
}

# --------------------------------------------------------------------
BEGIN  {
    Pi = atan2(0, -1)

    NttTrk = 0

    color = "black"

    if (0)  {
        Sc     = 50
        Stroke = 5
        FontSz = 22
    }
    else {
        Sc     = 15
        Stroke = 2
        FontSz = 12
    }
}

# ------------------------------------------------
NF == 0 || $1 == "#"  {
    next
}

# ------------------------------------------------
/color/ { color = $2; next }

# ------------------------------------------------
/text/ {
    textX  [NR] = $2

    if ("+" == substr($3, 1, 1))
        dy += substr($3, 2)
    else
        dy  = $3
    textY  [NR] = maxRow - dy + 1.2

    if ("-f" == substr($4, 1, 2))  {
        textF  [NR] = textF [NR] = $4
        text   [NR] = substr($0, index($0, $5))
    }
    else  {
        textF  [NR] = FontSz
        text   [NR] = substr($0, index($0, $4))
    }
    next
}

# ------------------------------------------------
/ttTrk/  {
    ang = 0
    for (n = 2; n <= NF; n+=2)  {
        ttTrkAng [NttTrk]   = ang   += $n
        ttTrkRad [NttTrk++] = $(n+1)
    }
    next
}

# ------------------------------------------------
{
    row [NR] = $0
    col = length($0)
    if (maxCol < col)
        maxCol = col
    maxRow = NR
}

# --------------------------------------------------------------------
END {
    printf "<!--\n"
    printf " size %d x %d, %d\n", maxCol, maxRow, NR
    for (nr = 1; nr <= NR; nr++)
        print row [nr]
    printf " -->\n"

    svgBegin(maxCol+1, maxRow+1, Sc)

    for (nr = 1; nr <= NR; nr++)  {
        if (text [nr])
            anno(textX [nr], textY [nr], text [nr], textF [nr])
    }

    for (nr = 1; nr <= maxRow; nr++)  {
        y = maxRow+1 - nr
        s = row [nr]

        c = ""
        for (i = 1; i <= length(s); i++) {
            pre = c
            c   = substr(s, i, 1)

            if ("_" == c) {
                line(i, y, i+1, y, color, Stroke)

                if ("/" == pre)
                    line(i-1, y, i, y,   color, Stroke)
            }

            else if ("/" == c)
                line(i, y, i+1, y+1, color, Stroke)

            else if ("\\" == c)  {
                line(i, y+1, i+1, y, color, Stroke)

                if ("_" == pre || "/" == substr(row [nr+1], i-1, 1))
                    line(i, y,   i+1, y, color, Stroke)
            }

            # westbound signals
            else if ("<" == c)  {
                line(i+0.9, y+0.2,  i+0.9,   y+0.8,  "black", 1)
                line(i+0.9, y+0.5,  i+0.5, y+0.5,  "black", 1)
                circle(i+0.3, y+0.5, 0.25, "none")

                line(i, y, i+1, y, "black", Stroke)
            }

            # eastbound signals
            else if (">" == c)  {
                line(i+0.1, y+0.2,  i+0.1,     y+0.8,  "black", 1)
                line(i+0.1, y+0.5,  i+0.5, y+0.5,  "black", 1)
                circle(i+0.7, y+0.5, 0.25, "none")
                if ("_" == pre)
                    line(i, y,   i+1, y, "black", Stroke)
            }

            else if ("|" == c)  {
                a = substr(row [nr-1], i, 1)    # char above

                if ("\\" == a)
                    x [i]= i+1
                else if ("/" == a)
                    x [i] = i
                else
                    x [i] = i

                line(x[i], y, x[i], y+1, color, Stroke)
            }
            else if ("*" == c)  {
                turntable(i, y, 3, color, Stroke)
            }
        }
        printf "\n"
    }

    # ------------------------------------------------
    comment("ttTrk");
    for (n = 0; n < NttTrk; n++)  {
        ttTrk(ttTrkAng [n], ttTrkRad [n], color, Stroke)
    }

    # ------------------------------------------------
    svgEnd()
}' $*

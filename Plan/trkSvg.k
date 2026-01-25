# trkSvg - yet another track drawing tool

awk '
# ------------------------------------------------
function anno (x, y, text, font)  {
    if (! font)
        font=10
    printf "  <text x=\"%d\" y=\"%d\"", mapX(x), mapY(y)
    printf " font-family=\"Verdana\""
    printf " font-size=\"%d\"", font
    printf ">%s</text>\n", text
}

# ------------------------------------------------
function annoC (x, y, text, font)  {
    if (! font)
        font = 10
    printf "  <text x=\"%d\" y=\"%d\"", mapX(x), mapY(y)
    printf " font-family=\"Verdana\""
    printf " text-anchor=\"middle\""
    printf " font-size=\"%d\"", font
    printf ">%s</text>\n", text
}

# ------------------------------------------------
function annoR (x, y, text, font)  {
    if (! font)
        font = 10
    printf "  <text x=\"%d\" y=\"%d\"", mapX(x), mapY(y)
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
    if (180 < abs(a1-a0))
        ; # lrg = 1
    swp = 1     # 1/0 cw/ccw
    if (0 > (a1 - a0))
        swp = 0

    printf "  <path d=\"M %4d %4d", x2, y2
    printf           "  A %4d %4d %d %d %d %4d %4d\"",\
                            S*rad, S*rad, rot, lrg, swp, x3, y3
    printf " stroke=\"%s\" stroke-width=\"2\" fill=\"none\" />\n", col
    printf "/>\n"
}

# ------------------------------------------------
function circle (x0, y0, rad, col, a)  {
    printf " <circle cx=\"%d\" cy=\"%d\" r=\"%d\"", mapX(x0), mapY(y0), S*rad
    printf " stroke=\"%s\"", col
    printf " stroke-width=\"2\""
    printf " fill=\"none\""
    printf "/>\n"
}

# ------------------------------------------------
function line (x0, y0, x1, y1, col, width)  {
    if (! color)
        color = "black"
    if (! width)
        width = 2

    printf "  <line   x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\"", \
        mapX(x0), mapY(y0), mapX(x1), mapY(y1)
    printf " style=\"stroke:%s;stroke-width:%d\"", col, width
    printf " />\n"
}

# ------------------------------------------------
function lineArrow (x0, y0, x1, y1) {
    printf "<line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\"",
        mapX(x0), mapY(y0), mapX(x1), mapY(y1)
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
function pathVec (vecX, vecY, N, col, fill) {
    if ("" == fill)
        fill = "none"
    printf "<path d=\"M %4d %4d\n", mapX(vecX [0]), mapY(vecY [0])
    for (n = 1; n < N; n++)   {
        printf "         L %4d %4d\n",   mapX(vecX [n]), mapY(vecY [n])
    }
    printf "\""
    printf " stroke=\"%s\" stroke-width=\"2\" fill=\"%s\" />\n", col, fill
}

# --------------------------------------------------------------------
function path (x0, y0, xRad, yRad, rot, largeArc, cw, x1, y1, col)  {
    comment(sprintf("path: x0 %d, y0 %d, xRad %d, yRad %d" \
            ", rot %d, smallArc %d, cw %d, x1 %d, y1 %d", \
            x0, y0, xRad, yRad, rot, largeArc, cw, x1, y1))

    printf "  <path d=\"M %4d %4d", mapX(x0), mapY(y0)

    printf           "  A %4d %4d %d %d %d", S*rad, S*rad, rot, largeArc, cw
    printf           " %4d %4d\"",  mapX(x1), mapY(y1)
    printf " stroke=\"%s\" stroke-width=\"2\" fill=\"none\" />\n", col
 #  printf "/>\n"
}

# ------------------------------------------------
function rect (x0, y0, x1, y1, color, wid, ht)  {
    wid = x1 - x0
    ht  = y1 - y0
    printf " <rect   x=\"%d\" y=\"%d\" width=\"%d\" height=\"%d\"", \
                        mapX(x0), y0, mapX(wid), ht
    printf " style=\"fill:none;stroke:%s;stroke-width:1\"", color
    printf " />\n"
}


# ------------------------------------------------
function mapX (x)  {
    return S* (x -Xoff)
}

# ------------------------------------------------
function mapY (y)  {
    return S* (Ht -(y -Yoff))
}

# ------------------------------------------------
function svgBegin (x0, y0, wid, ht, scale, bgCol)  {
    Xoff = x0
    Yoff = y0
    Wid = wid
    Ht  = ht  - y0
    S   = scale

    comment(sprintf("space y0 %d, ht %d, Ht %d", y0, ht, Ht))

    if (Html)  {
        printf "\n"
        printf "<p>"
        printf "<table border=1 cellspacing=0 bgcolor=lightcyan> <tr> <td>\n"
    }

    printf "<svg version=\"1.1\" baseProfile=\"full\"\n"
    printf "     width=\"%d\" height=\"%d\"\n", S*(Wid),      S*(Ht)
    printf "     xmlns=\"http://www.w3.org/2000/svg\">\n"

    if (bgCol)
        printf "  <rect width=\"100%%\" height=\"100%%\" fill=\"%s\"/>\n", \
            bgCol
    else
        ColTrk = "black"
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
# --------------------------------------------------------------------
BEGIN  {
    Pi    = atan2(0, -1)
    G     = 0.65

    AngSdg = 10
    ColTrk = "orange"
}

# ------------------------------------------------
function abs (x) {
    if (0 > x)
        return -x
    return x
}

function sgn (x) {
    if (0 > x)
        return -1
    return 1
}

# ------------------------------------------------
function error (msg)  {
    printf " ** Error: %s - %s\n", msg, $0
    exit
}

# ------------------------------------------------
function plug (x0, y0, col) {
    printf "thickness = 1.0\n"
    
    if (! col)
        col = "red"
    printf "color = %s\n", col

    rect(x0, y0, 4, 3, "red")
    printf "thickness = 1\n"
}

# ------------------------------------------------
function measure (x0, y0, x1, y1, sz, ang)  {
    col = "black"
    line(x0, y0, x1, y1, col, 1)

    _ang = atan2(y1 -y0, x1 -x0) *180/Pi
    a1   = ang+30;  c1 = cos((ang+10)*Pi/180);  s1 = sin((ang+10)*Pi/180)
    a2   = ang-30;  c2 = cos((ang+10)*Pi/180);  s2 = sin((ang+10)*Pi/180)
    _len = Wid/100
    if (x0 <= x1)  {
        if (y0 <= y1)  {
            line(x0, y0, x0 +c1*_len, y0 +s1*_len, col, 1)
            line(x0, y0, x0 +c2*_len, y0 -s2*_len, col, 1)

            line(x1, y1, x1 -c1*_len, y1 +s1*_len, col, 1)
            line(x1, y1, x1 -c2*_len, y1 -s2*_len, col, 1)
        }
        else {
            line(x0, y0, x0 +c1*_len, y0 -s1*_len, col, 1)
            line(x0, y0, x0 +c2*_len, y0 +s2*_len, col, 1)

            line(x1, y1, x1 -c1*_len, y1 -s1*_len, col, 1)
            line(x1, y1, x1 -c2*_len, y1 +s2*_len, col, 1)
        }
    }
    else {
        if (y0 <= y1)  {
            line(x0, y0, x0 -c1*_len, y0 +s1*_len, col, 1)
            line(x0, y0, x0 -c2*_len, y0 -s2*_len, col, 1)

            line(x1, y1, x1 +c1*_len, y1 +s1*_len, col, 1)
            line(x1, y1, x1 +c2*_len, y1 -s2*_len, col, 1)
        }
        else {
            line(x0, y0, x0 -c1*_len, y0 -s1*_len, col, 1)
            line(x0, y0, x0 -c2*_len, y0 +s2*_len, col, 1)

            line(x1, y1, x1 +c1*_len, y1 -s1*_len, col, 1)
            line(x1, y1, x1 +c2*_len, y1 +s2*_len, col, 1)
        }
    }

    annoC((x0+x1)/2, (y0+y1)/2, sprintf("%.2f", sqrt((x0-x1)^2 + (y0-y1)^2)))
}

# ------------------------------------------------
function xyPairs (thick, col, fill) {
    idx = 0;
    for (n = 2; n < NF; n += 2)  {
        _vecX [idx] = int($n)
        _vecY [idx] = int($(n+1))
        idx++
    }

    pathVec(_vecX, _vecY, idx, col, fill)
}

# ------------------------------------------------
filename != FILENAME {
    filename = FILENAME
    comment("filename " filename)
}

/^ *#/  { next }
NF      { printf "%60s", "";  comment(sprintf("line %4d - %s", NR, $0)) }
/quit/  { exit }

/arc/   { arc($2, $3, $4, $5, $6, $7);      next }
/measure/ { measure($2, $3, $4, $5, $6, $7); next }
/rect/  { rect($2, $3, $4, $5);             next }
/thick/ {                                   next }

/fill/  { fill = $2;                        next }
/bench/ {
    xyPairs(2, "dark-gray", fill)
    next
}

# /color/ { if ("black" != ColTrk) ColTrk=$2; next }
/color/ { ColTrk=$2;                        next }
/obj/   { xyPairs(2, "");                   next }
/plug/  { plug($2, $3, $4);                 next }
/room/  { xyPairs(2, "blue");               next }
/text/  { anno($2, $3, substr($0, index($0, $4)));         next }
/text/  { printf "anno %d %d %s\n", $2, $3, substr($0, index($0, $4)); next }
/title/ {                                   next }

# ------------------------------------------------
/aspect/ {
    printf "set_color %d = (%d, %d, %d)\n", g1=33, 50, 50, 50
    arc($2, $3, 0, 360, $4, g1)
    next
}

# ------------------------------------------------
/curve/ {
    rad  = $2
    dAng = $3
    col  = $4
  #  printf "# nF %d\n", NF
    if (4 <= NF)  {
        curve(rad, dAng, col)
    }
    else
        curve(rad, dAng, ColTrk)
}

# ------------------------------------------------
function curve (rad, dAng, color) {
  #  printf "# curve: rad %.1f, dAng %.1f, color %s\n", red, dAng, color

    _dirLst = dir
    if (0 < dAng)  {
        a0   = dir - 90
        a1   = a0 + dAng
        dir  = (a1 + 90) % 360
    }
    else {
        a0  = dir + 90
        a1  = a0 + dAng
        dir = (a1 - 90) % 360
    }

    comment(sprintf("curve: dirLst %d, a0 %d, a1 %d, dir %d", \
                                        _dirLst, a0, a1, dir))

    c  = cos(a0 * Pi / 180);    s  = sin(a0 * Pi / 180)
    xC = xPos -c*rad;        yC = yPos -s*rad

    # --------------------------------------
    # path M x0 y0 A xRad yRad rot smallArc cw x1 y1

    c = cos(a1 * Pi / 180);     s  = sin(a1 * Pi / 180)
    x1 = xC +c*rad;             y1 = yC +s*rad

    comment(sprintf("curve: xPos %d, yPos %d, xC %d, yC %d, x1 %d, y1 %d", \
                                        xPos, yPos, xC, yC, x1, y1))

    largeArc = 0
    if (180 < abs(dAng))
        largeArc = 1

    cw = 0
    if (0 > dAng)
        cw = 1

    path(xPos, yPos, rad, rad, 0, largeArc, cw, x1, y1, color)
 
    xPos = x1;      yPos = y1
    next
}

# --------------------------------------
/grid/ {
    x0 = $2;    y0 = int($3)
    x1 = $4;    y1 = int($5)
    dd = $6

    printf "thickness = 0.7\n"
    printf "set_color %d = (%d, %d, %d)\n", g2=33, 80, 80, 80
    printf "color = %d\n", g2
    for (x = x0; x <= x1; x += dd)
        line(x, y0, x, y1, g2)

    for (y = y0; y <= y1; y += dd)
        line(x0, y, x1, y, g2)

    next
}

# --------------------------------------
function pr (tag)  {
    comment(sprintf("# %-5s  %-5s xPos %6.2f, yPos %6.2f, dir %6.1f, trkLen %8.2f\n", \
            tag, lbl, xPos, yPos, dir, trkLen))
}

# --------------------------------------
/lbl/ {
    lbl = $2
    pr("lbl:")

    lblX [lbl] = xPos;  lblY [lbl] = yPos; lblDir [lbl] = dir
  # if ("_" != substr(lbl, 1, 1))
        anno(xPos, yPos, lbl)
    next
}

# --------------------------------------
/mvto/ {
    lbl = $2
    if ("" == lblX [lbl])  {
        error(sprintf("\"%s\" unknown", lbl))
    }

    xPos = lblX [lbl]; yPos = lblY [lbl]; dir = lblDir [lbl]

    if ("rev" == $3)
        dir = (dir + 180) % 360

    pr("mvto:")
    next
}

# --------------------------------------
/mvtt/ {
    dir  = $2

    xPos = xTt + cos(dir * Pi / 180) * diaTt /2;
    yPos = yTt + sin(dir * Pi / 180) * diaTt /2

  #  printf "# mvtt: xPos %6d, yPos %d, dir %d\n", xPos, yPos, dir
    next
}

# --------------------------------------
/pos/   {
    xPos = $2; yPos = $3; dir = $4;
  # mark(xPos, yPos, 1, 1, "red")
  # printf "thickness = 1.5\n"

    trkLen = 0
    next
}

# --------------------------------------
/sdg/ { 
    len   = $2
    right = $3
    sp    = $4

    spur(len, right, sp)

    dir -= angSdg
    str(lenDiv)

    dir = dirLst
    next
}

# --------------------------------------
/space/ { 
    if (! spaceCnt++)
        svgBegin($2, $3, $4, $5, $6, $7)
    next
}

# --------------------------------------
/spur/ { spur($2, $3, $4); next }

# ----------------------------
function spur (len, right, sp) {
    angSdg = AngSdg
    if ("right" == right)
        angSdg = -AngSdg

    dirLst = dir
    dir   += angSdg
    lenDiv = sp / sin(abs(angSdg) * Pi / 180)
  #  printf "# sdg: dirLst %.2f, dir %.2f, angSdg %.2f, lenDiv %.2f\n", \
  #     dirLst, dir, angSdg, lenDiv

    str(lenDiv)

  #  printf "# sdg chk 1\n"
    dir = dirLst
    str(len)
}

# --------------------------------------
/str/   {
    if (3 <= NF)
        str($2, $3)
    else
        str($2)
    next
}

# ----------------------------
function str (len, col) {
  # printf "# str: xPos %6d, yPos %d, dir %d, len %.2f, col %s\n", \
  #                     xPos, yPos, dir, len, col
    x0   = xPos;                  y0   = yPos
    c    = cos(dir * Pi / 180);   s    = sin(dir * Pi / 180)
    xPos = x0 + c * len;          yPos = y0 + s * len

    if (! col)
        col = ColTrk
    line(x0, y0, xPos, yPos, col)

  #  printf "# trkLen  %8.2f, x %6.2f, y %6.1f\n", trkLen += len, xPos, yPos
}

# --------------------------------------
/trkLen/ {
  #  printf "# trkLen: %.1f\n", trkLen
    anno(xPos, yPos, sprintf("%.1f", trkLen))
    next
}

# --------------------------------------
# turntable
/tt/   {
    diaTt = $2

    if (! col)
        col = ColTrk

    xTt  = xPos + cos(dir * Pi / 180) * diaTt /2;
    yTt  = yPos + sin(dir * Pi / 180) * diaTt /2
    circle(xTt, yTt, diaTt/2, col)

    next
}

# ------------------------------------------------
NF { 
    error("unkown")
}

# --------------------------------------------------------------------
END {
    if (0)  {
        printf "upper_boundary = %6.2f\n", 0.5
        printf "lower_boundary = %6.2f\n", 7.0

        printf "left_boundary  = %6.2f\n", 0.5
        printf "right_boundary = %6.2f\n", 10.75

        printf "title_x  track length %.1f ft\n", trkLen /12
    }

    svgEnd()
}' $*

# create drawing from pts

awk '
# ------------------------------------------------
function error (msg)  {
    printf " ** Error: %s - %s\n", msg, $0
    err++
    exit
}

# ------------------------------------------------
function anno (x, y, text, font)  {
  # comment(sprintf("anno: %d, %d, %s, %d", x, y, text, font))
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
function comment (text)  {
    printf "  <!-- %s -->\n", text
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
function line (x0, y0, x1, y1, color)  {
    comment(sprintf("line: (%d, %d) (%d, %d)", x0, y0, x1, y1))

    printf "  <line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\"", \
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
function mapY (y)  {
    return Ht - y
}

# ------------------------------------------------
function mark (x0, y0, dd, color)  {
    line(x0 -dd, y0,     x0 +dd, y0,     color)
    line(x0,     y0 -dd, x0,     y0 +dd, color)
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
function svgBegin (wid, ht, scale)  {
    Wid = wid
    Ht  = ht
    S   = scale

    comment(sprintf(" svgBegin: wid %.1f, ht %.1f, scale %.1f", wid, ht, scale))

    printf "<svg version=\"1.1\" baseProfile=\"full\"\n"
    printf "     width=\"%d\" height=\"%d\"\n", S*Wid, S*Ht
    printf "     xmlns=\"http://www.w3.org/2000/svg\">\n"

  # bgCol = "beige"
    if (bgCol)
        printf "  <rect width=\"100%%\" height=\"100%%\" fill=\"%s\"/>\n", \
            bgCol
}

# ------------------------------------------------
function svgEnd (text)  {
    _font = font + 10
    if (text)
        annoC(Wid/2, Ht - _font/S, text, _font)
    printf "</svg>\n"
}

# --------------------------------------------------------------------
function dispPt (p) {
    printf " <%4s %2d %2d %2d>", p, x [p], y [p], z [p]
}

# --------------------------------------------------------------------
function getPtX (p) {
    split(substr(p, 2), fld, "/")
    res = val ["x" fld [1]] - xOff

  # printf "# getPtX: p %s, res %s\n", p, res
    return res
}

function getPtY (p) {
    split(substr(p, 2), fld, "/")
    res = val ["y" fld [2]]

  # printf "# getPtY: p %s, res %s\n", p, res
    return res
}

function getPtZ (p) {
    split(substr(p, 2), fld, "/")
    res = val ["z" fld [3]]

  # printf "# getPtZ: p %s, res %s\n", p, res
    return res
}


# --------------------------------------------------------------------
function dump () {
    printf "<!--\n"
    printf "  dump: pts\n"
    for (p in pt)  {
        printf "    %6s", p
        printf " %6.2f", getPtX(p)
        printf " %6.2f", getPtY(p)
        printf " %6.2f", getPtZ(p)
        printf "\n"
    }

    if (1) {
        printf "  dump: vals\n"
        for (sym in val)
            printf "    %6s %6.2f\n", sym, val [sym]
    }

    printf "  dump: conns\n"
    for (c = 0; c < C; c++)
        printf "    %6s - %6s\n", p0 [c], p1 [c]

    printf "  dump: conns\n"
    printf "    %6.1f x\n", max ["x"]
    printf "    %6.1f y\n", max ["y"]
    printf "    %6.1f z\n", max ["z"]

    printf " -->\n\n"
}

# ------------------------------------------------
function valOf (tok, _v) {
    c = substr(tok, 1, 1)
    if ("0" <= c && c <= "9")
        return int(tok)

    _v = val [tok]
    if ("" == _v)
        error(sprintf("undefined tok: %s", tok))
    return _v
}

# ------------------------------------------------
BEGIN  {
    Pi         = atan2(0, -1)
    PixPerIn   = 96
    HoSc       = 12/87        # ft to inches
    PixPerScFt = PixPerIn * HoSc
    Color      = "black"
    Xmargin    = 5
    font       = 14

    C          = 0
    N          = 0
    P          = 0

    bar20      = "--------------------"
    bar40      = bar20 bar20
    bar60      = bar20 bar20 bar20
    dbg        = 1
    minX = minY = minZ = 99
}

# ------------------------------------------------
! NF || /^ *#/ { next }

/color/ { color = $2; if (Sc) printf "\n%s\n", $0;  next }
/font/  { font = $2;                                next }
/front/ { view = view "F";                          next }
/quit/  {                                           exit }
/scale/ { scX = $2; scY = $3; scLen= $4; scHt = $5; next }
/side/  { view = view "S";                          next }
/title/ { title = substr($0, index($0, $2));        next }
/xOff/  { xOff = $2;                                next }

# ------------------------------------------------
"=" == $2  {
    val [$1] = valOf($3)

    for (n = 4; n <= NF; n+= 2)   {
        if ("#" == $n)
            break
        else if ("+" == $n)
            val [$1] += valOf($(n+1))
        else if ("-" == $n)
            val [$1] -= valOf($(n+1))
        else
            error("unknown operator")
    }

    if (1 < dbg)  {
        printf "assign: %3s %6.2f - ", $1, val [$1];
        print
    }

    c = substr($1, 1, 1)        # x, y, z
    if (max [c] < val [$1])
        max [c] = val [$1]

    next
}

# ------------------------------------------------
"-" == $2 {
    if (1 < dbg)
        comment($0)

    pt [$1]++
    pt [$3]++

    p0 [C]   = $1
    p1 [C++] = $3
    next
}

# ------------------------------------------------
"+" == $1 {
    if (1 < dbg)
        comment($0)

    pt [$2]++

    p0 [C]   = p1 [C-1]
    p1 [C++] = $2
    next
}

# ------------------------------------------------
{
  error("unrecognized input")
}

# --------------------------------------------------------------------
function arrow (x0, y0, x1, y1, col) {
    dL = 0.9; dS = 0.3
    if (x0 == x1)  {
        dx = dS;   dy = dL

        if (y0 > y1) {
            t  = y0
            y0 = y1
            y1 = t
        }

        line(x0,  y0, x0 +dx, y0 +dy, col)
        line(x0,  y0, x0 -dx, y0 +dy, col)

        line(x1,  y1, x1 +dx, y1 -dy, col)
        line(x1,  y1, x1 -dx, y1 -dy, col)
    }
    else if (y0 == y1)  {
        dx = dL;   dy = dS

        if (x0 > x1) {
            t  = x0
            x0 = x1
            x1 = t
        }

        line(x0,  y0, x0 +dx, y0 +dy, col)
        line(x0,  y0, x0 +dx, y0 -dy, col)

        line(x1,  y1, x1 -dx, y1 +dy, col)
        line(x1,  y1, x1 -dx, y1 -dy, col)
    }

    line(x0, y0, x1, y1, col)
}

# ------------------------------------------------
function markPts () {
    for (sym in x)
        mark( x [sym], y [sym], 1, "black")
}

# ------------------------------------------------
function measure (x0, y0, x1, y1) {
    len = sqrt((x0 - x1)^2 + (y0 - y1)^2)

    xC = (x0 + x1) /2
    yC = (y0 + y1) /2

    if (x0 == x1)  {
        anno(xC +1, yC,    len)
        arrow(x0+1,  y0, x1+1, y1, "gray")
    }
    else if (y0 == y1)  {
        anno(xC,    y0 -1, len)
        arrow(x0,  y0 -1, x1, y0 -1, "gray")
    }
    else
        anno(xC,    yC,    len)
}

# -----------------------------------------------n-
function frontView (_x0, _y0, _z0, _x1, _y1, _z1) {
        printf "\n"
        comment(sprintf("frontView: font %s", font))
        for (c = 0; c < C; c++)  {
            _x0 = getPtX(p0 [c])
            _y0 = getPtY(p0 [c])
    
            _x1 = getPtX(p1 [c])
            _y1 = getPtY(p1 [c])
    
            line(Xmargin+_x0, _y0, Xmargin+_x1, _y1, Color)
            anno(Xmargin+_x1, _y1, sprintf("%d, %d", _x1, _y1), font)
          # anno(_x1, _y1, sprintf("%d, %d  %s", _x1, _y1, p0 [c]), font)
        }
}

# -----------------------------------------------n-
function sideView (_x0, _y0, _z0, _x1, _y1, _z1) {
        printf "\n"
        comment(sprintf("sideView: - C %d", C))
        z1 = val ["z1" ]
        for (c = 0; c < C; c++)  {
            if (0 != getPtX(p0 [c]))
                continue
    
            _z0 = getPtZ(p0 [c])
            _y0 = getPtY(p0 [c])
    
            _z1 = getPtZ(p1 [c])
            _y1 = getPtY(p1 [c])
    
            comment(sprintf("connPts: %s - %s", p0 [c], p1 [c]))
            line(_z0, _y0, _z1, _y1, Color)
            anno(_z1, _y1, sprintf("%d, %d", _z1 - z1, _y1), font)
        }
}

# ------------------------------------------------
function scale (x0, y0, len, ht) {
    printf "\n"
    comment("scale:")

    N  = 10
    x1 = x0 + len

    line(x0, y0, x1, y0, "black")

    if (1) {
    for (n = 0; n <= N; n++)  {
        dx = len*n/N
        x  = x0 + dx
        line(x, y0, x, y0+ht, "black")
        anno(x, y0+ht, dx, font)
    }
    anno(0,0, sprintf("scale: %d pix/inch", PixPerIn))
    }
}

# ------------------------------------------------
function setMinMax (s)  {
    _x = getPtX(s)
    if (xMin > _x) xMin = _x
    if (xMax < _x) xMax = _x

    _y = getPtY(s)
    if (yMin > _y) yMin = _y
    if (yMax < _y) yMax = _y

    _z = getPtZ(s)
    if (zMin > _z) zMin = _z
    if (zMax < _z) zMax = _z

    if (0) {
        printf "setMinMax: _x %4d, _y %4d, _z %4d\n", _x, _y, _z
        printf"   %4d - %4d\n", xMin, xMax
        printf"   %4d - %4d\n", yMin, yMax
        printf"   %4d - %4d\n", zMin, zMax
    }
}

# ------------------------------------------------
function getSizes ()  {
    xMin = xMax = getPtX(p0 [0])
    yMin = yMax = getPtY(p0 [0])
    zMin = zMax = getPtZ(p0 [0])

    for (c = 0; c < C; c++)  {
        setMinMax(p0 [c])
        setMinMax(p1 [c])
    }

    if (1)  {
        comment(sprintf("getSizes: x %4d - %4d", xMin, xMax))
        comment(sprintf("getSizes: y %4d - %4d", yMin, yMax))
        comment(sprintf("getSizes: z %4d - %4d", zMin, zMax))
    }
}

# ------------------------------------------------
END {
    if (err)
        exit

    if (dbg)
        dump()

    getSizes()

    wid = xMax
    if (match(view, "S"))
        wid = zMax

    svgBegin(wid +3*Xmargin, yMax +10, PixPerScFt)

    if (match(view, "F"))
        frontView()

    if (match(view, "S"))
        sideView()

    if (scX)
        scale(scX, scY, scLen, scHt)

    svgEnd(title)
}' $*

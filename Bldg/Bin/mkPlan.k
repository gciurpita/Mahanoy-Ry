# create 4 sided plan from len, wid, ht and pk

awk '
function abs (x)  {
    if (0 > x)
        return -x
    return x
}

# ------------------------------------------------
function error (msg)  {
    printf " ** Error: %s - %s\n", msg, $0
    exit
}

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
function line (x0, y0, x1, y1, color)  {
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
function measure (x0, y0, x1, y1, algn, col, _len) {
    if (dbg)
        return

    comment(sprintf("measure: (%.2f, %.2f) (%.2f, %.2f) %d", \
                                            x0, y0, x1, y1, algn))
    _len = sqrt((x0 - x1)^2 + (y0 - y1)^2)

    xC = (x0 + x1) /2
    yC = (y0 + y1) /2

    if (! col)
        col = "gray"

    if (x0 == x1)  {
        anno(xC +algn, yC,    _len)
        arrow(x0+algn,  y0, x1+algn, y1, col)
    }
    else if (y0 == y1)  {
        anno(xC,   y0 +algn, _len)
        arrow(x0,  y0 +algn, x1, y0 +algn, col)
    }
    else
        anno(xC,    yC,    _len)
}

# --------------------------------------------------------------------
function path (vecX, vecY, N, col) {
    printf "<path d=\"M %d %d\n",  S*vecX [0], S*mapY(vecY [0])
    for (n = 1; n < N; n++) {
        printf "         L %3d %4d\n", S*vecX [n], S*mapY(vecY [n])
    }
    printf "\""
    printf " stroke=\"%s\" stroke-width=\"2\" fill=\"none\" />\n", col
}

# ------------------------------------------------
function rect (x0, y0, wid, ht, col, _vecX, _vecY, _N)  {
    if (0) {
        printf " <rect   x=\"%d\" y=\"%d\" width=\"%d\" height=\"%d\"", \
                S*x0, S*mapY(y0), S*wid, S*ht
        printf " style=\"fill:none;stroke:%s;stroke-width:1\"", col
    }
    else  {
        _N = 0;
        _vecX [_N] = x0;          _vecY [_N++] = y0
        _vecX [_N] = x0;          _vecY [_N++] = y0 + ht
        _vecX [_N] = x0 + wid;    _vecY [_N++] = y0 + ht
        _vecX [_N] = x0 + wid;    _vecY [_N++] = y0
        _vecX [_N] = x0;          _vecY [_N++] = y0

        path(_vecX, _vecY, _N, col)
    }
    printf " />\n"
}

# ------------------------------------------------
function svgBegin (wid, ht, scale)  {
    Wid = wid
    Ht  = ht
    S   = scale

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
    if (text)
        annoC(Wid/2, Ht - 24/S, text, 24)
    printf "</svg>\n"
}

# --------------------------------------------------------------------
# --------------------------------------------------------------------
function peak (x0, y0, wid, ht, pk, col, side, _vecX, _vecY, _N, _xMid) {
    comment(sprintf("\npeak: wid %.2f, ht %.2f, pk %.2f", wid, ht, pk))
    _N = 0;
    if (side)  {
        _vecX [_N] = x0;          _vecY [_N++] = y0
        if ("l" == side)  {
            _vecX [_N] = x0;          _vecY [_N++] = y0 + ht + pk
            _vecX [_N] = x0 + wid;    _vecY [_N++] = y0 + ht
            measure(x0,    y0, x0,     y0+ht+pk, 1)
        }
        else if ("r" == side) {
            _vecX [_N] = x0;          _vecY [_N++] = y0 + ht
            _vecX [_N] = x0 + wid;    _vecY [_N++] = y0 + ht + pk
            measure(x0 +wid, y0, x0 +wid, y0+ht+pk, 1)
        }
        _vecX [_N] = x0 + wid;    _vecY [_N++] = y0
        _vecX [_N] = x0;          _vecY [_N++] = y0

    }
    else {
        _xMid = x0 + wid/2
        _vecX [_N] = x0;          _vecY [_N++] = y0
        _vecX [_N] = x0;          _vecY [_N++] = y0 + ht
        _vecX [_N] = _xMid;       _vecY [_N++] = y0 + ht + pk
        _vecX [_N] = x0 + wid;    _vecY [_N++] = y0 + ht
        _vecX [_N] = x0 + wid;    _vecY [_N++] = y0
        _vecX [_N] = x0;          _vecY [_N++] = y0

        measure(x0,    y0, x0,     y0+ht,    1)
        measure(_xMid, y0, _xMid,  y0+ht+pk)
    }

    path(_vecX, _vecY, _N, col)
    measure(x0,    y0, x0+wid, y0,      -1)
}

# ------------------------------------------------
function rectM (x0, y0, wid, ht, pcol, _vecX, _vecY, _N, _xMid) {
    comment(sprintf("\nrectM: wid %.2f, ht %.2f", wid, ht))
    rect(x, y0, wid, ht, col)

    measure(x0,    y0, x0,     y0+ht,    1)
    measure(x0,    y0, x0+wid, y0,      -1)
}

# ------------------------------------------------
BEGIN  {
    Pi       = atan2(0, -1)
    PixPerIn = 96
    PixPerFt = PixPerIn * 12 / 87       # scale feet

}

# ------------------------------------------------
function draw (len, wid, ht, pk, title)  {
    Wid = 5+ 2*wid +len
    Ht  = 5+ ht + abs(pk)
    col = "black"
    y0  = 3
    
    svgBegin(Wid, Ht, PixPerFt)
        x  = 1
        if (0 > pk)
            peak( x, y0, wid, ht, abs(pk), col, "l")
        else
            peak( x, y0, wid, ht, pk, col)

        x += wid;   rectM(x, y0, len, ht, col)

        x += len
        if (0 > pk)
            peak( x, y0, wid, ht, abs(pk), col, "r")
        else
            peak( x, y0, wid, ht, pk, col)

      # x += wid;   rectM(x, y0, len, ht, col)
    svgEnd(title)
}

# ------------------------------------------------
NF && ! /^ *#/ {
    dbg = 0
    draw($1, $2, $3, $4)
}

# ------------------------------------------------
END {
}' $* << **END** | tee mkPlan.htm
#   len wid ht  pk
    50  16  31   8  Iron Works
    50  16  19   8  Loading
    20  18  10  -6  Office
**END**

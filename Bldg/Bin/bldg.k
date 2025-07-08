# crude bldg svg drawing prog: lines with doors/windows

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
    printf         "         style=\"stroke:%s; fill:none\"", col
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
function line (x0, y0, x1, y1, color, strokeWid)  {
    comment(sprintf("line: (%d, %d), (%d, %d) %s, strkWid %d", \
                                x0, y0, x1, y1, color, strokeWid))
    printf "  <line   x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\"", \
        S*x0 +0.5, S*mapY(y0) +0.5, S*x1 +0.5, S*mapY(y1) +0.5
    if (! strokeWid)
        strokeWid = 1
    printf " style=\"stroke:%s;stroke-width:%d\"", color, strokeWid
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
function marker () {
  printf "<defs>\n"
  printf "  <marker id=\"arrowhead\" markerWidth=\"10\" markerHeight=\"5\"\n"
  printf "  refX=\"0\" refY=\"2.5\" orient=\"auto\">\n"
  printf "    <polygon points=\"0 0, 10 2.5, 0 5\" />\n"
  printf "  </marker>\n"
  printf "</defs>\n"
}

# --------------------------------------------------------------------
function path (vecX, vecY, N, stroke, strWid, fill) {
    printf    "<path d=\"M %4d %4d", S*vecX [0], S*mapY(vecY [0])
    for (n = 1; n < N; n++) {
        printf "\n         L %4d %4d", S*vecX [n], S*mapY(vecY [n])
    }
    printf "\"\n"
    printf "     stroke=\"%s\" stroke-width=\"%d\" fill=\"%s\" />\n", \
                        stroke, strWid, fill
}

# ------------------------------------------------
function rectWh (x0, y0, wid, ht, color, fill, strokeWid)  {
    comment(sprintf("rectWh: (%d, %d) <%d, %d> %s, %s, stkWid %d", \
                        x0, y0, wid, ht, color, fill, strokeWid))

    printf " <rect   x=\"%d\" y=\"%d\" width=\"%d\" height=\"%d\"", \
            S*x0 +0.5, S*mapY(y0+ht) +0.5, S*wid +0.5, S*ht +0.5
    if (! fill)
        fill = "none"
    if ("" == strokeWid)
        strokeWid = 1
    printf " style=\"fill:%s;stroke:%s;stroke-width:%d\"", \
                                            fill, color, strokeWid
    printf " />\n"
}

# ------------------------------------------------
function rectXy (x0, y0, x1, y1, color, wid, ht)  {
    rect(x0, y0, x1 - x0, y1 - y0, color)
}

# ------------------------------------------------
function svgBegin (wid, ht, scale)  {
    Wid = wid
    Ht  = ht
    S   = scale

    comment(sprintf("svgBegin: scale %.2f, PixPwrScIn %.2f", S, PixPerScIn))

    printf "<svg version=\"1.1\" baseProfile=\"full\"\n"
    printf "     width=\"%d\" height=\"%d\"", S*Wid, S*Ht
    printf "  xmlns=\"http://www.w3.org/2000/svg\">\n"

  # bgCol = "beige"
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
    Pi = atan2(0, -1)
    PixPerIn   = 96
    PixPerScIn = PixPerIn * 1/87
    PixPerScFt = PixPerIn * 12/87
}

# ------------------------------------------------
function door (x, y, wid, ht, col, _col, _row)  {
    comment(sprintf("       door:"))
    x += x0;    y += y0

    brdr = 4/12
    wid1 = wid -2*brdr
    wid2 = wid1 /2
    ht1  = ht  -brdr
    x1   = x +brdr
    x2   = x +wid/2
    xN   = x +wid -brdr
    yN   = y +ht  - brdr

    # blank out siding + outline
    rectWh(x,  y, wid, ht, "gray", "white")

    # outlines of 2 doors
    rectWh(x1, y, wid2, ht1, "black", "", 1)
    rectWh(x2, y, wid2, ht1, "black", "", 1)

    printf "\n"
    dx = 6/12
    N  = int(wid2 / dx)
    dx = (wid2 / N)
    comment(sprintf("   door: wid2 %.1f N %.1f, dx %.1f", wid2, N, dx))

    for (n = 1; n < N; n++) {
        x3 = x1 +n*dx
        line(x3, y, x3, y +ht1, "gray")

        x4 = x2 +n*dx
        line(x4, y, x4, y +ht1, "gray")
    }
}

# ------------------------------------------------
function window (x, y, wid, ht, col, _col, _row)  {
    printf "\n"
    comment(sprintf ("        window: (%d, %d) <%.1f, %.1f> [%d, %d] S %.3f", \
                x, y, wid, ht, _col, _row, S))

    x += x0;     y += y0
    # ----------------------------
    # interior glass
    brdr = 4 / 12
    x2   = x    +brdr
    y2   = y    +brdr
    wid2 = wid  -2*brdr
    ht2  = ht   -2*brdr

    rectWh(x,  y,  wid,  ht,  "gray", "white", 1)
    rectWh(x2, y2, wid2, ht2, "none", "gray", 0)

    # ----------------------------
    # panes
    dd = (1 /12) * PixPerScFt
    if (_row && _col)  {
        # verticals
        dw = wid2/_col
        for (c = 1; c < _col; c++)  {
            x1 = x2+ c*dw
            line(x1, y, x1, y +ht, "white", dd)
        }

        # horizontals
        for (r = 1; r < _row; r++)  {
            y1 = y2 + r*ht/_row
            line(x, y1, x +wid, y1, "white", dd)
        }
    }
    else  {
        printf "\n"
        comment(sprintf("    window: panes, dd %d, wid %d", dd, wid));
        # vertical
        line(x +wid/2, y+ ht/2, x +wid/2, y +ht, "white", dd)

        # horizontals
        line(x, y+ ht/2,   x +wid, y +ht/2,   "white", dd+1)
        line(x, y+ ht*3/4, x +wid, y +ht*3/4, "white", dd)
    }
}

# ------------------------------------------------
function cmnt (s) {
    printf "\n<!-- %s -->\n", s
}

# ------------------------------------------------
function bldg (x0, y0, widFt, htFt, peakFt, color) {
    comment(sprintf("bldg: widFt %d, htFt %d, peakFt %d, %s", \
                                        widFt, htFt, peakFt, color))

    svgBegin(widFt +10, htFt +peakFt +10, PixPerScFt)
    
    n = 0; x = x0; y = y0; 
    vecX [n] = x;           vecY [n++] = y
    vecX [n] = x;           vecY [n++] = y + htFt
    vecX [n] = x + widFt/2; vecY [n++] = y + htFt + peakFt
    vecX [n] = x + widFt;   vecY [n++] = y + htFt
    vecX [n] = x + widFt;   vecY [n++] = y
    vecX [n] = x;           vecY [n++] = y
    path(vecX, vecY, n, "none", 1, color)
}

# ------------------------------------------------
function siding (size) {
    ratio = peakFt / (widFt/2)

    if (1)
        for (y = y0; y < y0 + htFt; y += size/12)
            line(x0, y, x0 + widFt, y, "gray")

    for (y = y0 + htFt; y < y0 + htFt + peakFt; y += size/12)  {
        dy = y - (y0 + htFt)
        dx = dy / ratio
        line(x0 + dx, y, x0 + widFt -dx, y, "gray")
    }
}

# ------------------------------------------------
function dock (dockHtFt) {
    printf "\n"
    deckThick = 0.5

    y1 = y0 +dockHtFt -deckThick/2

    # --------------------------------------
    # spacing
    dx   = 6                        # dist between posts
    N    = int(widFt / dx)
    dx   = (widFt / N)

    dd   = 8/12                     # thickness of post
    _x2  = x0 +dd/2
    line(_x2, y0, _x2, y1, "gray", PixPerScFt*dd)

    stroke = PixPerScFt*dd
    for (n = 1; n <= N; n++)  {
        _x1 = x0 + n*dx -dd/2
        line(_x1, y0,   _x1, y1,  "gray", stroke)
        line(_x2, y0,   _x1, y1,  "gray", stroke)
        line(_x1, y0,   _x2, y1,  "gray", stroke)
        _x2 = _x1
    }

    # --------------------------------------
    # deck itself
    line(x0, y1, x0 +widFt, y1, "black", PixPerScFt*deckThick)
}

# ------------------------------------------------
function sign (x, y, wid, fontSz, text) {
    comment(sprintf("sign: (%d, %d) font %d,  %s", x, y, fontSz, text))

  # wid  *= PixPerScFt
    dy    = fontSz / PixPerScFt

    rectWh( x0 +x -wid/2, y0 +y, wid, dy, "white", "white")
    annoC(x0+x, y0+y, text, fontSz)
}

# ------------------------------------------------
NF == 0 || $1 == "#"  {
    next
}

/bldg/   { 
    x0    = $2;  y0   = $3
    widFt = $4;  htFt = $5;  peakFt = $6;  color = $7
    bldg( x0, y0, widFt, htFt, peakFt, color);              next }
/dock/   { dock(     $2);                                   next }
/door/   { door(     $2, $3, $4, $5, $6, $7, $8);           next }
/line/   { line(     $2, $3, $4, $5, $6, $7);               next }
/siding/ { siding(   $2);                                   next }
/sign/   { sign(     $2, $3, $4, $5, substr($0, index($0, $6))); next }
/space/  {                                                  next }
/window/ { window(   $2, $3, $4/12, $5/12, $6, $7, $8);           next }

# --------------------------------------------------------------------
END {
    svgEnd()
}' $*

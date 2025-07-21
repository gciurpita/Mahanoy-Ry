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
function line (x0, y0, x1, y1, color, wid)  {
    printf "  <line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\"", \
        S*x0, S*mapY(y0), S*x1, S*mapY(y1)
    if ("" == wid)
        wid = 1
    printf " style=\"stroke:%s;stroke-width:%d\"", color, wid
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
function path (vecX, vecY, N, col, prXy) {
    printf "<path d=\"M %d %d",  S*vecX [0], S*mapY(vecY [0])
    for (n = 1; n < N; n++) {
        printf "\n         L %3d %4d", S*vecX [n], S*mapY(vecY [n])
    }
    printf "\"\n       stroke=\"%s\" stroke-width=\"2\" fill=\"none\" />\n", col

    if (prXy)
        for (n = 0; n < N; n++)
            anno(vecX [n] +0.2, vecY [n] +0.2, \
                    sprintf("%d, %d", vecX [n] -vecX [0], vecY [n] -vecY [0]))
}

# ------------------------------------------------
function rect (x0, y0, wid, ht, col, fill)  {
    printf " <rect   x=\"%d\" y=\"%d\" width=\"%d\" height=\"%d\"", \
                S*x0, S*mapY(y0), S*wid, S*ht
        printf " style=\"fill:%s;stroke:%s;stroke-width:1\"/>\n", fill, col
}

# ------------------------------------------------
function svgBegin (wid, ht, scale, bgCol)  {
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
BEGIN  {
    Pi       = atan2(0, -1)
    PixPerIn = 96
    PixPerFt = PixPerIn * 12 / 87       # scale feet
}

# ------------------------------------------------
{   comment($0)  }

NF == 0 || $1 == "#"  {
    next
}

/deck/     { deck     = $2;                                         next }
/depth/    { depth    = $2;                                         next }
/door/     { nDoor    = $2; doorWid = $3; doorHt = $4;              next }
/peak/     { peak     = $2;                                         next }
/story/    { nStory   = $2; htStory = $3;                           next }
/width/    { widFt    = $2;                                         next }
/windows/  { nWindow  = $2; windWid = $3/12; windHt = $4/12;        next }

# --------------------------------------
{
    printf "Error: mkBldg unknown - "
    print
    err++; exit
}

# --------------------------------------------------------------------
function pr () {
    comment(sprintf("  sv: %6d %6d", vecX [N-1], vecY [N-1]))
}

# --------------------------------------------------------------------
function frontView (x0, y0, wid, htFt,  col) {
    printf "\n"
    comment("frontView:")

    N = 0
    vecX [N] = x0;                  vecY [N++] = y0;                pr()
    vecX [N] = vecX [N-1] + wid;    vecY [N++] = vecY [N-1];        pr()
    vecX [N] = vecX [N-1];          vecY [N++] = vecY [N-1] + htFt; pr()
    vecX [N] = vecX [0];            vecY [N++] = vecY [N-1];        pr()
    vecX [N] = vecX [0];            vecY [N++] = vecY [0];          pr()

    path(vecX, vecY, N, col, 0)

    anno(vecX [1], vecY [1], sprintf("%d, %d", \
                            vecX [1]-vecX [0], vecY [1]-vecY [0]))

    anno(vecX [2], vecY [2], sprintf("%d, %d", \
                            vecX [2]-vecX [0], vecY [2]-vecY [0]))

    _y   = y0 + deck
    for (n = 0; n <= nStory; n++)  {
        line(x0, _y, x0+wid, _y, col)
        anno(x0 +wid +0.2, _y, sprintf("%d, %d", wid, _y-y0))
        _y  += htStory
    }

    windows(x0, y0, wid, col)
}

# --------------------------------------------------------------------
function sideView (x0, y0, wid, htFt, pkFt, col, _y) {
    printf "\n"
    comment("sideView:")

    N = 0
    vecX [N] = x0;                  vecY [N++] = y0;                pr()
    vecX [N] = vecX [N-1] + wid;    vecY [N++] = vecY [N-1];        pr()
    vecX [N] = vecX [N-1];          vecY [N++] = vecY [N-1] + htFt; pr()
    vecX [N] = vecX [N-1] - wid/2;  vecY [N++] = vecY [N-1] + pkFt; pr()
    vecX [N] = vecX [N-1] - wid/2;  vecY [N++] = vecY [N-1] - pkFt; pr()
    vecX [N] = vecX [0];            vecY [N++] = vecY [0];          pr()

    path(vecX, vecY, N, col, 1)

    _y   = y0 + deck
    for (n = 0; n <= nStory; n++)  {
        line(x0, _y, x0+wid, _y, col)
        _y  += htStory
    }

    windows(x0, y0, wid, col)
}

# ------------------------------------------------
function windows (x0, y0, widFt, col, _wid) {
    printf "\n"
    comment(sprintf(" windows: wid %.2f, ht %.2f", windWid,windHt))

    nW   =  int((widFt -2) /windWid)      # 2 = guaranteed space

    _wid = nW * windWid
    if (! (nW % 2))
        _wid -= windWid

    x1 = (widFt -_wid) / 2

    comment(sprintf(" windows %.1f, nW %2d, _wid %.2f, x1 %.2f", \
                        depth, nW, _wid, x1))

    y1  = y0 +deck +(84 - widHt)/12
    x1 += x0
    for (n = 0; n <  nStory; n++)  {
        for (m = 0; m < nW; m += 2)  {
            x = x1 + m*windWid
            rect(x, y1, windWid, windHt, "none", col)

            for (dx = 0; dx <= windWid; dx +=  windWid/4) {
                x2 = x+dx
                line(x2, y1, x2, y1-windHt, "gray", 2)
            }

            for (y = y1; y >= y1-windHt; y -= windHt/4)
                line(x, y, x+windWid, y, "gray", 2)
        }
        y1 += htStory
    }
}

# ------------------------------------------------
END {
  # print "<meta http-equiv=\"refresh\" content=\"4\">"

    col = "black"; x0 = 2;  y0 = 2;

    wid    = widFt
    pkFt   = depth /3
    htFt   = deck + nStory*htStory
    htPkFt = htFt + pkFt

    svgBegin(5 +widFt +depth, htPkFt+5, PixPerFt)

    sideView( x0,        y0, depth, htFt, pkFt, col)
    frontView(x0 +depth, y0, widFt, htFt,       col)

    svgEnd(title)
}' $* 

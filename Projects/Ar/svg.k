# svg drawing routines

awk '
# ------------------------------------------------
function anno (x, y, text, font)  {
    if (! font)
        font = Font
    printf "  <text x=\"%d\" y=\"%d\"", S*x, S*mapY(y)
    printf " font-family=\"Verdana\""
    printf " font-size=\"%d\"", font
    printf ">%s</text>\n", text
}

# ------------------------------------------------
function annoC (x, y, text, font)  {
    if (! font)
        font = Font
    printf "  <text x=\"%d\" y=\"%d\"", S*x, S*mapY(y-font/(S*2))
    printf " font-family=\"Verdana\""
    printf " text-anchor=\"middle\""
    printf " font-size=\"%d\"", font
    printf ">%s</text>\n", text
}

# ------------------------------------------------
function annoR (x, y, text, font)  {
    if (! font)
        font = Font
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
function rect (xC, yC, wid, ht, color, lbl, _x, _y)  {
    _x = xC - wid/2
    _y = yC + ht/2
    printf "  <rect x=\"%d\" y=\"%d\" width=\"%d\" height=\"%d\"", \
            S*_x, S*mapY(_y), S*wid, S*ht
    printf " style=\"fill:none;stroke:%s;stroke-width:1\"", color
    printf " />\n"

    if (lbl)  {
        sym    [lbl] = 1
        locX   [lbl] = xC
        locY   [lbl] = yC
        objWid [lbl] = wid
        objHt  [lbl] = ht

        annoC(xC, yC, lbl)
    }
}

# ------------------------------------------------
function mapY (y)  {
    return Ht - y
}

# ------------------------------------------------
function svgBegin (wid, ht, scale, bgCol)  {
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
    Font = 10
}

# ------------------------------------------------
function error (msg) {
    printf "Error: %s\n", msg
    printf "    %s\n", $0
    exit
}

# ------------------------------------------------
function dispSym () {
    printf "# dispSym:\n"
    for (s in sym)
        if (sym [s])
            printf "#            %s\n", s
}

# ------------------------------------------------
function getXy (s) {
    if (dbg) printf "#   getXy: %s\n", s

    if (sym [s])  {
        x = locX [s]
        y = locY [s]
    }
    else if ("(" == substr(s, 1, 1))  {
        if (2 != split(substr(s, 2), fld, ","))
            error("getXy: too few args in ()")
        x = int(fld [1])
        y = int(fld [2])
    }
    else {
        dispSym()
        error("getXy: " s ", neither sym nor ()")
    }

    if (dbg) printf "#    getXy: x %d, y %d\n", x, y
}

# ------------------------------------------------
function locOf (s, _x, _y) {
    if (dbg) printf "#  locOf: %s\n", s

    F = split(s, fld, "+")
    if (2 <= F)  {
        printf "## locOf: + case, %s\n", s
        if (fld [1])
            getXy(fld [1])
        for (f = 2; f <= F; f++)  {
            _x  = x;  _y  = y
            getXy(fld [f]); x  += _x; y  += _y
        }
    }
    else {
        printf "## locOf: mono case\n"
        getXy(s)
    }

    if (dbg) printf "#  locOf: x %d, y %d\n", x, y
}

# ------------------------------------------------
NF == 0 || $1 == "#"  {
    next
}

dbg { printf "##  %s\n", $0 }

/dbg/  { dbg = $2;                      next }
/font/ { Font = $2;                     next }
/quit/ { exit }

# ------------------------------------------------
"=" == $2  { locOf($3); sym [$1]=1; locX [$1] = x; locY [$1] = y; next; }

/lineTo/  {
    x0 = x; y0 = y
    if (dbg) printf "# lineTo: x %d, y %d\n", x0, y0

    locOf($2)
    line(x0, y0, x, y, $3)
    next
}

/moveTo/  {
    if (dbg) printf "# moveTo:\n"
    locOf($2)
    next
}

/rect/    { x=$2; y=$3; rect(x, y, $4, $5, $6, $7); next; }
/space/   { svgBegin($2, $3, $4, $5);               next; }
/text/    { annoC(x, y, substr($0, index($0, $2))); next; }

{       error() }

# --------------------------------------------------------------------
END {
    svgEnd()
}' $* << **END**
    space 450 260 1.5 beige
    font  14

    rect  20 145 30 10 black DccA
    rect  20 105 30 10 black DccB

    rect 430 145 30 10 black X
    rect 430 105 30 10 black Y

    rect  60 230 50 50 black Pwr
    rect 120 160 50 50 black Det
    rect 210 200 50 70 black Processor

    rect 350 160 50 40 black XAp
    rect 350 220 50 40 black XBn

    rect 350  90 50 40  black XAn
    rect 350  30 50 40  black XBp
    
    moveTo DccA+(15,0)
    lineTo Det+(-25,-15)    red
    moveTo Det+(25,-15)     red
    lineTo XAp+(-25,-15)    red

    moveTo DccA+(290,0)
    lineTo DccA+(290,60)   red
    lineTo +(15,0)      red

    moveTo XAp+(25,-15)
    lineTo X+(-15,0)      red

    moveTo XBn+(25,-15)
    lineTo +(20,0)      blue
    lineTo +(0,-100)    blue

    moveTo DccB+(15,0)
    lineTo XAn+(-25,15) blue

    moveTo XAn+(-40,15)
    lineTo +(0,-60)     blue
    lineTo +(15,0)      blue

    moveTo XAn+(25,15)
    lineTo Y+(-15,0)    blue

    moveTo XBp+(25,15)
    lineTo +(30,0)      red
    lineTo +(0,100)     red

#   Det connections    
    moveTo Det+(25,15)
    lineTo +(40,0)      black

#   Vss connections    
    moveTo XBn+(25,0)
    lineTo +(10,0)      black

    moveTo XAp+(25,0)
    lineTo +(10,0)      black

    moveTo XAn+(25,0)
    lineTo +(10,0)      black

    moveTo XBp+(25,0)
    lineTo +(10,0)      black
    lineTo +(0,220)     black
    lineTo +(-300,0)     black

    moveTo +(10,5)
    text Va

#   Bias connections    
    moveTo XBn+(-25,0)
    lineTo +(-90,0)      black

    moveTo XAp+(-25,0)
    lineTo +(-40,0)      black
    lineTo +(0,50)       black
    lineTo +(-50,0)      black

    moveTo XAn+(-25,0)
    lineTo +(-50,0)      black
    lineTo +(0,100)       black
    lineTo +(-40,0)      black

    moveTo XBp+(-25,0)
    lineTo +(-60,0)      black
    lineTo +(0,150)      black
    lineTo +(-30,0)      black

#   Pwr connections    
    moveTo Pwr+(-15,-25)
    lineTo +(0,-60)      red

    moveTo Pwr+(0,-25)
    lineTo +(0,-100)     blue

    moveTo Pwr+(25,-10)
    lineTo +(100,0)      black
    moveTo +(-90,5)
    text Vb

    moveTo Det+(0,20)
    lineTo +(0,40)      black

    moveTo Pwr+(15,-25)
    lineTo +(0,-10)     black
    lineTo +(-3,6)     black
    lineTo +(6,0)      black
    lineTo +(-3,-6)    black

    moveTo Det+(0,-25)
    lineTo +(0,-10)     black
    lineTo +(-3,6)     black
    lineTo +(6,0)      black
    lineTo +(-3,-6)    black

    moveTo Processor+(0,-35)
    lineTo +(0,-10)     black
    lineTo +(-3,6)     black
    lineTo +(6,0)      black
    lineTo +(-3,-6)    black

    moveTo XBn+(0,-20)
    lineTo +(0,-10)     black
    lineTo +(-3,6)     black
    lineTo +(6,0)      black
    lineTo +(-3,-6)    black

    moveTo XAp+(0,-20)
    lineTo +(0,-10)     black
    lineTo +(-3,6)     black
    lineTo +(6,0)      black
    lineTo +(-3,-6)    black

    moveTo XAn+(0,-20)
    lineTo +(0,-10)     black
    lineTo +(-3,6)     black
    lineTo +(6,0)      black
    lineTo +(-3,-6)    black

    moveTo XBp+(0,-20)
    lineTo +(0,-10)     black
    lineTo +(-3,6)     black
    lineTo +(6,0)      black
    lineTo +(-3,-6)    black

**END**

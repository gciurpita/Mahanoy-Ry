# yet another track drawing too
awk '
# --------------------------------------------------------------------
function anno (x, y, text)  {
    yAnno += dyAnno
    printf "anno %8.4f %8.4f  %s\n", x, y, text
}

# ------------------------------------------------
# standard orientation
function arc (x0, y0, a0, a1, rad, col, a)  {
    printf "next\n"

    if (a1 < a0)  {
        a  = a0
        a0 = a1
        a1 = a
    }

    for (a = a0; a <= a1; a += 2)  {
        w = a * Pi / 180
        printf "  %8.4f %8.4f\n", x0+(rad * cos(w)), y0+(rad * sin(w))
    }

    w = a1 * Pi / 180
    printf "  %8.4f %8.4f\n", x0+(rad * cos(w)), y0+(rad * sin(w))
    printf "\n"
}

# ------------------------------------------------
function line (x0, y0, x1, y1, color)  {
    printf "next\n"
    printf " %8.4f  %8.4f\n", x0, y0
    printf " %8.4f  %8.4f\n", x1, y1
    printf "\n"
}

# ------------------------------------------------
function mark (x, y, dx, dy, color)  {
    printf "\ncolor=%s\n", color
    printf "next\n"
    printf " %8.4f  %8.4f\n", x, y-dy
    printf " %8.4f  %8.4f\n", x, y+dy

    printf "next\n"
    printf " %8.4f  %8.4f\n", x-dx, y
    printf " %8.4f  %8.4f\n", x+dx, y
}

# --------------------------------------------------------------------
# ------------------------------------------------
function ladder (x0, y0, ang, rL, N, len, col) {
    printf "# ladder: x0 %6.2f, y0 %6.2f, ang %6.2f, rl %d, N %d, len %d, %s\n", \
                        x0, y0, ang, rL, N, len, col


    for (n = N0; n < N; n++)  {
        if (! col)
            col = "dark-gray"
        to(x0, y0, ang, rL, dir=1, col)

        if (len)  {
            if (! col)
                col = "blue"
            line(x, y, len, y, col)
        }
        x0  = x1
        y0  = y1
    }
}

# ------------------------------------------------
function radius (x0, y0, ang0, ang1, rad, col) {
    if (! col)
        col = "cyan"

    c = cos(ang0 * Pi / 180)
    s = sin(ang0 * Pi / 180)

    xC = x0 - ToRad * c
    yC = y0 - ToRad * s

    arc(xC, yC, ang0, ang1, ToRad, col)

    c = cos(ang1 * Pi / 180)
    s = sin(ang1 * Pi / 180)

    x  = xC + ToRad * c
    y  = yC + ToRad * s
}

# ------------------------------------------------
function side (x0, y0, ang, rL, N, len, col) {
    to(x0, y0, ang, rL, len, col)
    if (len)
        line(x0, y0, len, y0, col)

    ladder(x, y, a, ! rL, N, len, col)
}

# ------------------------------------------------
function siding (x0, y0, ang, rL, N, len, col) {
    to(x0, y0, ang, rL, ToRight=1, col)
    x10 = x;  y10 = y           # x,y of diverging rail
    x11 = x1; y11 = y1
    a10 = a

    radius(x, y, 90 + ToAng + ang, 90 + ang, ToRad, col)
    x12 = x;  y12 = y

    if (! col)
        col = "dark-gray"
    to(x0+len, y0, ang, 1-rL, toRight=0, colol = col)
    x20 = x; y20 = y
    line(x11, y11, x1, y1, col)

    if (! col)
        col = "red"
    radius(x20, y20, 90 - ToAng + ang, 90 + ang, ToRad, col)

    if (! col)
        col = "green"
    line(x12, y12, x, y, col)
}

# ------------------------------------------------
function to (x0, y0, ang, rL, toRight, col) {
    if (! col)
        col = "dark-gray"

    c = cos(ang * Pi / 180)
    s = sin(ang * Pi / 180)

    # ----------------------------
    if (1 == toRight)  {
        # locate pts
        xA = x0 + c * ToExt
        yA = y0 + s * ToExt

        # locate frog
        xB = x0 + c * (ToExt + ToLen)
        yB = y0 + s * (ToExt + ToLen)

        # locate end of straight
        x1 = x0 + c * (ToLen + 2 * ToExt)
        y1 = y0 + s * (ToLen + 2 * ToExt)

        line(x0, y0, xA, yA, "yellow")      # col)
        line(xA, yA, xB, yB, col)
        line(xB, yB, x1, y1, "yellow")      # col)

        if (rL)  {
            xC = xA + ToRad * s
            yC = yA - ToRad * c
            a0 = ang + 90
            a1 =  a0 - ToAng
            a  = ang - ToAng
        }
        else {
            xC = xA - ToRad * s
            yC = yA + ToRad * c
            a0 = ang - 90
            a1 =  a0 + ToAng
            a  = ang + ToAng
        }
        arc(xC, yC, a0, a1,ToRad, col)

        # ----------------------------
        c1 = cos(a1 * Pi / 180)
        s1 = sin(a1 * Pi / 180)

        xD = xC + ToRad  * c1
        yD = yC + ToRad  * s1

        # ----------------------------
        # extend end-point of diverging rail
        c  = ToExt * cos(a * Pi/180)
        s  = ToExt * sin(a * Pi/180)
        x  = xD + c
        y  = yD + s
        line(xD, yD, x, y, "yellow")
    }
    else {
        printf "# toLeft %d\n", toLeft

        xA = x0 - c * ToExt
        yA = y0 + s * ToExt

        # locate frog
        xB = x0 - c * (ToExt + ToLen)
        yB = y0 + s * (ToExt + ToLen)

        # locate end of straight
        x1 = x0 - c * (ToLen + 2 * ToExt)
        y1 = y0 + s * (ToLen + 2 * ToExt)

        line(x0, y0, xA, yA, "yellow")
        line(xA, yA, xB, yB, col)
        line(xB, yB, x1, y1, "yellow")

        if (rL)  {
            printf "# rL\n"
            xC = xA + ToRad * s
            yC = yA + ToRad * c
            a0 = 270  + ang
            a1 =  a0 - ToAng
            a  = ang - ToAng
        }
        else {
            printf "# ! rL\n"
            xC = xA + ToRad * s
            yC = yA - ToRad * c
            a0 =  90 - ang 
            a1 =  a0 + ToAng
            a  = ang + ToAng
        }
        arc(xC, yC, a0, a1,ToRad, col)

        # ----------------------------
        c1 = cos(a1 * Pi / 180)
        s1 = sin(a1 * Pi / 180)

        xD = xC + ToRad  * c1
        yD = yC + ToRad  * s1

        # ----------------------------
        # extend end-point of diverging rail
        c  = cos(a * Pi/180)
        s  = sin(a * Pi/180)
        x  = xD - c * ToExt
        y  = yD - s * ToExt
        line(xD, yD, x, y, "yellow")
    }

    printf "# to: Fn %d, ToAng %6.2f, Tolen %6.2f\n",     ToFn, ToAng, ToLen
    printf "# x0 %6.2f, y0 %6.2f, ang %6.2f, rL %d\n",    x0, y0, ang, rL
    printf "# xA %6.2f, yA %6.2f\n",                      xA, yA
    printf "# xC %6.2f, yC %6.2f, a0  %6.2f, a1 %6.2f\n", xC, yC, a0, a1
    printf "# xD %6.2f, yD %6.2f, a   %6.2f\n",           xD, yD, a
    printf "# xB %6.2f, yB %6.2f\n",                      xB, yB
    printf "# x1 %6.2f, y1 %6.2f\n",                      x1, y1

    printf "# c  %6.2f, s  %6.2f, a  %6.2f\n", c,  s,  a
    printf "# x  %6.2f, y  %6.2f\n",           x,  y
    printf "# --------------------\n"
}

# ------------------------------------------------
# determine endpoints for 2 rail turnout
function turnout (x0, y0, ang) {

    line(0, 0,  0, 6, "black")
    printf "thickness = 2\n"

    to(x0, y0+3, ang, rL=1, toRight=1, "dark-gray")

    to(x0, y0+2, ang, rL=1, toRight=0, "dark-gray")
    to(x0, y0+1, ang, rL=0, toRight=0, "dark-gray")

    to(x0, y0,   ang, rL=0, toRight=1, "dark-gray")

    if (1)
        return

    y1 = y0 + G/2
    y2 = y0 - G/2

    col2 = "cyan"
    line(x0, y1, x0+ToLen, y1, col2)
    line(x0, y2, x0+ToLen, y2, col2)

    col3 = "red"
    xC   = x0
    yC   = y0 + ToRad
    a0   = ang -90
    a1   = ang -90 + ToAng
    arc(xC, yC, a0, a1, ToRad - G/2, col3)
    arc(xC, yC, a0, a1, ToRad + G/2, col3)
    printf "# turnout: a0 %6.2f, a1 %6.2f\n", a0, a1

    # ----------------------------
    # 1 in. extension beyond frog
    col4 = "yellow"
    c    = cos(ToAng * Pi/180)
    s    = sin(ToAng * Pi/180)
    x1   = x0 + ToLen
    x3   = x1 + c
    y3   = y1 + s
    line(x1, y1, x3, y3, col4)
    printf "# turnout: x1 %6.3f, y1 %6.3f, x3 %6.3f, y3 %6.3f, s %.4f\n", \
                                        x1, y1, x3, y3, s

    x4  = x3 - s * G/2
    y4  = y3 + c * G/2
    line(x3, y3, x4, y4, col4)

    # ----------------------------
    # another approach
    rad = sqrt(1^2 + (G/2)^2)
    a2  = ToAng + atan2(G/2, 1) * 180/Pi
    c    = cos(a2 * Pi/180)
    s    = sin(a2 * Pi/180)
    x5   = x1 + rad * c
    y5   = y1 + rad * s
    line(x1, y1, x5, y5, col4)
    printf "title_x: a2 %6.2f, x5 %6.2f\n", a2, x5
}

# ------------------------------------------------
function yard (N, len, col) {
    line(0, 0, 0, 16, "black")
    siding(0,   2, a=0, rL=0, N, len, col)

    ladder(x10, y10, a10, ! rL, N, len, col)

    x = "1-mainline 2-arrival 3-outbound 4-loc-1 5-loc-2 7-locos 8-cabeese"
    F = split(x, text, " ")
    f = 1
    X = 70
    for (y = 2.1; f <= F; y += 1.55)
        printf "anno %d %8.4f %s\n", X, y, text [f++]

    printf "title_x frog# %d\n", ToFn
}

# --------------------------------------------------------------------
BEGIN  {
    Pi    = atan2(0, -1)
    G     = 0.65

    AngSdg = 10
    ColTrk = "orange"

    printf "title_x \n"
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
function xyPairs (col, thick, label) {
    printf "thickness = %s\n",  thick
    if (col)
        printf "color = %s\n",      col
    printf "next\n"
    for (n = 2; n < NF; n += 2)
        printf " %8.2f %8.2f\n", $n, $(n+1)

}

# ------------------------------------------------
/^ *#/  { next }
NF      { printf "# %s\n", $0 }
/quit/  { exit }

/bench/ { xyPairs("white", 2, $1);    next }
/color/ { printf "color = %s\n", col=$2;  next }
/obj/   { xyPairs("",  2, $1);    next }
/room/  { xyPairs("blue",  2, $1);    next }
/title/ { printf "title  %s\n", substr($0, index($0, $2)); next }

# ------------------------------------------------
/curve/ {
    rad  = $2
    dAng = $3
    dbg  = $4
    curve($2, $3, $4)
}

# ------------------------------------------------
function curve (rad, dAng, dbg) {
    printf "title_x curve: dbg %s\n", dbg

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

    col = ColTrk
    if ($4)
        col = $4

    c = cos(a0 * Pi / 180)
    s = sin(a0 * Pi / 180)
    xC = xPos - c * rad
    yC = yPos - s * rad


    if ("" != dbg)
        mark(xC, yC, 1, 1, "yellow")

    arc(xC, yC, a0, a1, rad, col)

    c    = cos(a1 * Pi / 180);   s    = sin(a1 * Pi / 180)
    xPos = xC + c*rad;           yPos = yC + s*rad

    next
}

# --------------------------------------
/lbl/ {
    printf "# lbl: %s, xPos %6d, yPos %d, dir %d\n", $2, xPos, yPos, dir
    lblX [$2] = xPos;  lblY [$2] = yPos; lblDir [$2] = dir
    anno(xPos, yPos, $2)
    next
}

# --------------------------------------
/mvto/ {
    lbl = $2
    if ("" == lblX [lbl])
        error()

    xPos = lblX [lbl]; yPos = lblY [lbl]; dir = lblDir [lbl]

    if ("rev" == $3)
        dir = (dir + 180) % 360

    printf "# mvto: xPos %6d, yPos %d, dir %d\n", xPos, yPos, dir
    next
}

# --------------------------------------
/pos/   { xPos = $2; yPos = $3; dir = $4;
  # mark(xPos, yPos, 1, 1, "red")
    printf "thickness = 1\n"
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
    dx  = $4 - $2;   xC = ($2+$4) / 2
    dy  = $5 - $3;   yC = ($3+$5) / 2

    aspect = 5/8
    if ($6)
        aspect = $6

    # black line establishing screen x/y ranges
    printf "color = %s\n", "black"
    if (abs(dx) < abs(dy))  {
        dXd2 = (aspect * dy) / 2
        line(xC - dXd2, $3, xC + dXd2, $5, col)
        rad = dx/2
    }
    else  {
        dYd2 = (aspect * dx) / 2
        line($2, yC - dYd2, $2+dx, yC + dYd2, col)
        rad = dy/2
    }

    # aspect circle
    printf "# rad %6.2f, dx %6.2f, dy %6.2f\n", rad, dx, dy
    cn = 33
    printf "set_color %d = ( %d, %d, %d )\n", cn, 50, 50, 50

    printf "color = %s\n", cn
    arc(($4+$2)/2, ($5+$3)/2, 0, 360, rad, cn)

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
    printf "# sdg: dirLst %.2f, dir %.2f, angSdg %.2f, lenDiv %.2f\n", \
        dirLst, dir, angSdg, lenDiv

    str(lenDiv)

    printf "# sdg chk 1\n"
    dir = dirLst
    str(len)
}

# --------------------------------------
/str/   {
    str($2); next
}

# ----------------------------
function str (len) {
    printf "# str: xPos %6d, yPos %d, dir %d, len %.2f\n", xPos, yPos, dir, len
    x0   = xPos;                  y0   = yPos
    c    = cos(dir * Pi / 180);   s    = sin(dir * Pi / 180)
    xPos = x0 + c * len;          yPos = y0 + s * len

    line(x0, y0, xPos, yPos, ColTrk)
}

# ------------------------------------------------
NF { 
    error("unkown")
}

# --------------------------------------------------------------------
END {
}' $*

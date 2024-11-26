awk '
# --------------------------------------------------------------------
function anno (x, y, text, color)  {
    yAnno += dyAnno
    printf "anno %8.4f %8.4f  %s\n", x, y, text
}

# ------------------------------------------------
# standard orientation
function arc (x0, y0, a0, a1, rad, col, a)  {
    printf "next\ncolor = %s\n", col

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
    printf "next\ncolor=%s\n", color
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
function to (x0, y0, ang, rL, col) {
    c = cos(ang * Pi / 180)
    s = sin(ang * Pi / 180)

    x1 = x0 + ToLen * c
    y1 = y0 + ToLen * s
    line(x0, y0, x1, y1, "green")

    # ----------------------------
    if (rL)  {
        xC = x0 + ToRad * s
        yC = y0 - ToRad * c
        a0 = ang + 90
        a1 =  a0 - ToAng
        a  = ang - ToAng
    }
    else {
        xC = x0 - ToRad * s
        yC = y0 + ToRad * c
        a0 = ang - 90
        a1 =  a0 + ToAng
        a  = ang + ToAng
    }
    arc(xC, yC, a0, a1,ToRad, col)

    # ----------------------------
    c1 = cos(a1 * Pi / 180)
    s1 = sin(a1 * Pi / 180)

    x = xC + ToRad  * c1
    y = yC + ToRad  * s1

    printf "# x0 %6.2f, y0 %6.2f, ang %6.2f, rL %d\n",    x0, y0, ang, rL
    printf "# x1 %6.2f, y1 %6.2f\n",                      x1, y1
    printf "# xC %6.2f, yC %6.2f, a0  %6.2f, a1 %6.2f\n", xC, yC, a0, a1
    printf "# x  %6.2f, y  %6.2f, a   %6.2f",             x,  y,  a
    printf "\n"
}

# ------------------------------------------------
function ladder (x0, y0, ang, rL, N, len, col) {
    for (n = 0; n < N; n++)  {
        to(x0, y0, ang, rL, col)
        if (len)
            line(x, y, len, y, col)
        x0  = x1
        y0  = y1
    }
}

# ------------------------------------------------
function side (x0, y0, ang, rL, N, len, col) {
    to(x0, y0, ang, rL, col)
    if (len)
        line(x0, y0, len, y0, col)

    ladder(x, y, a, ! rL, N, len, col)
}

# ------------------------------------------------
BEGIN  {
    Pi    = atan2(0, -1)

    ToFn  = 6
    ToLen = 7.8
    ToAng = 9.5
    ToRad = 12*339/87

    Len   = 100
    N     = 5

    side(0,     0, a=0, rL=0, N, Len, "red")
    side(ToLen, 0, a=0, rL=1, N, Len, "cyan")

    side(0,   2*N, a=0, rL=0, 2*N, Len, "red")
}' $* | tee ladder.xgr

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

    if (a0 > a1) {
        tmp = a0
        a0  = a1
        a1  = tmp
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
function rotate (x0, y0, ang) {
    c = cos(ang * Pi / 180)
    s = sin(ang * Pi / 180)
    x = c*x0 - s*y0
    y = s*x0 + c*y0
}

# ------------------------------------------------
function rotateLine (x0, y0, len, ang) {
    rotate( 0,    Gd2, ang); x1 = x0 + x; y1 = y0 + y
    rotate( len,  Gd2, ang); x2 = x0 + x; y2 = y0 + y
    line(x1, y1, x2, y2, col)
}

# ------------------------------------------------
function to (x0, y0, ang, fAng, col) {
    L  = 9
    L0 = 1
    Lf = L0 + 7

    # ----------------------------
    # straight
    rotate( 0,    Gd2, ang); x1 = x0 + x; y1 = y0 + y
    rotate( L,    Gd2, ang); x2 = x0 + x; y2 = y0 + y
    line(x1, y1, x2, y2, col)

    rotate( 0,   -Gd2, ang); x3 = x0 + x; y3 = y0 + y
    rotate( L,   -Gd2, ang); x4 = x0 + x; y4 = y0 + y
    line(x3, y3, x4, y4, col)

    # ----------------------------
    # diverging
    angF = fAng
    g    = Gd2
    if (0 > angF)
        g = -g

    printf "to: angF %6.2f, g %6.2f,  %s\n", fAng, g, col

    rotate( 1,    g, angF); x6 = x; y6 = y

    rotate(Lf,    g,    ang); x5 = x0 + x; y5 = y0 + y
    rotate(Lf+x6, y6,   ang); x6 = x0 + x; y6 = y0 + y
    line(x5, y5, x6, y6, col)

    rotate( 0,    2*g,  angF); x7 = x; y7 = y
    rotate( 1,    2*g,  angF); x8 = x; y8 = y

    rotate(Lf+x7, y7+g, ang); x7 = x0 + x; y7 = y0 + y
    rotate(Lf+x8, y8+g, ang); x8 = x0 + x; y8 = y0 + y
    line(x7, y7, x8, y8, col)
}

# ------------------------------------------------
function center (x0, y0, x1, y1) {
    x = (x0 + x1) / 2
    y = (y0 + y1) / 2
}

# ------------------------------------------------
function radial (x0, y0, a0, a1, rad, col) {
    c = cos(a0 * Pi / 180)
    s = sin(a0 * Pi / 180)

    xc = x0 - c * rad
    yc = y0 - s * rad
    arc(xc, yc, a0, a1, rad, col)

  # mark(xc, yc, 1, 1, col)
    printf "# radial: a0 %6.2f, a1 %6.2f, rad %6.2f\n", a0, a1, rad
}

# ------------------------------------------------
function extend (x0, y0, ang, len, col) {
  # mark(x0, y0, 1, 1, "red")
    c  = cos(ang * Pi / 180)
    s  = sin(ang * Pi / 180)
    x2 = x0 + c * len
    y2 = y0 + s * len
    line(x0, y0, x2, y2, col)
}

# ------------------------------------------------
BEGIN  {
    Pi   = atan2(0, -1)
    Gd2  = 0.65 / 2
    Fang = 9.5

    line(0, 0, 20, 20*5/8, "black")
    arc( 5,  2, 0, 360,  3, "dark-gray")


    ang0 = 25
    to( 0, 0, ang0,   Fang, "red")

    x0   = (x6 + x8) / 2
    y0   = (y6 + y8) / 2
    ang1 = ang0 + Fang
    to(x0, y0, ang1, -Fang, "cyan")
    extend(x2, y2, ang1,    6.0, "blue")
    radial(x2, y2, 90+ang1, 90, 28, "cyan")

    x0   = (x6 + x8) / 2
    y0   = (y6 + y8) / 2
    ang2 = ang1 - Fang
    to(x0, y0, ang2,     -Fang, "yellow")
    extend(x2, y2,    ang2, 1.5, "blue")
    radial(x2, y2, 90+ang2, 90, 28, "yellow")

    extend(x6, y6,    ang2-Fang, 4, "blue")
    x6 = x2; y6 = y2
    radial(x6, y6, 90+ang2-Fang, 90, 28, "orange")

    for (y = 14; y <= 18; y+= 2)  {
        line(30, y+Gd2, 40, y+Gd2, "white")
        line(30, y-Gd2, 40, y-Gd2, "white")
    }
}' $* | tee staging2.xgr

# study of ladder in layout staging

awk '
# ------------------------------------------------
function anno (x, y, text, color)  {
    yAnno += dyAnno
    printf "anno %8.4f %8.4f  %s\n", x, y, text
}

# ------------------------------------------------
function arc (x1, y1, a0, a1, rad, col, a)  {
    printf "next\ncolor = %s\n", col

    for (a = a0; a <= a1; a += 2)  {
        w = a * Pi / 180
        printf "  %8.4f %8.4f\n", x1+(rad * sin(w)), y1+(rad * cos(w))
    }
    w = a1 * Pi / 180
    printf "  %8.4f %8.4f\n", x1+(rad * sin(w)), y1+(rad * cos(w))
    printf "\n"
}

# ------------------------------------------------
function line (x1, y1, x2, y2, color)  {
    printf "\nnext\ncolor=%s\n", color
    printf " %8.4f  %8.4f\n", x1, y1
    printf " %8.4f  %8.4f\n", x2, y2
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

# ------------------------------------------------
function measure (x1, y1, x2, y2, color, x, y, len)  {
    printf "color = %s\n", color

    x = (x1 + x2) / 2
    y = (y1 + y2) / 2
    printf "arrow  %8.4f %8.4f  %8.4f %8.4f\n", x1, y1, x, y
    printf "arrow  %8.4f %8.4f  %8.4f %8.4f\n", x2, y2, x, y

    len = sqrt( (x2-x1)^2 + (y2-y1)^2)
    printf "anno   %8.4f %8.4f  %.1f\n", x, y, len
}


# --------------------------------------------------------------------
function dispPt (x, y, p) {
    anno(x, y, sprintf("(%.2f, %.2f) P%d", x, y, p))
}

# ------------------------------------------------
function drawTurnout (id, Tlen, Fang, Trad, \
            xa, ya, x0, y0, x1, y1, x2, y2, a0, a1)  {
    a0 = to [id, A0]
    x0 = to [id, X0]
    y0 = to [id, Y0]

    c  = cos(a0 * Pi / 180)
    s  = sin(a0 * Pi / 180)

    to [id, X1] = x1 = x0 + Tlen * c
    to [id, Y1] = y1 = y0 + Tlen * s
    to [id, A1] = a1 = a0 - Fang

    c1 = cos(a1 * Pi / 180)
    s1 = sin(a1 * Pi / 180)
    xa = x0 + Trad * s
    ya = y0 - Trad * c
  # mark(xa, ya, 1, 1, "cyan")
    arc(xa, ya, 360-a0, 360-a1, Trad, "cyan")

    line(x0, y0, x1, y1, "red");

    to [id, X2] = xa + Trad * sin((360-a1) * Pi / 180)
    to [id, Y2] = ya + Trad * cos((360-a1) * Pi / 180)

    if (0) {
        dispPt(to [id, X1], to [id, Y1], 1)
        dispPt(to [id, X2], to [id, Y2], 2)
    }
}

# ------------------------------------------------
BEGIN  {
    Pi = atan2(0, -1)

    A0 = 0; A1 = 1; X0 = 2; Y0 = 3; X1 = 4; Y1 = 5; X2 = 6; Y2 = 7

    line(0, 10, 50, -20, "black")
    arc(20, -10, 0, 360, 10, "white")

    ToLen = 7.8
    ToFn  = 6
    ToAng = 9.5
    ToRad = 12*339/87
    Rad   = 28

    printf "thickness = 1.5\n"
    col = "dark-gray"

    ladder(0, 10, 30)
    ladder(0, 20, 40)
    ladder(0, 35, 45)
    ladder(0, 50, 50)
}

# ------------------------------------------------
function ladder (x0, y0, a0)  {
    # ----------------------------
    # turnout placement
    to [0, A0] = a0
    to [0, X0] = x0
    to [0, Y0] = y0
    drawTurnout(0, ToLen, ToAng, ToRad)

    # ----------------------------
    # 2nd turnout
    to [1, A0] = to [0, A1]
    to [1, X0] = to [0, X2]
    to [1, Y0] = to [0, Y2]
    drawTurnout(1, ToLen, ToAng, ToRad)

    # ----------------------------
    # non-diverging curve to horizontal
    x1 = to [1, X1]
    y1 = to [1, Y1]

    xc = x1 + Rad * sin(to [1, A0] * Pi / 180)
    yc = y1 - Rad * cos(to [1, A0] * Pi / 180)
    arc(xc, yc, 360-to [1, A0], 360, Rad, "yellow")
    anno(xc, yc+Rad, sprintf("%.1f", Rad))

    # ---------------------------- 
    # horizontal intersect & trackage
    x3 = xc
    y3 = yc + Rad
    x4 = x3 + 20
    line(x3, y3, x4, y3, "dark-gray")

    # ---------------------------- 
    # diverging curve
    x2 = to [1, X2]
    y2 = to [1, Y2]
    a1 = to [1, A1]

    xc = x2 + Rad * sin(a1 * Pi / 180)
    yc = y2 - Rad * cos(a1 * Pi / 180)
    arc(xc, yc, 360-a1, 360, Rad, "yellow")
    anno(xc, yc+Rad, sprintf("%.1f", Rad))

    # ---------------------------- 
    # diverging horizontal intersect & trackage
    x5 = xc
    y5 = yc + Rad
    x6 = x4
    line(x5, y5, x6, y5, "dark-gray")
    anno(x6, y5, sprintf("(%.2f, %.2f) P6", x6, y5))

    measure(x4-10, y3, x4-10, y5, "orange")
    measure(x0, y3, x0, y0, "orange")

    # ---------------------------- 
    # 1st turnout horizontal intersect & trackage
    c   = cos(a0 * Pi / 180)
    s   = sin(a0 * Pi / 180)
    rad = (y3 + 2 - to [0, Y1]) / (1 - c)

    xc = to [0, X1] + rad * s
    yc = to [0, Y1] - rad * c
    arc(xc, yc, 360-a0, 360, rad, "yellow")
    anno(xc, yc+rad, sprintf("%.1f", rad))
    line(xc, yc+rad, x4, yc+rad, "dark-gray")
}' $*

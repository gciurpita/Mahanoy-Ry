
awk '
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
function anno (x, y, text, color)  {
    yAnno += dyAnno
    printf "anno %8.4f %8.4f  %s\n", x, y, text
}

# ------------------------------------------------
function ellipse (x0, y0, a0, a1, radX, radY, col, da, a)  {
    printf "next\ncolor = %s\n", col

    if ("" == da)
        da = 2
    for (a = a0; a <= a1; a += da)  {
        w = a * Pi / 180
        printf "  %8.4f %8.4f\n", x0+(radX * sin(w)), y0+(radY * cos(w))
    }
    printf "\n"
}

# ------------------------------------------------
function arc (x0, y0, a0, a1, rad, col, da)  {
    ellipse(x0, y0, a0, a1, rad, rad, col, da)
}

# ------------------------------------------------
function dash (x0, y0, x1, y1, seg, color, x, y)  {
    printf "# dash:\n"
    printf "\ncolor=%s\n", color

    dx  = x1 - x0
    dy  = (y1 - y0) * seg / dx
    dx *= seg / dx
    y   = y0

    for (x = x0; x < x1; x += 2*dx)  {
        printf "next\n"
        printf " %8.4f  %8.4f\n", x, y
        if (x + dx < x1)
            printf " %8.4f  %8.4f\n", x+dx, y+dy
        else
            printf " %8.4f  %8.4f\n", x1, y1
        y += 2*dy
    }
}

# ------------------------------------------------
function line (x0, y0, x1, y1, color)  {
    printf "\nnext\ncolor=%s\n", color
    printf " %8.4f  %8.4f\n", x0, y0
    printf " %8.4f  %8.4f\n", x1, y1
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
function measure (x0, y0, x1, y1, color, x, y, len)  {
    color = "white"
    printf "color = %s\n", color

    x = (x0 + x1) / 2
    y = (y0 + y1) / 2
    printf "arrow  %8.4f %8.4f  %8.4f %8.4f\n", x0, y0, x, y
    printf "arrow  %8.4f %8.4f  %8.4f %8.4f\n", x1, y1, x, y

    len = sqrt( (x1-x0)^2 + (y1-y0)^2)
    printf "anno   %8.4f %8.4f  %.1f\n", x, y, len
}

# ------------------------------------------------
function rotate (xy, ang, z)  {
    c = cos(ang * Pi / 180)
    s = sin(ang * Pi / 180)

    z       = xy [0] *c - xy [1] *s
    xy [1]  = xy [0] *s + xy [1] *c
    xy [0]  = z
}

# ------------------------------------------------
function rectAng (x0, y0, wid, ht, ang, color)  {
    xy1 [0] = wid; xy1 [1] = 0
    xy2 [0] = wid; xy2 [1] = ht
    xy3 [0] = 0;   xy3 [1] = ht
    rotate(xy1, ang)
    rotate(xy2, ang)
    rotate(xy3, ang)

    printf "\nnext\ncolor=%s\n", color
    printf " %8.4f  %8.4f\n", x0, y0
    printf " %8.4f  %8.4f\n", x0 + xy1 [0], y0 + xy1 [1]
    printf " %8.4f  %8.4f\n", x0 + xy2 [0], y0 + xy2 [1]
    printf " %8.4f  %8.4f\n", x0 + xy3 [0], y0 + xy3 [1]
    printf " %8.4f  %8.4f\n", x0, y0
}

# --------------------------------------------------------------------
# --------------------------------------------------------------------
BEGIN  {
    Pi = atan2(0, -1)

    Rad  = 28
    Long = 24
    Foam = 32
    Len  = 12 * 24

    opp = Long/2
    adj = sqrt(Rad^2 - opp^2)
    angLong = atan2(opp, adj) * 180 / Pi

    circFt = 2 * Rad * Pi / 12
    ang2ft = 360 * 2 / circFt

    # --------------------------------------
    # benchwork & foam
    if (1)  {
        printf "set_color 140 = (60, 60, 60)\n"
        printf "thickness = 155\n"
        line( -adj+3,  0, 2*Rad,  0, 140)
    }

    printf "thickness = 1\n"
    line(-adj,  0, 2*Rad,  0, "white")

    printf "thickness = 3\n"
    line(-adj,  opp, 2*Rad,  opp, "dark-gray")
    line(-adj, -opp, 2*Rad, -opp, "dark-gray")

    # ----------------------------------------------------------
    # track
    printf "thickness = 2\n"
    ang = 50
    a0  = 90 + ang
    a1  = 360 + 90 - ang
    arc(0, 0, a0, a1, Rad, "orange")

    x   = Rad * cos(ang * Pi / 180)
    y   = Rad * sin(ang * Pi / 180)
  # anno(x, y, sprintf("%d deg", ang))

    # upper straight extension
    a2 = 180
    a3 = 180 + 90 - ang
    k  = 0.15

    dx = (k*y)
    dy = -(k*x)
    line(x, y, x+dx, y+dy, "green")
  # strLen = sqrt(dx^2 + dy^2)

    # upper reverse curve
    x2 = 2*x + dx
    y2 = 2*y + dy
    arc(x2, y2, a2, a3, Rad, "orange")

    # --------------------------------------
    # lower reverse track 
    a4 = 360 - (90 - ang)
    a5 = 360
    arc(x2, -y2, a4, a5, Rad, "orange")

    # straight extension
    k  = 0.80
    dx =  k*y
    dy = -k*x
    xA =  x + dx
    yA = -y -dy
    line(x, -y, xA, yA, "green")

    # --------------------------------------
    # curved turnout
    R1   = 30
    R2   = 24
    angT = 30
    rad  = 30 * Pi / 180

    cA  = cos(a4 * Pi/180)
    sA  = sin(a4 * Pi/180)

    angA = 360 - ang
    cA  = cos(angA * Pi/180)
    sA  = sin(angA * Pi/180)

    # inside 24 in. curve
    x2  = xA + R2 * cA
    y2  = yA + R2 * sA
    arc(x2, y2, a4, a4 + angT, R2, "yellow")
    arc(x2, y2, a4 + angT, 360, R2, "orange")

    # outside 30 in. curve
    x1  = xA + R1 * cA
    y1  = yA + R1 * sA
    arc(x1, y1, a4, a4 + angT, R1, "pink")
    mark(x1, y1, 1, 1, "pink")

    angB = a4 + angT
    sB  = sin(angB * Pi/180)
    cB  = cos(angB * Pi/180)
    mB  = -sB /cB

    printf "title_x  %s\n", \
        sprintf("angB %.1f, sB %.3f, cB %.3f, mB, %.2f", angB, sB, cB, mB)

    x3  = x1 + R1 * sB
    y3  = y1 + R1 * cB
  # mark(x3, y3, 1, 1, "blue")

    d4  = 6.5
    x4  = x3 + d4
    y4  = y3 + d4 * mB
  # mark(x4, y4, 1, 1, "green")
    line(x3, y3, x4, y4, "green")

    # ----------------------------------------------------------
    printf "title    %s\n", "Staging Detail"
}'


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
    printf "color=%s\nnext\n", color
    printf " %8.4f  %8.4f\n", x0, y0
    printf " %8.4f  %8.4f\n", x1, y1
}

# ------------------------------------------------
function mark (x, y, dx, dy, color)  {
    printf "color=%s\n", color
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
function extLen (cw, pt, ang, len, col, x, y)  {
    printf "\n# extLen: x %d, y %d, ang %d, len %d\n", \
            pt[X], pt[Y], ang, len

    if (CCW == cw)
        ang -= 90
    else
        ang  = (ang + 90) % 360

    c = cos(ang * Pi / 180)
    s = sin(ang * Pi / 180)
    printf "# extLen: ang %d, c %.3f, s %.3f\n", ang, c, s

    x = pt[X] + len * s
    y = pt[Y] + len * c
    line(pt[X], pt[Y], x, y, col)
    pt[X] = x
    pt[Y] = y
}

# ------------------------------------------------
function extCw (pt, ang0, ang1, rad, col, x, y)  {
    printf "\n# extCw: x %d, y %d, rad %d\n", pt[X], pt[Y], rad
    x = pt[X] - rad * sin(ang0 * Pi / 180)
    y = pt[Y] - rad * cos(ang0 * Pi / 180)
  # mark(x, y, 1, 1, col)

    arc(x, y, ang0, ang1, rad, col)

    pt[X] = x + rad * sin(ang * Pi / 180)
    pt[Y] = y + rad * cos(ang * Pi / 180)
}

# ------------------------------------------------
function ptSave (pt, idx) {
    pts[X, idx] = pt[X]
    pts[Y, idx] = pt[Y];

    if (1) {
        mark(pts[X, idx], pts[Y, idx], 1, 1, "white")
        anno(pts[X, idx], pts[Y, idx], idx)
    }
}

# ------------------------------------------------
function ptLoad (idx, pt) {
    pt[X] = pts[X, idx]
    pt[Y] = pts[Y, idx]
}

# ------------------------------------------------
function angRev (ang) {
    return (180 + ang) % 360
}

# ------------------------------------------------
BEGIN  {
    Pi = atan2(0, -1)
    CW  = X  = 0
    CCW = Y  = 1

    rad = 28
    ang = 90 + 50

    col = "red"
    arc(0, 0, ang, 180, rad, col)

    pt [X] = rad * sin(ang * Pi / 180)
    pt [Y] = rad * cos(ang * Pi / 180)

    extLen(CCW, pt, ang, 10, "green")
    ptSave(pt, 1)

    ang = angRev(ang) + 30

    # inside curved turnout
    extCw(pt, ang-30, ang, 24, "pink")
    ptSave(pt, 2)

    # outside curved turnout
    ptLoad(1, pt)
    extCw(pt, ang-30, ang, 30, "yellow")
    ptSave(pt, 3)

    # turnout non-diverging
    extLen(CW, pt, ang, 10, "green")
  # extCw(pt, ang, 360, 30, "cyan")

    # turnout diverging
    ptLoad(3, pt)
    ang += 10
    extCw(pt, ang-10, ang, 47, "orange")

    # --------------------------------------
    printf "\n"
    printf "title_x ang %d\n", ang
}'

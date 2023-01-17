
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

    w = a1 * Pi / 180
    printf "  %8.4f %8.4f\n", x0+(radX * sin(w)), y0+(radY * cos(w))

    printf "\n"
}

# ------------------------------------------------
function arc (x0, y0, a0, a1, rad, col, da)  {
    ellipse(x0, y0, a0, a1, rad, rad, col, da)
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

# --------------------------------------------------------------------
# --------------------------------------------------------------------
function extLen (cw, pt, ignore, len, col, x, y)  {
    printf "\n# extLen: x %d, y %d, ang %d, len %d\n", \
            pt[X], pt[Y], ang, len

    ang = pt[A]
    if (CCW == cw)
        ang -= 90
    else
        ang += 90

    c = cos(ang * Pi / 180)
    s = sin(ang * Pi / 180)

    dx = len * s
    dy = len * c

    x = pt[X] + dx
    y = pt[Y] + dy

    printf "# extLen: ang %d, c %.3f, s %.3f", ang, c, s
    printf " dx %.3f, dy %.3f", dx, dy
    printf " x %.3f, y %.3f", x, y
    printf "\n"

    line(pt[X], pt[Y], x, y, col)
    pt[X] = x
    pt[Y] = y
}

# ------------------------------------------------
function extChk () {
    printf "\nextChk:\n"
    ptPr(pt)

    printf "thickness =1\n"

    Rad = 10
    arc(0, 0, 10, 350, Rad, "red")
    for (ang = 30; ang <= 360; ang += 30)  {
        pt[X] = Rad * sin(ang * Pi / 180)
        pt[Y] = Rad * cos(ang * Pi / 180)
        extLen(CW,  pt, ang, 8, "pink")

        pt[X] = Rad * sin(ang * Pi / 180)
        pt[Y] = Rad * cos(ang * Pi / 180)
        extLen(CCW, pt, ang, 8, "yellow")
    }
}

# ------------------------------------------------
function extCcw (pt, ang0, ang1, rad, col, x, y)  {
    printf "\n# extCcw: x %d, y %d, rad %d\n", pt[X], pt[Y], rad

    # locate center from pt
    x = pt[X] - rad * sin(ang0 * Pi / 180)
    y = pt[Y] - rad * cos(ang0 * Pi / 180)
  # mark(x, y, 1, 1, col)

    arc(x, y, ang1, ang0, rad, col)

    pt[X] = x + rad * sin(ang1 * Pi / 180)
    pt[Y] = y + rad * cos(ang1 * Pi / 180)
}

# ------------------------------------------------
function extCw (pt, ang0, ang1, rad, col, x, y)  {
    printf "\n# extCw: x %d, y %d, ang %.1f - %.1f, rad %d\n",
        pt[X], pt[Y], ang0, ang1, rad

    x = pt[X] - rad * sin(ang0 * Pi / 180)
    y = pt[Y] - rad * cos(ang0 * Pi / 180)
  # mark(x, y, 1, 1, col)

    arc(x, y, ang0, ang1, rad, col, 0.25)

    pt[X] = x + rad * sin(ang1 * Pi / 180)
    pt[Y] = y + rad * cos(ang1 * Pi / 180)
}

# ------------------------------------------------
function ptSave (idx, pt, ang) {
    pts[X, idx] = pt[X]
    pts[Y, idx] = pt[Y];
    pts[A, idx] = pt[A]
    if (ang)
        pts[A, idx] = ang

    pts[X2, idx] = pt[X2]
    pts[Y2, idx] = pt[Y2];
    pts[A2, idx] = pt[A2]

    if (1) {
      # mark(pts[X, idx], pts[Y, idx], 1, 1, "white")
        anno(pts[X, idx], pts[Y, idx], idx)
    }
}

# ------------------------------------------------
function ptLoad (pt, idx) {
    pt[X]  = pts[X, idx]
    pt[Y]  = pts[Y, idx]
    pt[A]  = pts[A, idx]

    pt[X2] = pts[X2, idx]
    pt[Y2] = pts[Y2, idx]
    pt[A2] = pts[A2, idx]
}

# ------------------------------------------------
function pt2Load (pt, idx) {
    pt[X]  = pts[X2, idx]
    pt[Y]  = pts[Y2, idx]
    pt[A]  = pts[A2, idx]
    pt[X2] = pt[Y2] = pt[A2] = ""
}

# ------------------------------------------------
function ptMark (pt, col) {
    mark(pt[X],  pt[Y],  0.2, 0.2, col)
    if ("" != pt[X2])
        mark(pt[X2], pt[Y2], 0.2, 0.2, col)
}

# ------------------------------------------------
function ptPr (pt) {
    anno(pt[X], pt[Y], sprintf("(%.1f, %.1f) %.1f", pt[X], pt[Y], pt[A]))
}

# ------------------------------------------------
function angRev (ang) {
    return (180 + ang) % 360
}

# ------------------------------------------------
function turnout (pt, cw, len, fAng, rh, col) {
    printf "# turnout:"
    printf " x %.3f, y %.3f, ang %.1f", pt[X], pt[Y], pt[A]
    printf " cw %d, len %.1f, fAng %.2f, rh %d", cw, len, fAng, rh
    printf "\n"

    ang = pt[A]
    if (CCW == cw)
        ang -= 90
    else
        ang += 90

    x1 = pt[X] + len * sin(ang * Pi / 180)
    y1 = pt[Y] + len * cos(ang * Pi / 180)
    line(pt[X], pt[Y], x1, y1, col)

    if (RH == rh)  {
        ang    = ang   + fAng
        pt[A2] = pt[A] + fAng
    }
    else  {
        ang    = ang   - fAng
        pt[A2] = pt[A] - fAng
    }

    x2 = pt[X] + len * sin(ang * Pi / 180)
    y2 = pt[Y] + len * cos(ang * Pi / 180)
    line(pt[X], pt[Y], x2, y2, col)

    pt[X2] = x2
    pt[Y2] = y2

    pt[X] = x1
    pt[Y] = y1
    printf "title_x  %.3f\n", pt[A]
}

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
BEGIN  {
    Pi = atan2(0, -1)
    X  = CCW = RH = 0
    Y  = CW  = LH = 1
    A  = 2
    X2 = 3
    Y2 = 4
    A2 = 5

    # ----------------------------
    G    = 0.66
    Gd2  = G / 2
    FN   = 6
    fW   = 2 * atan2(0.5, FN)
    fAng = fW * 180 / Pi
    rad  = G / (1 - cos(fW))
    lead = sin(fW) * rad
    printf "title_x %s\n", 
        sprintf(" F# %.1f, ang %.2f, lead %.2f rad, %.1f", \
            FN, fAng, lead, rad)

    line(0, -3, 0, 3, "black")

    track(lead, fW, rad, "dark-gray")
    easement(fAng, lead)

    # ----------------------------
    printf "title  Turnout\n"
}

# ------------------------------------------------
function easement (fAng, lead)  {
    printf "thickness = 2\n"
    pt[X] = 0
    pt[Y] = Gd2


    rad1 = 100
    a1   = fAng / 4

    ptPr(pt)
    extCw(pt, 0,      a1,      rad1, "red", x, y) 
    ptPr(pt)

    c1   = cos(a1 * Pi / 180)
    s1   = sin(a1 * Pi / 180)
    c2   = cos(fAng * Pi / 180)
    s2   = sin(fAng * Pi / 180)

    dx   = lead - rad1 * s1 
    dy   = G - rad1 * (1 - c1)
    rad2 = dy / (c1 -  c2)

    extCw(pt, a1, fAng,  rad2, "green", x, y) 
    ptPr(pt)
}

# ------------------------------------------------
function track (lead, fW, rad, col)  {
    line(0,  Gd2, 1+lead,  Gd2, col)
    line(0, -Gd2, 1+lead, -Gd2, col)

    c = cos(fW)
    s = sin(fW)
    line(lead, -Gd2, lead+c, -Gd2-s, col)

  # arc(0, -rad + Gd2, 0, fW * 180/Pi, rad, col, 0.2)
  # printf "title_x %s\n", sprintf(" c %.3f, s %.3f", c, s)
}'

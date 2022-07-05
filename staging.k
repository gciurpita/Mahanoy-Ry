
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

    if (a0 > a1)  {
        tmp = a0;  a0 = a1; a1 = tmp
    }

    if ("" == da)
        da = 2
    for (a = a0; a <= a1; a += da)  {
        w = a * Pi / 180
        printf "  %8.4f %8.4f\n", x0+(radX * sin(w)), y0+(radY * cos(w))

 #      if (! (a % 30))  {
 #          dD = -2
 #          if ((a % 360) <= 180)
 #              dD = 2
 #          x9 = x0+((dD+radX) * sin(w))
 #          y9 = y0+((dD+radY) * cos(w))
 #          printf "anno  %8.4f %8.4f %.2f, %5.1f\n", x9, y9, x9, y9
 #      }
    }
    printf "\n"
}

# ------------------------------------------------
function arcLen (x0, y0, a, rad, len)  {
    w  = a * Pi / 180
    dD = -2
    if ((a % 360) <= 180)
        dD = 2
    x9 = x0+((dD+rad) * sin(w))
    y9 = y0+((dD+rad) * cos(w))
    printf "anno  %8.4f %8.4f %.1f'\''\n", x9, y9, len
}

# ------------------------------------------------
function arc (x0, y0, a0, a1, rad, col, da)  {
    ellipse(x0, y0, a0, a1, rad, rad, col, da)

    len = 0
    da  = 12 * 180 / (Pi * rad)
    printf "title_x  %.2f\n", da

    if (1)  {
        if (a0 < a1)
            for (a = a0; a <= a1; a += da)
                arcLen(x0, y0, a, rad, len++)
        else
            for (a = a0; a >= a1; a -= da)
                arcLen(x0, y0, a, rad, len++)

        len += -1 + (da - (a - a1)) / da
        arcLen(x0, y0, a1, rad, len)
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

    dx  = (pt[X] + x) / 2
    dy  = (pt[Y] + y) / 2
    dy -= sgn(dy) * 5
    dd  = sqrt( ((pt[X] - x) / 2)^2 + ((pt[Y] - y) / 2)^2)
    printf "anno %.3f %.3f  %.2f\n", dx, dy, dd

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
    printf "\n# extCw: x %d, y %d, rad %d\n", pt[X], pt[Y], rad
    x = pt[X] - rad * sin(ang0 * Pi / 180)
    y = pt[Y] - rad * cos(ang0 * Pi / 180)
  # mark(x, y, 1, 1, col)

    arc(x, y, ang0, ang1, rad, col)

    pt[X] = x + rad * sin(ang1 * Pi / 180)
    pt[Y] = y + rad * cos(ang1 * Pi / 180)
}

# ------------------------------------------------
function ptSave (idx, pt, ang, pr) {
    pts[X, idx] = pt[X]
    pts[Y, idx] = pt[Y];
    pts[A, idx] = pt[A]
    if (ang)
        pts[A, idx] = ang

    pts[X2, idx] = pt[X2]
    pts[Y2, idx] = pt[Y2];
    pts[A2, idx] = pt[A2]

    if (pr) {
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
    anno(pt[X], pt[Y], sprintf("   %.1f, %.1f  %.1f", pt[X], pt[Y], pt[A]))
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
}

# ------------------------------------------------
BEGIN  {
    Pi = atan2(0, -1)
    X  = CCW = RH = 0
    Y  = CW  = LH = 1
    A  = 2
    X2 = 3
    Y2 = 4
    A2 = 5

    # ----------------------------
    Rad    = 28
    Foam   = 32
    Frame  = 24
    Offset = int(1+sqrt(Rad^2 - (Frame/2)^2))

    if (1)  grid(Offset-30, Offset+60, -30, 30)

    if (1)  bench(12*7, Foam, Frame)
    if (1)  loop(Rad, Offset)

    if (0)  ladder1(40, 0, 50)
    if (0)  ladder2(0, 0, 50)
}

# ----------------------------------------------------------
function bench (len, wid, wid2)  {
    printf "# bench:\n"

    col = "green"
    line(0,  wid/2, len,  wid/2, col)
    line(0, -wid/2, len, -wid/2, col)

    printf "thickness = 3\n"
    col = 140
    line(0,  wid2/2, len,  wid2/2, col)
    line(0, -wid2/2, len, -wid2/2, col)
}

# ----------------------------------------------------------
function grid (x0, x1, y0, y1, dx, dy, x, y)  {
    if ("" == dx)
        dx = dy = 1

    dV = 0x20
    v  = 0x30
    c0 = 138
    printf "set_color %d = (%d, %d, %d)\n", c0, v, v, v

    v += dV
    c1 = 139
    printf "set_color %d = (%d, %d, %d)\n", c1, v, v, v

    v += dV
    c2 = 140
    printf "set_color %d = (%d, %d, %d)\n", c2, v, v, v

    for (x = x0; x <= x1; x += dx)  {
        col = c0
        if (! (x % 12))
            col = c2
        else if (! (x % 3))
            col = c1
        line(x, y0, x, y1, col)
    }

    for (y = y0; y <= y1; y += dy)  {
        col = c0
        if (! (y % 12))
            col = c2
        else if (! (y % 3))
            col = c1
        line(x0, y, x1, y, col)
    }
}

# ------------------------------------------------
function loop (Rad, x0) {
    ang = 50

    a0  = 90 + ang
    a1  = 360 + 90 - ang

    if (0) {
        x1   = x0 + Rad * sin(a0 * Pi / 180)
        y1   =      Rad * cos(a0 * Pi / 180)
        printf "thickness = 1\n"
        line(x0, 0, x1, y1, "red")

        x1   = x0 + Rad * sin(a1 * Pi / 180)
        y1   =      Rad * cos(a1 * Pi / 180)
        line(x0, 0, x1, y1, "red")
    }

    printf "thickness = 2\n"
    col = "orange"
    arc(x0, 0, a1, a0, Rad, col)
    mark(x0, 0, 1, 1, col)

    # manually set endpoints of arc
    pt[A] = a1
    pt[X] = x   = x0 + Rad * cos(ang * Pi / 180)
    pt[Y] = y   = Rad * sin(ang * Pi / 180)
    ptSave(1, pt)
  # ptPr(pt)

    pt[A] = a0
    pt[X] = x   =  x0 + Rad * cos(ang * Pi / 180)
    pt[Y] = y   = -Rad * sin(ang * Pi / 180)
    ptSave(2, pt)
  # ptPr(pt)

    # --------------------------------------
    # upper reverse curve 
    ptLoad(pt, 1)
    extLen(CW, pt, pt[A], 4, "green")

    extCcw(pt, angRev(pt[A]), 180, Rad, "orange")
    # --------------------------------------
    # lower reverse curve 
    ptLoad(pt, 2)
    extLen(CCW, pt, pt[A], 4, "green")

    ptSave(3, pt)

    extCw(pt, angRev(pt[A]), 360, Rad, "orange")

    # --------------------------------------
    # staging extension
    ptLoad(pt, 3)
    extLen(CCW, pt, pt[A], 10, "pink")

    ptSave(4, pt)
 #  ptPr(pt)

}

# ------------------------------------------------
function ladder2 (x, y, ang)  {
    printf "# ladder2: \n"

    Len  = 8
    Fang = 9.5

    if (x)  {
        pt[X] = x
        pt[Y] = y
        pt[A] = ang
    }

    turnout(pt, CCW, Len, Fang, RH, "red")
    ptSave(5, pt, pt[A])

    # non-diverging 1st turnout
    extCw(pt, angRev(pt[A]), 360, 38, "yellow")
    ptPr(pt)
 
    pt2Load(pt, 5)
    turnout(pt, CCW, Len, Fang, RH, "cyan")
    ptSave(5, pt, pt[A])

 #return # ***

    extCw(pt, angRev(pt[A]), 360, 28, "orange")
    ptPr(pt)

    pt2Load(pt, 5)
    extCw(pt, angRev(pt[A]), 360, 46, "green")
    ptPr(pt)

    # --------------------------------------
    printf "\n"
    printf "title Ladder 2\n"
}

# ------------------------------------------------
function ladder1 (x, y, ang)  {
    line(0, -2, 40, 2, "black")
    printf "thickness = 2.0\n"

    Len  = 8
    Fang = 9.5

    pt[X] = x
    pt[Y] = y
    pt[A] = ang

    turnout(pt, Len, Fang, RH, "red")
    ptMark(pt, "red")

    ptSave(2, pt, pt[A])
    turnout(pt, Len, Fang, RH, "cyan")
    ptSave(3, pt, pt[A])

    pt2Load(pt, 2)
    extCw(pt, 270+pt[A], 360, 58, "yellow")
    ptPr(pt)

    pt2Load(pt, 3)
    extCw(pt, 270+pt[A], 360, 40, "yellow")
    ptPr(pt)

    ptLoad(pt, 3)
    extCw(pt, 270+pt[A], 360, 28, "green")
    ptPr(pt)

    # --------------------------------------
    printf "\n"
    printf "title Ladder\n"
}'

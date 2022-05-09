
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
function bench (e, col)  {
    x1  = Wid - D * 1.5

    y1  = Ht - D
    y2  = y1 - A
    y3  = y2 - D*2

    # --------------------------------------
    # end wall
    ye  = Door + 10
    line(0,   ye, e, ye,  col)
    line(e,   ye, e, y1-12,  col)

    measure(e+4, ye, e+4, y1, col)

    # --------------------------------------
    # upper shelf
    x2  = Wid - 12*6
    x2  = 3* 12*8
    xW  = Wid - 8
    line(e+12, y1, x2,  y1,  col)

  # x3  = Wid - 12*5
  # y5  = Ht  - 12*1
  # line(x2,  y1, x3, y5,  col)

    anno(150, y1-5, "Upper Shelf")

    for (x = 0; x+96 < Wid; x += 96)
        measure(x, Ht+2, x+12*8, Ht+2, col)

    # --------------------------------------
    # pennisula
    x2  = e + A + 60
    x3  = x2 + 2* 12*8
    line(x2,  y2, x3,  y2,  col)
    line(x2,  y3, x3,  y3,  col)

    joist(x2, y2, x3, y3, 16, 0, 21)
    joist(x2, y2, x3, y3, 16, 0, 21)

    rad = 32
    yC  = (y2 + y3)/2
    joist(x2, yC-rad, x2-2*rad, yC+rad, 16, 0, 21)

    xC  = x2 - (rad + 2)
    arc(xC, yC, 180-45/2, 400, rad, col, 45)
  
    anno(150, y3-5, "Peninsula")

    for (x = x2; x+96 < Wid; x += 96)
        measure(x, 92, x+12*8, 92, col)

    # --------------------------------------
    # lower shelf
    line(Wid-12,  20, Wid-12, 48,  col)

    x3  = 210
    y5  = 0
    y4  = y5 + D
  # line(x1,  y3, x1,  y4,  col)
    line(x3,  y4, Wid-48,  y4,  col)
    line(x3,  y4, x3,  y5,  col)

    anno(250, y4+2, "Lower Shelf")

    measure(x3, 26, x3+12*8, 26, col)
}

# ------------------------------------------------
function frogDim (fN) {
    fAng  = 2 * atan2(0.5, fN)
    fRad  = G / (1 - cos(fAng))
    fLead = fRad * sin(fAng)

    printf "#"
    printf " G %.4f", G
    printf " fN %.1f", fN
    printf " fAng %.2f", fAng * 180 / Pi
    printf " fRad %.2f", fRad
    printf " fLead %.2f", fLead
    printf "\n"
}

# ------------------------------------------------
function grid (d, col) {
    for (x = 0; x < Wid; x += d)
        line(x, 0, x, Ht, col)
    for (y = 0; y < Ht; y += d)
        line(0, y, Wid, y, col)
}

# ------------------------------------------------
function join (x0, y0, x1, y1, col) {
    line(x0, y0, x1, y1, col)
    return

    if (0)  {
        if (x1 < x0) {
            t  = x0; x0 = x1; x1 = t
        }

        if (y1 < y0) {
            t  = y0; y0 = y1; y1 = t
        }
    }

  # dx = abs(x1 - x0)
  # dy = abs(y1 - y0)

    dx = (x1 - x0)
    dy = (y1 - y0)

    w  = atan2(dy, dx)
    r  = (dy/4) / (1 - cos(w))

    anno(x0+dx/2, y0+dy/2 + 8, sprintf("%.1f, %.1f) %.1f rad, %.1f ang, %.4f, %.2f dy", \
        dx, dy, r, w * 180/Pi, 1- cos(w), dy))

    line(x0, y0, x0 + dx*cos(w), y0 - dx*sin(w), col)
}

# ------------------------------------------------
function joist (x0, y0, x1, y1, xSp, ySp, col) {
    if (xSp)  {
        if (x1 < x0)  {
            t  = x0
            x0 = x1
            x1 = t
        }
        for (x = x0; x <= x1; x += xSp)
            line(x, y0, x, y1, col)
    }

    if (ySp)
        for (y = y0; y <= y1; y += ySp)
            line(x0, y, x1, y, col)
}

# ------------------------------------------------
function room (col)  {
    # room
    Door = 30
    line(0,   0,  Wid, 0,   col)
    line(Wid, 0,  Wid, Ht,  col)
    line(Wid, Ht, 0,   Ht,  col)
    line(0,   Door, 0,   Ht,  col)

    radDoor = 30
    k       = 0.707     # sin 45 deg
    arc(0, 0, 0, 45, radDoor, col)
    line(0, 0, k*radDoor, k*radDoor, col)

    # --------------------------------------
    # obstructions
    rectAng(Wid-45, Ht-31, 28, 21, -20, "green")   # stove
    anno(Wid-35, 115, "wood stove")

  # rectAng(Wid-43, 4, 19, 18, 0, "green")          # water pump
    arc(Wid-31, 12, 0, 360, 9, "green")          # water pump
    anno(Wid-33, 13, "water")
    anno(Wid-33,  9, "pump")

    rectAng(12*16,  0, 15, 11, 0, "green")          # sewer pipe
    anno(12*16.4,  5, "sewer")

    # --------------------------------------
    # work bench and shelves
    radX = 8
    radY = 5
    x    = Wid - 11 - radX
    y    = Ht  - 10 - radY
    ellipse(x, y, 0, 360, radX, radY, "green")

    col = 72

    rectAng( 36,  1, 48, 12, 0, col)       # shelf
    anno(    50,  6, "shelf (48\")")
    rectAng( 86,  1, 48, 12, 0, col)       # bench
    anno(   100,  6, "work bench")
    rectAng(136,  1, 48, 12, 0, col)       # shelf
    anno(   150,  6, "shelf (48\")")
}

# ------------------------------------------------
function track () {
    rad = Rad
    clr = 3
    xN  = Wid - clr
    x1  = xN - rad

    yN  = Ht - clr
    y2  = yN - rad
    y0  = clr
    y1  = y0 + rad

    printf "title_x"
    printf "  Wid = %.1f", Wid/12
    printf ", Ht = %.1f", Ht/12
    printf ", Rad = %d", Rad
    printf "\n"

    # --------------------------------------
    # upper shelf
    col = "yellow"
  # yN = Ht - Rad - clr
    arc(Rad+10, yN-Rad-4, 270, 360, Rad, col)

    yard(8,  yN-Rad+2,  6, -74, Fn, Sp, col)    # right half

    turntable(8, Ht-8, 90, col)
    arc(x1, y2, -20, 90, Rad, col)

  # yard(120, 130, -70,  2, Fn, Sp, col)        # station

    yard(200, 130,  70,  2, Fn, Sp, col)        # station
  # yard(170, 130,  70,  2, Fn, Sp, col)        # industries
  # anno(190, 122, "industries")

    # ------------------------------------------------
    # pennisula
    col = "orange"
    x30 = x1
    y30 = yN - Rad - 4;
    arc(x30, y30, 90, 180, Rad, col)

    # ---------------------------------
    # peninsula staging
    colStg = "dark-gray"
    anno(Wid-44, Ht/2 -2, "Staging (?)")
    arc(x1, yN - Rad - 14, 90, 180, Rad, col)
    yard(310, Ht-D-A-D+2, -13*12, -4, Fn, Sp, colStg)

    y10  = Ht/2
    y11  = y10 + 4
    y12  = y10 - 4
    dash(130, y11, Wid-20, y11, 4, "white")
    dash( 90,  50, 130, y11, 4, "white")
    dash(140, y12, Wid-12, y12, 4, "white")
    anno(140, y12-4, "view block")


    # ---------------------------------
    x20 = 150
    y20 =  84
    l20 =  74
    yard(x20, y20, l20, -2, Fn, Sp, col)     # upper

    x40 = x20 + l20
    y40 = y30 - Rad

    join(x30, y40, x40, y20, col)

    # ---------------------------------
    x0  = 90
    rad = 28
    yC  = Ht/2
    a1  = 45
    a2  = a1
    turnAround(x0, yC, a1, a2, rad, col)

  # arc(x0, yC, 180-45/2, 400, rad+4, "light-gray", 45)

    # staging reversing section
    if (0)  {
        c = cos(a2 * Pi / 180)
        s = sin(a2 * Pi / 180)
        l = 40
        x3 = x0+rad*s
        y3 = yC-rad*c
        line(x3, y3, x3 + c*l, y3 + s*l, col)
    }
    else  {
        a3  = 50
        k   = 0.707
        rad = Rad
        x10 = x0 + Rad + 28
        y10 = yC - Rad
        arc(x10, y10, 270+a3, 360, rad, col)
    }

    arc(x1, 36, 0, 90, Rad, col)
    if (0)
        yard(140, 80, -70, -8, Fn, Sp, col)
    else {
        x10 = 124
        y10 =  79
        rad = 180; arc(x10, y10+rad, 180, 195, rad, col)
        rad =  60; arc(x10, y10-rad, 310, 360, rad, col)
        rad =  40; arc(x10, y10-rad, 290, 360, rad, col)
    }

    # ---------------------------------
    yard(180, 58,  70,  2, Fn, Sp, col)     # lower peninsula

    # ------------------------------------------------
    # lower deck staging
    col = "red"
    col = 41
    arc(x1+2, y1-2, 90, 180, Rad, col)
    line(x1+2+Rad, y1-2, x1+2+Rad, y1-2+84, col)

    yard(x1+2, y1-2-Rad, -(9*12),  8, Fn, Sp, col)

    line(250, -6, 300, -6, "black")
    anno(250, -4, "possible lower deck staging (red)")

    # ------------------------------------------------
    # lower shelf
    col = "cyan"
    arc(x1, y1, 90, 200, Rad, col)
    turntable(220, 7, 90, col)

    yard(300, 8, -60, 2, Fn, Sp, col)
}

# ------------------------------------------------
# facing right
function turnAround (x0, y0, ang, ang2, rad, col) {
    arc(x0, y0, 180-ang2, 360+ang, rad, col)

    c = rad * cos(ang2 * Pi / 180)
    s = rad * sin(ang2 * Pi / 180)
    arc(x0 + 2*s, y0 - 2*c, 360-ang2, 360, rad, col)

    c = rad * cos(ang * Pi / 180)
    s = rad * sin(ang * Pi / 180)
    arc(x0 + 2*s, y0 + 2*c, 180, 180+ang, rad, col)

    if (0) {
        k =  0.707
        line(x0, y0, x0 +k*rad, y0-k*rad, "dark-gray")
        anno((x0+x0 +k*rad)/2, (y0+y0-k*rad)/2, rad)
    }
    else  {
        anno(x0-rad, y0, rad )
    }
}

# ------------------------------------------------
function turntable (x0, y0, diaFt, col) {
    rad = diaFt * 12 / Sc / 2
    arc(x0, y0, 0, 360, rad, col)
    arc(x0, y0, 0, 360, rad, col)
}

# ------------------------------------------------
function yard (x0, y0, dx, dy, fN, sp, col, xN, yN) {
    frogDim(fN)

    if (abs(dx) > abs(dy))  {     # horizontal
        xN = x0 + dx
        for (d = 0; d <= abs(dy); d += sp)  {
            y = y0 + sgn(dy)*d
            if (sp == d && 2 == abs(dy))
                line(x0, y, xN - sgn(dx) * fLead, y, col)
            else
                line(x0, y, xN, y, col)
            x0 += sgn(dx) * fLead
        }
    }
    else  {                         # vertical
        yN = y0 + dy
        for (d = 0; d <= abs(dx); d += sp)  {
            x   = x0 + sgn(dx)*d
            line(x, y0, x, yN, col)
            y0 += sgn(dy) * fLead
        }
    }
}

# ------------------------------------------------
function wye (x0, y0, rad, col)  {
    dd = rad * 0.707
    arc(x0-dd, y0-dd, -15, 45, rad, col)
    arc(x0+dd, y0+dd, 225, 285, rad, col)
  # arc(x0-2*dd, y0+2*dd, 90+15, 180-15, rad, col)
}

# --------------------------------------------------------------------
BEGIN  {
    Pi  = atan2(0, -1)

    Fn  = 5         # frog number
    G   = 0.65      # track gage
    Sc  = 87        # scale
    Sp  = 2         # spacing
    Rad = 28

    Wid = 12 * 29.25        # 29 ft 2in
    Ht  = 12 * 12

    cn = 17
  # printf "set_color %d = (%d, %d, %d)\n", cn, 30, 30, 30

    # aspect circle
    arc(Wid/2, Ht/2, 0, 360, Ht/2, cn)

    D   = 12 * 1.5
    D   = 48 / 3
    A   = (Ht - (4 * D)) / 2

    printf "title   %s\n", "LaVale Train Room"
    printf "thickness = 2.0\n"

    grid(24, cn)
    room("blue")
    bench(24, 71)       # "light-gray")
    track()

    line(0, 0, 0, -10, "black")
    anno(0, -10, "3/15/22")
}' $*

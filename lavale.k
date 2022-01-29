
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
function ellipse (x0, y0, a0, a1, radX, radY, col, a)  {
    printf "next\ncolor = %s\n", col

    for (a = a0; a <= a1; a += 2)  {
        w = a * Pi / 180
        printf "  %8.4f %8.4f\n", x0+(radX * sin(w)), y0+(radY * cos(w))
    }
    printf "\n"
}

# ------------------------------------------------
function arc (x0, y0, a0, a1, rad, col, a)  {
    ellipse(x0, y0, a0, a1, rad, rad, col)
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
    y3  = y2 - D
    
    # end wall
    ye  = Door + 10
    line(0,   ye, e, ye,  col)
    line(e,   ye, e, y1-12,  col)

    # long wall
    x2  = Wid - 12*6
    xW  = Wid - 8
    yW  = Ht - 8
    line(e+12,   y1, x2,  y1,  col)
    line(x1,  yW, x2,  y1,  col)
    line(x1,  yW, xW,  y1,  col)

    # short wall
    x3  = 210
    y4  = y3 - A
    y5  = y4 - D
  # line(x1,  y3, x1,  y4,  col) 
    line(x3,  y4, x1-12,  y4,  col) 
    line(x3,  y4, x3,  y5,  col)

    # pennisula wall
    x2  = e + A + 60
    line(x2,  y2, x1,  y2,  col)
  # line(x2,  y2, x2,  y3,  col)
    line(x2+12,  y3, x1,  y3,  col)

    y6  = (y2 + y3) / 2
    line(140,  y6, 320,  y6,  col)
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
function room (col)  {
    # room
    Door = 30
    line(0,   0,  Wid, 0,   col)
    line(Wid, 0,  Wid, Ht,  col)
    line(Wid, Ht, 0,   Ht,  col)
    line(0,   Door, 0,   Ht,  col)

    rectAng(Wid-45, Ht-31, 28, 21, -20, "green")   # stove
    rectAng(Wid-43, 4, 19, 18, 0, "green")          # water pump
    rectAng(12*16,  0, 15, 11, 0, "green")          # sewer pipe

    radX = 8
    radY = 5
    x    = Wid - 11 - radX
    y    = Ht  - 10 - radY
    ellipse(x, y, 0, 360, radX, radY, "green")

    rectAng( 36,  0, 48, 12, 0, "light-gray")       # shelf
    rectAng( 86,  0, 48, 12, 0, "light-gray")       # bench
    anno(   100,  4, "work bench")
    rectAng(136,  0, 48, 12, 0, "light-gray")       # shelf

    radDoor = 30
    k       = 0.707     # sin 45 deg
    arc(0, 0, 0, 45, radDoor, col)
    line(0, 0, k*radDoor, k*radDoor, col)
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
    arc(Rad+clr, yN-Rad, 270, 360, Rad, col)
    yard(8,  yN-Rad-4, -4, -64, Fn, Sp, col)    # left half
    yard(10, yN-Rad-4,  4, -64, Fn, Sp, col)    # right half
    anno(2, 35, "Staging(?)")

    turntable(22, 126, col)
    arc(x1, y2,  0, 90, Rad, col)
    yard(120, Ht-clr, -70, -8, Fn, Sp, col)     # yard

    yard(200, 138,  70, -2, Fn, Sp, col)        # station
    yard(170, 130,  70,  2, Fn, Sp, col)        # industries
    anno(190, 122, "industries")

    anno(150, 115, "Upper Shelf")

    # --------------------------------------
    # pennisula
    col = 9
    arc(x1, Ht-40, 90, 180, Rad, col)
    x0  = 90
    y0  = 65
    a1  = 40
    a2  = 57.5
    turnAround(x0, y0, a1, a2, Rad, col)

    c = cos(a2 * Pi / 180)
    s = sin(a2 * Pi / 180)
    l = 30
    x3 = x0+Rad*s
    y3 = y0-Rad*c
    line(x3, y3, x3 + c*l, y3 + s*l, col)

    arc(x1, 36, 0, 90, Rad, col)
    yard(140, 80, -70, -8, Fn, Sp, col)
    anno( 90, 65, "industries")

    yard(150, 80,  70,  2, Fn, Sp, col)
    anno(170, 75, "station")

    yard(200, 68,  70, -2, Fn, Sp, col)
    anno(230, 60, "station")

    anno(270, 86, "Staging (?)")
    yard(320, 80, -70,  4, Fn, Sp, col)
    anno(270, 74, "Tunnel")

    anno(200, 55, "Peninsula")

    # --------------------------------------
    # lower shelf
    col = "orange"
    arc(x1, y1, 90, 180, Rad, col)
    turntable(220, 11, col)
  # wye(Wid-12, 12, 24, col)

    yard(300,  6, -60, 2, Fn, Sp, col)
    anno(260,  1, "station")

    anno(250, -5, "Lower Shelf")
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
}

# ------------------------------------------------
function turntable (x0, y0, col) {
    rad = 130 * 12 / Sc / 2
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
    Rad = 30

    Wid = 12 * 29.25        # 29 ft 2in
    Ht  = 12 * 12

    cn = 22
  # printf "set_color %d = (%d, %d, %d)\n", cn, 30, 30, 30

    # aspect circle
    arc(Wid/2, Ht/2, 0, 360, Ht/2, cn)

    D   = 12 * 2
    A   = (Ht - (3 * D)) / 2

    printf "title   %s\n", "LaVale Train Room"
    printf "thickness = 2.0\n"

    grid(24, cn)
    room("blue")
    bench(24, "light-gray")
    track()

}' $*

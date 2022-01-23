
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
    x3  = Wid / 2
    y4  = y3 - A
    y5  = y4 - D
  # line(x1,  y3, x1,  y4,  col) 
    line(x3,  y4, x1-12,  y4,  col) 
    line(x3,  y4, x3,  y5,  col)

    # pennisula wall
    x2  = e + A 
    line(x2,  y2, x1,  y2,  col)
    line(x2,  y2, x2,  y3,  col)
    line(x2,  y3, x1,  y3,  col)
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

    rectAng(12*25.5, 12*10, 28, 25, -30, "green")
    rectAng(Wid-36, 5, 24, 12, 0, "green")

    radX = 8
    radY = 5
    x    = Wid - 11 - radX
    y    = Ht  - 10 - radY
    ellipse(x, y, 0, 360, radX, radY, "green")
}

# ------------------------------------------------
function staging (col) {
    rad = 30
    clr = 3
    xN  = Wid - clr
    x1  = xN - rad

    yN  = Ht - clr
    y2  = yN - rad
    y0  = clr
    y1  = y0 + rad

    arc(x1, y2,  0,  90, rad, col)
    arc(x1, y1, 90, 180, rad, col)
    len  = rad * Pi / 2

    line(xN, y1, xN, y2, col)
    len += y1 - y0

    x0  = x1 - 12*15
    line(x0, yN, x1, yN, col)
    len += x1 - x0

    printf "title_x  staging len = %6.2f", len
    gr = 1.5; printf " (%.2f%% %6.2f)", gr, len*gr/100
    gr = 2.0; printf " (%.2f%% %6.2f)", gr, len*gr/100
    printf "\n"

}

# ------------------------------------------------
function track () {
  # rad = 30
  # x0  = Wid - 32
  # x1  = Wid - 44
  # y0  = Ht - 33
  # y1  =      40
  # y2  =      44

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
    yard(clr, yN-Rad-4,  8, -70, Fn, Sp, col)
    turntable(22, 126, col)
    arc(x1, y2,  0, 90, Rad, col)

    # --------------------------------------
    # pennisula
    col = 9
    arc(x1, Ht-40, 90, 180, Rad, col)
    turnAround(90, 65, 30, 60, Rad, col)
    arc(x1, 36, 0, 90, Rad, col)
    yard(140, 80, -70, -8, Fn, Sp, col)

    # --------------------------------------
    # lower shelf
    col = "orange"
    arc(x1, y1, 90, 180, Rad, col)
    yard(300, clr, -70, 8, Fn, Sp, col)
    turntable(200, 11, col)
  # wye(Wid-12, 12, 24, col)
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
function yard (x0, y0, dx, dy, fN, sp, col) {
    frogDim(fN)

    if (abs(dx) > abs(dy))  {     # horizontal
        xN = x0 + dx
        for (d = 0; d <= abs(dy); d += sp)  {
            line(x0, y0 + sgn(dy)*d, xN, y0 + sgn(dy)*d, col)
            x0 += sgn(dx) * fLead
        }
    }
    else  {                         # vertical
        yN = y0 + dy
        for (d = 0; d <= abs(dx); d += sp)  {
            line(x0 + sgn(dx)*d, y0, x0 + sgn(dx)*d, yN, col)
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

    Wid = 12 * 30
    Ht  = 12 * 12.5

    cn = 22
  # printf "set_color %d = (%d, %d, %d)\n", cn, 30, 30, 30

    # aspect circle
    arc(Wid/2, Ht/2, 0, 360, Ht/2, cn)

    D   = 12 * 2
    A   = (Ht - (3 * D)) / 2

    printf "title   %s\n", "LaVale Train Room"
    printf "thickness = 1.5\n"

    grid(24, cn)
    room("cyan")
    bench(24, "light-gray")
    track()

}' $*

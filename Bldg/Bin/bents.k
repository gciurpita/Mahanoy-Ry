# svg drawing routines - trestle bents

awk '
# ------------------------------------------------
function anno (x, y, text, font)  {
    if (! font)
        font=10
    printf "  <text x=\"%d\" y=\"%d\"", S*x, S*mapY(y)
    printf " font-family=\"Verdana\""
    printf " font-size=\"%d\"", font
    printf ">%s</text>\n", text
}

# ------------------------------------------------
function annoC (x, y, text, font)  {
    if (! font)
        font = 10
    printf "  <text x=\"%d\" y=\"%d\"", S*x, S*mapY(y)
    printf " font-family=\"Verdana\""
    printf " text-anchor=\"middle\""
    printf " font-size=\"%d\"", font
    printf ">%s</text>\n", text
}

# ------------------------------------------------
function comment (text)  {
    printf " <!-- %s -->\n", text
}

# ------------------------------------------------
function line (x0, y0, x1, y1, color)  {
    printf "  <line   x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\"", \
        S*x0, S*mapY(y0), S*x1, S*mapY(y1)
    printf " style=\"stroke:%s;stroke-width:1\"", color
    printf " />\n"
}

# ------------------------------------------------
function mapY (y)  {
    return Ht - y
}

# ------------------------------------------------
function marker () {
  printf "<defs>\n"
  printf "  <marker id=\"arrowhead\" markerWidth=\"10\" markerHeight=\"5\"\n"
  printf "  refX=\"0\" refY=\"2.5\" orient=\"auto\">\n"
  printf "    <polygon points=\"0 0, 10 2.5, 0 5\" />\n"
  printf "  </marker>\n"
  printf "</defs>\n"
}

# ------------------------------------------------
function rectWh (x0, y0, wid, ht, color)  {
    printf " <rect   x=\"%d\" y=\"%d\" width=\"%d\" height=\"%d\"", \
            S*x0, S*mapY(y0+ht), S*wid, S*ht
    printf " style=\"fill:none;stroke:%s;stroke-width:1\"", color
    printf " />\n"
}

# ------------------------------------------------
function rectXy (x0, y0, x1, y1, color, wid, ht)  {
    rect(x0, y0, x1 - x0, y1 - y0, color)
}

# ------------------------------------------------
function svgBegin (wid, ht, scale)  {
    printf "<!-- svgBegin: "
    printf "  wid %4.2f", wid
    printf "  ht %4.2f", ht
    printf "  sc %4.2f", scale
    printf " -->\n"

    Wid = wid
    Ht  = ht
    S   = scale
    if (Html)  {
        printf "\n"
        printf "<p>"
        printf "<table border=1 cellspacing=0 bgcolor=lightcyan> <tr> <td>\n"
    }

    printf "<svg version=\"1.1\" baseProfile=\"full\"\n"
    printf "     width=\"%d\" height=\"%d\"\n", S*Wid, S*Ht
    printf "     xmlns=\"http://www.w3.org/2000/svg\">\n"

  # bgCol = "beige"
    if (bgCol)
        printf "  <rect width=\"100%%\" height=\"100%%\" fill=\"%s\"/>\n", \
            bgCol
}

# ------------------------------------------------
function svgEnd (text)  {
    if (text)
        annoC(Wid/2, Ht - 14/S, text, 14)
    printf "</svg>\n"

    if (H)
        printf "</table>\n"
    printf "\n"
}

# --------------------------------------------------------------------
function profile (lenIn, maxHt) {
    lenFt   = 87 * lenIn / 12
    lenDeck = 2* 45
    lenGr   = lenFt - lenDeck

    ScFt   = 8 * PixPerIn / lenFt
    svgBegin(lenFt, maxHt+5, ScFt)

    line(0, 0, lenGr, maxHt, Col)
    line(lenFt-90, maxHt, lenFt, maxHt, Col)

    for (x = lenGr; x <= lenFt; x += lenDeck/4)
        line(x, 0, x, maxHt, Col)

    anno(lenGr,   0,     lenGr)
    anno(lenGr,   maxHt, maxHt)
    anno(lenFt-9, 0,     lenFt)

    Nbent = 0
    bentPosFt [Nbent]   = lenGr
    bentHtFt  [Nbent++] = maxHt

    gr    = maxHt / lenGr
    anno(5, 5, sprintf("%.1f%%", 100*(gr)))

    dx    = 10
    for (x = lenFt-90 -dx; x > 0; x -= dx)  {
        y = x*gr
        if (y < 3*Beam)
            break
        line(x, 0, x, y, Col)

        bentHtFt  [Nbent] = y
        bentPosFt [Nbent] = x

        anno(bentPosFt [Nbent]+1, 0,     bentPosFt [Nbent])
        anno(bentPosFt [Nbent], maxHt, sprintf("%.1f", bentHtFt [Nbent]))

        Nbent++
    }
    svgEnd()


    if (0)  {
        for (n = 0; n < Nbent; n++)  {
            printf " %3d:", n
            printf " %3d",  bentPosFt [n]
            printf " %3.1f",  bentHtFt [n]
            printf "\n"
        }
    }
}

# --------------------------------------------------------------------
BEGIN  {
    Pi       = atan2(0, -1)
    Sc       = 87
    PixPerIn = 96
    PixPerFt = 150 / 12.5           # HO scale
    PixPerFt = PixPerIn * 12 / 87
    Col      = "black"

    wB = 26 * Pi / 180;   cB = cos(wB);   sB = sin(wB)
    wB = 20 * Pi / 180;   cB = cos(wB);   sB = sin(wB)

    HtBent  = 10        # ft
    WidBent = 8         # ft
    Beam = 1/8 *87/12   # ft
    Sp = 12             # ft
    Gr = 5.5

    printf "<meta http-equiv=\"refresh\" content=\"5\">\n"

    # ------------------------------------------------
    profile(36, HtBent)

    printf "<p>\n"

    # ------------------------------------------------
    # first few can just be stacks of beams
    for (n = 1; n <= 3; n++)  {
        ht   = n * Beam
        dist = ht / (Gr/100)
        printf "<!-- dist %6.1f, ht %6.2f -->\n", dist, ht
        bent(WidBent, ht, Beam, dist)
    }

    # ------------------------------------------------
    # remainder evenly spaced
    if (0)  {
    for (dist += Sp; ; dist += Sp)  {
        ht  = (dist * Gr / 100) - Beam     # account for longitudinals
        if (3 >= ht)
            continue

        if ((HtBent-Beam) < ht)
            break

        printf "<!-- dist %6.1f, ht %6.2f -->\n", dist, ht
        bent(WidBent, ht, Beam, dist)
    }

    for (n = 0; n < 5; n++)
        bent(WidBent, HtBent-Beam, Beam, dist)
    }

    # ------------------------------------------------
    else  {
        for (n = Nbent-1; 0 <= n; n--)
            bent(WidBent, bentHtFt [n], Beam, bentPosFt [n])
    }

    scale(3, 0.2)
}

# ------------------------------------------------
function scale (wid, ht)  {
    svgBegin(wid, ht, PixPerIn)

    line(0, ht/2, wid, ht/2, Col)

    for (x = 0; x <= wid; x ++)
        line(x, 0, x, ht, Col)

    anno(wid/10, 0, sprintf ("%.2f'\''", 87/12))

    svgEnd()
}

# ------------------------------------------------
function bent (wid, ht, sz, dist)  {
    y0    =  2
    y1    =  y0 + ht - sz    # bottom of upper beam
    yBase = y0 + sz          # top    of lower beam

    lB   = (y1-yBase) /cB;   dxB = sB * lB
    wid2 = wid + 2*dxB
    xC   = 2 + wid2/2

    printf "<!--"
    printf "  wid %4.2f", wid
    printf "  ht %4.2f", ht
    printf "  sz %4.2f", sz
    printf "  PixPerFt %4.2f", PixPerFt

    printf ", y0 %4.2f", y0
    printf ", y1 %4.2f", y1
    printf ", yBase %4.2f", yBase

    printf ", xC %4.2f", xC
    printf " -->\n"

    # ----------------------------
    # stacks
    if (3*sz >= ht)  {
        svgBegin(wid+4, ht+4, PixPerFt)

        for (n = 0; n*sz < ht; n++)
            rectWh(xC-wid/2,  y0+n*sz,    wid,  sz, Col)

      # anno(0,     1, sprintf("%.0f", dist), 14)
        anno(0,     1, sprintf("%.2f", dist* 12/87), 14)

        svgEnd()
        return
    }

    # ------------------------------------------------
    svgBegin(2*xC, ht+4, PixPerFt)

    # ----------------------------
    # top/bottom
    comment("upper");
    rectWh(xC-wid/2,  y1,    wid,  sz, Col)
    comment("bottom");
    rectWh(xC-wid2/2, y0,    wid2, sz, Col)

    # ----------------------------
    # inner posts
    xA  = xC + wid/4 - sz/2
    rectWh(xA, yBase, sz, y1-yBase, Col)

    xA  = xC - wid/4 - sz/2
    rectWh(xA, yBase, sz, y1-yBase, Col)

    xF  = wid/4

  # anno(0,     1, sprintf("%.0f", dist), 14)
    anno(0,     1, sprintf("%.2f\"", dist* 12/87), 14)
  # anno(xC-xF, 1, sprintf("%.1f", wid2+0.05), 14)
    anno(xC-xF, 1, sprintf("%.0f'\''", dist), 14)
    anno(xC+xF, 1, sprintf("%.1f", ht),   14)

    # ----------------------------
    # left side
    xD  = xC - wid/2
    xB  = xC - wid2/2
    dx  = sz * cB

    line(xB,    yBase, xD,    y1, Col)
    line(xB+dx, yBase, xD+dx, y1, Col)

    # ----------------------------
    # right side
    dx  = sz * cB
    xD  = xC + wid/2
    xB  = xC + wid2/2

    line(xB,    yBase, xD,    y1, Col)
    line(xB-dx, yBase, xD-dx, y1, Col)

    svgEnd()
}' $* | tee ../bents.htm

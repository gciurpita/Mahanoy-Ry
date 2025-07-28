
awk '
# ------------------------------------------------
function error (msg)  {
    printf " ** Error: %s - %s\n", msg, $0
    exit
}

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
function line (x0, y0, x1, y1, color, wid)  {
    comment(sprintf("line: (%d, %d) (%d, %d)", x0, y0, x1, y1))

    if ("" == wid)
        wid = 1

    printf "  <line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\"", \
        S*x0, S*mapY(y0), S*x1, S*mapY(y1)
    printf " style=\"stroke:%s;stroke-width:1\"", color
    printf " />\n"
}

# ------------------------------------------------
function mapY (y)  {
    return Ht - y
}

# --------------------------------------------------------------------
function path (vecY, N, col) {
    printf "<path d=\"M %d %d\n", 0, Ht - vecY [0]
    for (n = 1; n < N; n++) {
        printf "  L %3d %4d\n", n, Ht - vecY [n]
      # printf "  L %3d %8.4f\n", n,      vecY [n]
    }
    printf "\""
    printf " stroke=\"%s\" stroke-width=\"2\" fill=\"none\" />\n", col
}

# ------------------------------------------------
function rect (x0, y0, wid, ht, col, fill)  {
    printf " <rect   x=\"%d\" y=\"%d\" width=\"%d\" height=\"%d\"", \
                S*x0, S*mapY(y0), S*wid, S*ht
        printf " style=\"fill:%s;stroke:%s;stroke-width:1\"/>\n", fill, col
}

# ------------------------------------------------
function svgBegin (wid, ht, scale, bgCol)  {
    Wid = wid
    Ht  = ht
    S   = scale

    comment(sprintf(" svgBegin: wid %.1f, ht %.1f, scale %.1f", wid, ht, scale))

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
        annoC(Wid/2, Ht - 24/S, text, 24)
    printf "</svg>\n"
}

# --------------------------------------------------------------------
BEGIN  {
    PixPerIn   = 96                # 96
    PixPerScIn = PixPerIn * 1/87
    PixPerScFt = PixPerIn * 12/87

    storyHt = 12
    windWid = 3
    windHt  = 5

    C = 13
    R = 3

    wid   = 30
}

END {
    Ht = storyHt * R
    svgBegin(wid, Ht, PixPerScFt)

    y1 = Ht
    for (row = 0; row < R; row++)  {
        x = 0
        for (col = 0; col < C; col++)  {
            rect(x, y1, windWid, windHt, "gray", "white")

            dd = 2/12
            rect(x+dd, y1-dd, windWid-2*dd, windHt-2*dd, "none", "black")

            if (1)  {
                dx = windWid/4
                for (i = 1; i < 4; i++)  {
                    x2 = x+ i*dx
                    line(x2, y1-dd, x2, y1-windHt+2*dd, "gray", 2)
                }

                dy = windHt/4
                for (i = 1; i < 4; i++)  {
                    y2 = y1 -i*dy
                    line(x+dd, y2, x+windWid-2*dd, y2, "gray", 2)
                }
            }

            x += 2*windWid

            if (wid < x)
                break
        }

      # y1 -= windHt
        y1 -= storyHt
    }
    svgEnd()

    comment(sprintf(" windWid %.2f, windHt %.2f", windWid, windHt))
}' $* << **END**
**END**

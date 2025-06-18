# create .bld flag from dimensions and # stories

awk '

# ------------------------------------------------
NF == 0 || $1 == "#"  {
    next
}

/deck/     { deck     = $2; next }
/door/     { nDoor    = $2; doorWid = $3; doorHt = $4;next }
/sign/     { signTxt = substr($0, index($0, $2)) };
/story/    { nStory   = $2; next }
/width/    { Wid      = $2; next }
/windows/  { nWindow  = $2; windWid = $3; windHt = $4; next }

# --------------------------------------------------------------------
function prLine (x0, y0, x1, y1, col) {
    printf "    line    %4d %4d %4d %4d %s\n", x0, y0, x1, y1, col
}

# --------------------------------------------------------------------
END {
    PixPerFt = 150 / 12.5
    col      = "black"
    x0       = y0 = 5
    brdr     = 5
    brdr2    = 2* brdr

    HtStory  = 12 * PixPerFt
    deck    *= PixPerFt
    Wid     *= PixPerFt
    htBldg   = nStory*HtStory + deck
    htPeak   = htBldg + Wid/3

    Ht       = nStory*HtStory + htPeak + deck

    printf "    space   %4d %4d\n", Wid + brdr2, htPeak + brdr2

    printf "    bldg    %4d %4d %4d %4d\n", x0, y0, Wid, htBldg

    # ------------------------------------------------
    # deck
    if (deck)  {
        deck2 = deck - PixPerFt /3
        prLine(x0, deck2, x0+Wid, deck2, col)

        yMid = deck2 /2
        yHi  = yMid + PixPerFt / 3
        yLo  = yMid - PixPerFt / 3

        N    = int(Wid / deck)
        wid  = Wid / N

        xMid = wid / 2

        for (n = 0; n < N; n++)  {
            x  = brdr + n* wid
            xL = xMid - PixPerFt/3
            xR = xMid + PixPerFt/3

            prLine(x, brdr, x+xL, yMid, col)
            prLine(x, deck2, x+xL, yMid, col)

            prLine(x+wid, brdr, x+xR, yMid, col)
            prLine(x+wid, deck2, x+xR, yMid, col)

            xL = x +       PixPerFt/2
            xR = x + wid - PixPerFt/2

            prLine(xL, brdr, x+xMid, yLo, col)
            prLine(xR, brdr, x+xMid, yLo, col)

            if (1) {
            prLine(xL, deck2, x+xMid, yHi, col)
            prLine(xR, deck2, x+xMid, yHi, col)
            }
        }
    }

    # ------------------------------------------------
    # gable
    xMid     = x0 + Wid/2
    xN       = x0 + Wid
    ySide    = y0 + htBldg
    yPeak    = y0 + htPeak
    printf "    line    %4d %4d %4d %4d %s\n", x0, ySide, xMid, yPeak, col
    printf "    line    %4d %4d %4d %4d %s\n", xN, ySide, xMid, yPeak, col

    # ------------------------------------------------
    # floors
    for (n = 0; n < nStory; n++)  {
        y = deck + n * HtStory
        printf "    line    %4d %4d %4d %4d %s\n", x0, y, x0+Wid, y, col
    }

    # ------------------------------------------------
    # doors
    for (n = 0; n < nDoor; n++)  {
        wid = Wid / nDoor
        x   = n * wid + wid/2 - doorWid/2
        printf "    door    %4d %4d %4d %4d %s\n", \
                x0+x, deck, doorWid, doorHt, col
    }

    # ------------------------------------------------
    # windows
    for (n = 1; n < nStory; n++)  {
        y = deck + n * HtStory + 50
        for (w = 1; w <= nWindow; w++)  {
            x = w * Wid / (1 + nWindow) - windWid/2
            printf "    window  %4d %4d %4d %4d %s\n", \
                x0+x, y, windWid, windHt, col
        }
    }

    # ------------------------------------------------
    # sign
    FontSz = 20
    if (signTxt)  {
        y = HtStory - FontSz + deck
        printf "    sign    %4d %4d %3d %s\n", Wid/2, y, FontSz, signTxt
    }
}' $*

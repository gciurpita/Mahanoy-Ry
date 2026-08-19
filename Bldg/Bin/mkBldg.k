# create .bld from building description

awk '
BEGIN {
    nStory = 1
    color  = "tan"
}

# ------------------------------------------------
NF == 0 || $1 == "#"  {
    next
}

/color/    { color    = $2;                                         next }
/brick/    { brick    = 1;                                          next }
/deck/     { deck     = $2;                                         next }
/door/     { nDoor    = $2; doorWid = $3; doorHt = $4;              next }
/peak/     { peak     = $2;                                         next }
/sign/     { signWid  = $2; signText = substr($0, index($0, $3));   next }
/siding/   { sidingIn = $2;                                         next }
/story/    { nStory   = $2; htStory = $3;                           next }
/width/    { widFt    = $2;                                         next }
/windows/  { nWindow  = $2; windWid = $3; windHt = $4;              next }

/space/    { next }

# --------------------------------------
{
    printf "Error: mkBldg unknown - "
    print
    err++; exit
}

# --------------------------------------------------------------------
END {
    x0 = 5;     y0 = 5
                htFt = htStory * nStory + deck
    if (peak)
                pkFt = widFt / peak

    if (brick)
        color = "#C04657"   # "#792933"           #

    printf "    bldg %3d %3d  %4d %4d %4d  %s\n", \
                    x0, y0, widFt, htFt, pkFt, color

    if (sidingIn)
        printf "    siding %.2f\n", sidingIn
    else if (brick)
        printf "    brick\n"

    if (deck)
        printf "    dock   %.2f\n", deck

    if (nWindow)  {
        spFt = widFt / nWindow
        y    = deck + 3

        for (n = 0; n < nStory; n++)  {
            x    = (spFt - windWid/12) /2 
            for (w = 0; w <  nWindow; w++)  {
                printf "    window  %6.2f %6.2f %6.2f %6.2f %s\n", \
                    x, y, windWid, windHt, col
                x += spFt
            }
            y += htStory
        }
    }

    if (nDoor)  {
        x = (widFt - doorWid/12) / 2
        printf "    door    %6.2f %6.2f %6.2f %6.2f %s\n", \
                            x, deck, doorWid/12, doorHt/12, "red"
    }

    if (signText)  {
        fontSz = 28
        printf "    sign  %3d %3d %4d %4d  %s\n", \
                            widFt/2, htFt -fontSz/12, signWid, fontSz, signText
    }
}' $*

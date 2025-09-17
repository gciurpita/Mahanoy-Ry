awk '
# ------------------------------------------------
function windows (Nrow, Ncol, dw, dh, NpaneX, NpaneY, color )  {
  # printf "#  industrial windows: n %d, WidFt %.2f\n", n, WidFt
    for (row = 0; Nrow > row; row++)  {
        y -= dh/12
        x = 0
        for (col = 0; Ncol > col; col++) {
            printf "    window %6d %6d  %3d %3d %s %d %d\n", \
                                            x, y, dw, dh, color, NpaneX, NpaneY
            x += dw/12
        }
        printf "\n"
    }
}

# --------------------------------------------------------------------
BEGIN {
    WidFt = 50;            HtFt = 90
    Wid   = 9;             Ht   = 6
    printf "    space   %6d %6d\n", WidFt, HtFt

    y  = HtFt

    # ------------------------------------------------
    # windows
    if (0) {
        printf "# windows\n"
        dw  = 36;    dh = 60
        dx  = dw / 12
        for (rows = 2; rows > 0; rows--)  {
            y  -= 1 + +dh / 12
            for (x = 5; x < WidFt - dx; x += dx)  {
                printf "    window %6.2f %6.2f  %5.2f %5.2f %s\n", \
                                x, y, dw, dh, col
            }
            printf "\n"
        }
    }

    # ------------------------------------------------
    windows(Nrow=16, Ncol=21, wid=24, ht=48, NpaneX=2, NpaneY=4, "gray") 


    # ------------------------------------------------
    # doors
    if (0)  {
        y = 870
        dw = 48;    dh = 84
        for (x = 10; x < Wid - dw; x += dw+1)
            printf "    door   %6d %6d  %3d %3d black  2 3\n", x, y, dw, dh
        printf "\n"
    }

    # ------------------------------------------------
  # printf "    scale\n"
}'

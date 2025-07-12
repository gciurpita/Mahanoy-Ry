awk '
BEGIN {
    WidFt = 50;                      HtFt = 50
    Wid   = 9;             Ht   = 6
    printf "    space   %6d %6d\n", WidFt, HtFt

    y  = HtFt

    # ------------------------------------------------
    # windows
    printf "# windows\n"
    if (1) {
        dw  = 36;    dh = 60
        dx  = dw / 12
        for (rows = 2; rows > 0; rows--)  {
            y  -= 1 + +dh / 12
            for (x = 5; x < WidFt - dx; x += dx)  {
                printf "    window %6.2f %6.2f  %5.2f %5.2f  black\n", \
                                x, y, dw, dh
            }
            printf "\n"
        }
    }

    # ------------------------------------------------
    # industrial windows
    printf "# industrial windows\n"
    if (1)  {
        dw  = 72;    dh = 72
        dx = dw / 12
        y  -= 1 +dh/12
        for (n = 4; 0 < n; n--)  {
          # printf "#  industrial windows: n %d, WidFt %.2f\n", n, WidFt
            for (x = 5; x < WidFt - dx; x += dx)  {
                printf "#   industrial windows: n %d, x %d\n", n, x
                printf "    window %6d %6d  %3d %3d black  5 6\n", \
                                            x, y, dw, dh
            }
            printf "\n"
            y -= 1 +dh/12
        }
    }

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
    printf "    scale\n"
}'

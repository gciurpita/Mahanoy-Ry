awk '
BEGIN {
    Wid = 800;  Ht = 1000
    printf "    space   %6d %6d\n", Wid, Ht

    # ------------------------------------------------
    # windows
    if (0) {
        y = 880
        dw = 40;    dh = 72
        for (x = 10; x < Wid - dw; x += dw+5)
            printf "    window %4d %4d  %3d %3d  black\n", x, y, dw, dh
        printf "\n"
    }

    # ------------------------------------------------
    # industrial windows
    if (1)  {
        dw = 60;    dh = 72
        y  = 700;
        for (n = 5; 0 < n; n--)  {
            for (x = 10; x < Wid - dw; x += dw+1)
                printf "    window %6d %6d  %3d %3d black  5 6\n", \
                                            x, y, dw, dh
            printf "\n"
            y -= dh+1
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
}' << **END**


    window    10  910   32   60 black
    window    50  910   32   60 black
    window    90  910   32   60 black

    window   130  910   32   60 black
    window   170  910   32   60 black
    window   210  910   32   60 black
    window   250  910   32   60 black
    window   290  910   32   60 black

    window   330  910   32   60 black
    window   370  910   32   60 black
    window   410  910   32   60 black
    window   450  910   32   60 black
    window   490  910   32   60 black

    door      10  800   36   84 black  2 3
    door      50  800   36   84 black  2 3
    door      90  800   36   84 black  2 3
    door     130  800   36   84 black  2 3
    door     170  800   36   84 black  2 3
    door     210  800   36   84 black  2 3
    door     250  800   36   84 black  2 3
    door     290  800   36   84 black  2 3
    door     330  800   36   84 black  2 3
    door     370  800   36   84 black  2 3
    door     410  800   36   84 black  2 3
    door     450  800   36   84 black  2 3
    door     490  800   36   84 black  2 3

    window    14  710   60   72 black  5 6
    window    82  710   60   72 black  5 6
    window   149  710   60   72 black  5 6
    window   217  710   60   72 black  5 6
    window   284  710   60   72 black  5 6
    window   352  710   60   72 black  5 6
    window   419  710   60   72 black  5 6
    window   487  710   60   72 black  5 6

    window    14  610   60   72 black  5 6
    window    82  610   60   72 black  5 6
    window   149  610   60   72 black  5 6
    window   217  610   60   72 black  5 6
    window   284  610   60   72 black  5 6
    window   352  610   60   72 black  5 6
    window   419  610   60   72 black  5 6
    window   487  610   60   72 black  5 6

    window    14  510   60   72 black  5 6
    window    82  510   60   72 black  5 6
    window   149  510   60   72 black  5 6
    window   217  510   60   72 black  5 6
    window   284  510   60   72 black  5 6
    window   352  510   60   72 black  5 6
    window   419  510   60   72 black  5 6
    window   487  510   60   72 black  5 6

    window    14  410   60   72 black  5 6
    window    82  410   60   72 black  5 6
    window   149  410   60   72 black  5 6
    window   217  410   60   72 black  5 6
    window   284  410   60   72 black  5 6
    window   352  410   60   72 black  5 6
    window   419  410   60   72 black  5 6
    window   487  410   60   72 black  5 6

    window    14  310   60   72 black  5 6
    window    82  310   60   72 black  5 6
    window   149  310   60   72 black  5 6
    window   217  310   60   72 black  5 6
    window   284  310   60   72 black  5 6
    window   352  310   60   72 black  5 6
    window   419  310   60   72 black  5 6
    window   487  310   60   72 black  5 6

    window    14  210   60   72 black  5 6
    window    82  210   60   72 black  5 6
    window   149  210   60   72 black  5 6
    window   217  210   60   72 black  5 6
    window   284  210   60   72 black  5 6
    window   352  210   60   72 black  5 6
    window   419  210   60   72 black  5 6
    window   487  210   60   72 black  5 6

    window    14  110   60   72 black  5 6
    window    82  110   60   72 black  5 6
    window   149  110   60   72 black  5 6
    window   217  110   60   72 black  5 6
    window   284  110   60   72 black  5 6
    window   352  110   60   72 black  5 6
    window   419  110   60   72 black  5 6
    window   487  110   60   72 black  5 6
**END**

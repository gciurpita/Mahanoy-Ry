# create generic .bld file
##
##    space  480 588
##
##    sign   240 180 20 Acme Hauling
##
##    bldg   480 588
##    line     0   0   0 548 black
##    line     4  44   4 548 black
##    line   476  44 476 548 black
##    line   480   0 480 548 black
##
##    line     0 552 488 552 black
##    line     0 548 488 548 black
##    line     0 380 488 380 darkgray
##    line     0 212 488 212 darkgray
##    line     0  44 488  44 black
##    line     0   0 488   0 black
##
##    door   184 44 120 120 black
##
##    window  44 416 32  60  black
##    window 164 416 32  60  black
##    window 284 416 32  60  black
##    window 404 416 32  60  black
##
##    window  44 248 32  60  black
##    window 164 248 32  60  black
##    window 284 248 32  60  black
##    window 404 248 32  60  black

awk '
BEGIN {
    L = 480
    S = 3.5
    D = 1

    HtLdg    = 44
    HtStory  = 12*14
    HtWindow = 36

    HtD  = 12*10
    WidD = 12*10

    HtW  = 60
    WidW = 32
}
END {
    wid  = 12*L
    ht  = HtStory * S

    printf "    space  %4d %4d\n", wid, ht
    printf "    bldg   %4d %4d\n", wid, ht

    printf "    line   %4d %4d %4d %4d black\n", 0,     0, 0,     ht
    printf "    line   %4d %4d %4d %4d black\n", 4,     0, 4,     ht
    printf "    line   %4d %4d %4d %4d black\n", wid-4, 0, wid-4, ht
    printf "    line   %4d %4d %4d %4d black\n", wid,   0, wid,   ht

    # -------------------------------------
    # line delineating floors
    for (s = 0; s < S; s++)  {
        ht = HtLdg + HtStory*s
        printf "    line   %4d %4d %4d %4d black\n", 0, ht, wid, ht
    }
    printf "\n"

    # -------------------------------------
    # windows
    if (0 < W)  {
        dx = wid / W
        x0 = dx / 2 - WidW/2
        for (s = 1; s < S; s++)  {
            y = HtLdg + HtStory*s + HtWindow
            for (w = 0; w < W; w++)  {
                x = x0 + dx * w
                printf "    window   %4d %4d %4d %4d black\n", x, y, WidW,HtW
            }
        }
        printf "\n"
    }

    # -------------------------------------
    #  doors
    if (0 < D)  {
        dx = wid / D
        x0 = dx / 2 - WidD/2
        for (d = 0; d < D; d++)  {
            x = x0 + dx * d
            printf "    door   %4d %4d %4d %4d black\n", x, HtLdg, WidD,HtD
        }
        printf "\n"
    }

}' $* << **END**
**END**

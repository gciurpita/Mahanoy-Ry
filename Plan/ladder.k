
awk '
BEGIN {
    A = 1; R = 2; P = 3; L = 4; ENd  = 5; ED  = 6

    #     ang    rad pre   lead extNd    extD  frog
    s4 = "12.7   26.3   1  5.625   1.5  2.3125   4.5"
    s6 = "9.5    46.8   1  7.8     2.0  1.0      6"


    trkLen = 80
    ladder(0, 0, s4, "orange")
    ladder(0, 0, s6, "green")

    printf "    space -5 -1 15 14\n"
}

# --------------------------------------------------------------------
function ladder (x, y, s, col) {
    F = split(s, fld, " ")

    # ------------------------------------------------
    printf "\n"
    printf "# ------------------------------------------------\n"
    printf "# %s\n", s
    printf "    color %s\n", col
  # printf "    pos %3d %3d\n", 0, 0
    printf "    pos   192 122 180\n"
    printf "\n"

    printf "    lbl   t%d\n", 0
    printf "    curve %5.1f %5.1f\n", fld [R], fld [A]
    printf "    str   %5.1f\n",       fld [ENd]

    N     = 5
    for (n = 1; n < N; n++)  {
        printf "    str   %5.1f\n", fld [P]
        printf "    lbl   t%d\n", n
        printf "    str   %5.1f\n", fld [L] + fld [ENd]
        printf "\n"
    }
    printf "    lbl   t%d\n", n
    printf "\n"

    # ------------------------------------------------
    printf "    mvto  t%d\n", 0
    printf "    str   %d\n",          trkLen
    printf "\n"

    for (n = 1; n < N; n++)  {
        printf "    mvto  t%d\n", n
        printf "    curve %5.1f %5.1f\n", fld [R], -fld [A]
        printf "    str   %d\n",          fld [ED]
        printf "    str   %d\n",          trkLen
        printf "\n"
    }

    printf "    mvto  t%d\n", N
    printf "    curve %5.1f %5.1f\n", fld [R], -fld [A]
    printf "    str   %5.1f\n",       fld [ENd]
    printf "    str   %d\n",          fld [ED]
    printf "    str   %d\n",          trkLen
}'

# strip length difference vs radius

awk '
BEGIN {
    Pi   = atan2(0, -1)

    Rad  = 28       # in
    Arc  = 180      # deg
    Thick = 3/6     # in

    len0 = Rad * Pi
    len1 = (Rad + Thick) * Pi

    printf " %6.2f", len0
    printf " %6.2f", len1
    printf " %6.2f", len1 - len0
    printf "\n"
}'

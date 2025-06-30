
awk '
BEGIN {
    Sc        = 87
    PixPerIn  = 96
    ScFtPerIn  = 12 / Sc
    PixPerScFt = ScFtPerIn * PixPerIn

    printf " %6.3f\" %-8s", 1/Sc, "ScIn"
    printf " %6.3f %-8s\n", PixPerIn/Sc, "Pix/ScIn"

    printf " %6.3f\" %-8s", 12/Sc, "ScFt"
    printf " %6.3f %-8s\n", PixPerScFt, "Pix/ScFt"
    printf " %6.3f 150/12.5\n", 150/12.5
    printf "\n"
}'

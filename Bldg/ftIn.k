
awk '
BEGIN {
    K = 12 / 87
}

! NF { print }

NF {
    printf " (%3d, %3d)", $1, $2
    printf " [%5.2f, %5.2f]", K*$1, K*$2
    printf "\n"
}

END  {
    printf "\n"
    for (n = 1; n <= 16; n++)
        printf " %4d/16  %5.2f\n", n, n/16
}' << **END**
    0 106
    20 98
    20 93
    36 86
    36 70
    45 66
    45 60
    60 54
    68 50
    68 45
    83 39

    24 24
    33 46
    83 88
**END**

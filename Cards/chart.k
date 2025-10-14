
awk '
BEGIN {
    printf "<blockquote>\n"
    printf "<table width=432 border=1 cellspacing=0>\n"

    printf " <tr> <th colspan=7> Mahanoy Valley Ry\n"

    printf " <tr>"
    for (n = 0; n < 4; n++)
        printf " <td width=20>"
    printf " <th> %s", "# Cars"
    printf " <th> %s", "Types"
    printf " <th> %s", "Site"
    printf "\n"
}

/#/  { next }

NF {
    printf " <tr>"
    for (n = 0; n < 4; n++)
        printf " <td width=20>"
    printf " <th> %d", $2
    printf " <th> %s", $1
    printf " <td> %s", substr($0, index($0, $4))
    printf "\n"
}

END {
    printf "</table>\n"

    printf "<p><table border=1 cellspacing=0> <tr><th>Iron Works</table>\n"
    printf "<p><table border=1 cellspacing=0> <tr><th>Gregory Machine</table>\n"
    printf "<p><table border=1 cellspacing=0> <tr><th>Fisher Foundry</table>\n"

    printf "<p><table border=1 cellspacing=0> <tr><th>Warechowski <br>Millwork</table>\n"
    printf "<p><table border=1 cellspacing=0> <tr><th>Fuel Dealer</table>\n"
}' $* | tee chart.htm



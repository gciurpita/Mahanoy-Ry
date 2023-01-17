
awk '
{
    N = 75

    printf "    "
    printf " $%6.2f", $1
    printf " %6d",    $2
    printf "  %4.2f", $1/$2

    printf " $%6.2f",  75 * $1/$2
    printf " $%6.2f", 100 * $1/$2

    printf "   %s", substr($0, index($0, $4))
    printf "\n"
}' << **END**
    35   5  150-500-5   atlas flex track code 83 (yankee dabbler)
    55  10  150-500-10  atlas flex track code 83 (yankee dabbler)
    130 25  150-500-25  atlas flex track code 83 (yankee dabbler)
    475 100 150-500-100 atlas flex track code 83 (yankee dabbler)

    390 75  _           atlas flex track
    425 80  +35         atlas flex track
    445 85  +55         atlas flex track
    480 90  +55+35      atlas flex track

    1   22.46  150-287  atlas LH 30/24 in. curved turnout
    1   22.46  150-288  atlas RH 30/24 in. curved turnout

    1   20.21  150-563  atlas LH code 83 #6 customline turnout
    1   20.21  150-564  atlas RH code 83 #6 customline turnout

    31.98  #6 turnout - code 83 walthers NS dcc friendly

    30+30+30+15+12+10   127/3  42  x2 84
**END**

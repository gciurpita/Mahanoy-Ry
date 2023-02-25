# various layout stuff

awk '
function grade () {
    Rad = 28
    ta  = Pi * Rad
    pen = 2 * 24 * (8 - 3) 
    cur = Rad * Pi * 3/4

    wall = 24 * 3
    cor  = Rad * Pi * 1/4

    printf "grade:"
    printf " loop %.1f", ta
    printf " penn %.1f", pen
    printf " curv %.1f", cur
    printf " wall %.1f", wall
    printf " corn %.1f", cor

    sum = ta + pen + cur + wall + cor
    printf " Tot %6.2f", sum

    printf " %6.2f%%", 100 * 6 / sum
    printf "\n"
}

# ----------------------------------------------------------
function aisle () {
    printf "aisle:"
    printf " wid %.1f",    wid = 12*12
    printf " shelf %.1f",  shelf = 48/3
    printf " penn/2 %.1f", penn_d2 = (48*2/3)/2
    printf " aisle %.1f", wid/2 - shelf - penn_d2
    printf "\n"
}

# ----------------------------------------------------------
BEGIN {
    Pi = atan2(0, -1)

    grade()
    aisle()
}'

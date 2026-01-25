# # cars and track length

awk '
END {
    CarLenFt = 40
    carLenIn = CarLenFt * 12 / 87

    listCars()
    townSpots()
    trkCapacity()
}

# ------------------------------------------------
match(FILENAME, ".car") && NF && ! /#/ {
    if (/type/)
        typeName [$2] = substr($0, index($0, $3))
    else
        cars [$1]++
}

function listCars () {
    printf "car inventory:\n"
    for (type in cars)  {
        printf " %6d  %s\n", cars [type], typeName [type]
        carTotal += cars [type]
    }
    printf " %6d  %s\n", carTotal, "Total"
    printf "\n"
}

# ------------------------------------------------
function townSpots () {
    x = "Gilberton,Maizeville,Mahanoy City,Giradville"
    F = split(x, towns, ",")

    x = "9,5,6,8"
    x = "10,5,6,8"
    F = split(x, spots, ",")

    for (f = 1; f <= F; f++)
        spotTotal += spots [f]

    pct = (carTotal /3) /spotTotal

    printf "Spots:\n %6s %6s %7s\n", "Spots", "Allot", "Len(in)"
    for (f = 1; f <= F; f++)  {
        allocTotal += alloc = pct *spots [f]
        trainLen    = int(alloc +0.5) *carLenIn
        printf " %6s %6.1f %6d  %s\n", \
                spots [f], alloc, trainLen, towns [f]
    }
    printf " %6s %6.1f  %s (%d%%)\n", spotTotal, allocTotal, "Total", 100*pct

    printf "\n"
    printf "%14s %6d  %s (%d cars)\n", "", \
        (carTotal/3) *carLenIn, "staging", carTotal/3

    printf "\n"
    return sum
}

# ------------------------------------------------
function trkCapacity () {
    printf "track capacity:\n"

    x = "55 72 80 84 87 92"
    F = split(x, trkL, " ")

    for (f = 1; f <= F; f++)
        printf " %4d", trkL [f]
    printf "  inches\n"

    for (f = 1; f <= F; f++)
        printf " %4.0f", int(trkL [f] /carLenIn)
    printf "  cars\n"
    printf "\n"
}

# ------------------------------------------------
function trkLengthCapacity () {
    printf "track Capacity:  car: %d ft, %.1f inch\n", CarLenFt, carLenIn
    for (len = 10; len <= 100; len += 10)
        printf " %4d", len
    printf "  inces\n"
    for (len = 10; len <= 100; len += 10)
        printf " %4.1f", len /carLenIn
    printf "  cars\n"
    printf "\n"
}' ../Cards/mahanoy.car

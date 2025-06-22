
awk '
/^#/ { next }

NF {
    F = split($0, fld, ",")
    if (3 > F)
        next

    x = fld [3]
    y = fld [2]
    if (/?/)  {
        gsub("?", "", fld [1])
        printf "anno  %8.6f %8.6f %s\n", x, y, fld [1]
    }

    else if (/_/)
        printf " %8.6f %8.6f\n", x, y

    else {
      # gsub(" ", "", fld [1])
        printf "anno  %8.6f %8.6f %s\n", x, y, fld [1]
        printf " %8.6f %8.6f\n", x, y
    }
}

END {
    printf "title Shamokin Div Station\n"

}' << **END** | tee stations.xgr
    Shamokin        ,40.7875016,-76.5656913
    Exelsior        ,40.7736036,-76.5028599

#   Mt Carmel       ,40.7960805,-76.4219522
    Locust Gap      ,40.7697096,-76.4513032
    Locust Summit   ,40.772029, -76.4244837
    Locust Dale     ,40.7784174,-76.3782414
    _Gordon         ,40.768843, -76.371292
    _Gordon         ,40.763447, -76.365627
    _Gordon         ,40.753890, -76.370090
    _Gordon         ,40.745112, -76.364683
    _Gordon         ,40.745827, -76.351379
    Gordon          ,40.7493717,-76.3605085
    Ashland         ,40.7822481,-76.3646275
    Girardville     ,40.7926211,-76.2936852

    Mahanoy Plane   ,40.7945479,-76.2547427

    Maizeville      ,40.7981061,-76.2431637
#   Shenadoah       ,40.800730, -76.200452
    ?Shenadoah      ,40.814699, -76.198564
    Gilberton       ,40.798771, -76.212857
    Boston Run      ,40.8031434,-76.1891066
    St Nicholas     ,40.8073899,-76.1810198

    Mahanoy City    ,40.8126155,-76.1485187
    Mahanoy Tunnel  ,40.811857,-76.0885285
    Buck Mountain   ,40.811175,-76.085138
    Barnesville     ,40.812883,-76.0498169

    ?Hometown       ,40.823101, -75.980623

    _H   ,40.821672, -76.011822
    _H   ,40.819301, -76.001051
    _H   ,40.810629, -75.997017

    _Tamaqua        ,40.812610, -75.981696
    _Tamaqua        ,40.810207, -75.973070

    Tamaqua         ,40.7987396,-75.9677912


    East Mahanoy Jt
#   Tamaqua         ,40.8058132,-75.9674234

    Tuscarora
    Middleport
    New Philadelphia
    Pottville
**END**

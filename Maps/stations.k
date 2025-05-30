
awk '
/^#/ { next }

NF {
    F = split($0, fld, ",")
    if (3 > F)
        next

    x = fld [3]
    y = fld [2]
    printf " %8.6f %8.6f\n", x, y

    if (! /_/)  {
        gsub("   ", "", fld [1])
        printf "anno  %8.6f %8.6f %s\n", x, y, fld [1]
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
    Shenadoah       ,40.800730, -76.200452
    Gilberton       ,40.798771, -76.212857

    Mahanoy City    ,40.8126155,-76.1485187

    Buck Mountain
    East Mahanoy Jt
    Barnesville
#   Tamaqua         ,40.8058132,-75.9674234

    Tuscarora
    Middleport
    New Philadelphia
    Pottville
**END**

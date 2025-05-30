
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

}' << **END** | tee lehighAndMahanoy.xgr
    Black Creek     ,40.9738914,-76.2197586
    Hartz
    Gerhard
    Switch Back
    Quakake Jct     ,40.8517516,-76.0566403
    Delano          ,40.840431,-76.0660655
    Meyersville
    Mahanoy City    ,40.812616,-76.138219
    Yatesville
    Shenandoan      ,40.814699,-76.1985639
    Raven Run       ,40.8161967,-76.2741539
    Centralia       ,40.8038755,-76.3543067
    Mount Carmel    ,40.7960805,-76.4219522
**END**

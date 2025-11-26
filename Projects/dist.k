# study of switching algorithms

awk '
/loc/  {
    F = split($2, fld, "-")
    lbl = fld [1]
    loc [lbl] = "_"

    if (1 < F)
        loc [lbl] = fld [2]

    desc [lbl] = $3
  # printf "find %s %s\n", lbl, loc [lbl]
}

# ------------------------------------------------
/mvto/  {
    lbl = $3
    if (! loc [lbl])
        next

    re [lbl] = $NF
  # printf "mvto %4s %6d\n", lbl, re [lbl]
}

# ------------------------------------------------
/lbl/  {
    lbl = $3
    if (! loc [lbl])
        next

    if ("_" == loc [lbl])  {
        loc [lbl] = $NF
        printf "  loc   %s   %6d  %s\n", lbl, loc [lbl], desc [lbl]
    }
    else  {
        from      = loc [lbl]
        loc [lbl] = $NF - re [from]
        printf "  loc   %s-%s %6d  %s\n", lbl, from, loc [lbl], desc [lbl]
    }


}' << **END**
    loc  c      Maizeville-East
    loc  d-c    Iron-Machine-Freight
    loc  e-c    Foundry
    loc  f      Maizeville-West
    loc  g      Breaker
    loc  V      Staging-Jct
    loc  R-V    Gilberton-West
    loc  s-R    Coal-Dealer
    loc  S-R    Freight-House
    loc  U      Gilberton-Eest
    loc  Y-U    switchback(??)
    

# lbl:   B     xPos 336.40, yPos  82.54, dir  200.0, trkLen     0.00
# lbl:   a     xPos 324.89, yPos  78.35, dir  200.0, trkLen    12.25
# lbl:   b     xPos 315.99, yPos  76.06, dir  190.0, trkLen    21.45
# mvto:  b     xPos 315.99, yPos  76.06, dir  190.0, trkLen    88.66
# mvto:  a     xPos 324.89, yPos  78.35, dir  200.0, trkLen   154.29
# mvto:  B     xPos 336.40, yPos  82.54, dir  200.0, trkLen   231.35
# lbl:   b     xPos 294.09, yPos  86.62, dir  180.0, trkLen   274.98
# mvto:  b     xPos 294.09, yPos  86.62, dir    0.0, trkLen   274.98
# mvto:  b     xPos 294.09, yPos  86.62, dir  180.0, trkLen   348.61
# lbl:   c     xPos 270.09, yPos  86.62, dir  180.0, trkLen   372.61
# lbl:   f     xPos 166.09, yPos  86.62, dir  180.0, trkLen   476.61
# lbl:   g     xPos 140.09, yPos  86.62, dir  180.0, trkLen   502.61
# mvto:  g     xPos 140.09, yPos  86.62, dir  180.0, trkLen   528.73
# lbl:   V     xPos 104.29, yPos  48.11, dir   30.0, trkLen   684.48
# lbl:   Q     xPos 130.42, yPos  58.86, dir    0.0, trkLen   713.14
# mvto:  c     xPos 270.09, yPos  86.62, dir  180.0, trkLen   713.14
# lbl:   d     xPos 243.77, yPos  85.19, dir  180.0, trkLen   739.54
# lbl:   e     xPos 183.77, yPos  85.19, dir  180.0, trkLen   799.54
# mvto:  d     xPos 243.77, yPos  85.19, dir    0.0, trkLen   817.95
# mvto:  d     xPos 243.77, yPos  85.19, dir  180.0, trkLen   852.21
# mvto:  e     xPos 183.77, yPos  85.19, dir  180.0, trkLen   896.47
# mvto:  V     xPos 104.29, yPos  48.11, dir   30.0, trkLen   946.13
# lbl:   x     xPos 119.53, yPos  59.73, dir   40.0, trkLen   965.33
# mvto:  x     xPos 119.53, yPos  59.73, dir   40.0, trkLen  1098.88
# lbl:   y     xPos 127.01, yPos  65.08, dir   30.0, trkLen  1108.08
# mvto:  y     xPos 127.01, yPos  65.08, dir   30.0, trkLen  1232.74
# mvto:  Q     xPos 130.42, yPos  58.86, dir    0.0, trkLen  1354.72
# lbl:   R     xPos 185.42, yPos  58.86, dir    0.0, trkLen  1409.72
# mvto:  R     xPos 185.42, yPos  58.86, dir    0.0, trkLen  1513.72
# lbl:   s     xPos 209.74, yPos  60.29, dir    0.0, trkLen  1538.12
# lbl:   S     xPos 221.74, yPos  60.29, dir    0.0, trkLen  1550.12
# lbl:   T     xPos 263.74, yPos  60.29, dir    0.0, trkLen  1592.12
# lbl:   U     xPos 290.06, yPos  58.86, dir    0.0, trkLen  1618.53
# mvto:  S     xPos 221.74, yPos  60.29, dir    0.0, trkLen  1618.53
# mvto:  s     xPos 209.74, yPos  60.29, dir  180.0, trkLen  1664.14
# mvto:  U     xPos 290.06, yPos  58.86, dir    0.0, trkLen  1702.05
# lbl:   Y     xPos 313.49, yPos  64.05, dir    0.0, trkLen  1726.20
# lbl:   tail  xPos 323.49, yPos  64.05, dir    0.0, trkLen  1736.20
# mvto:  Y     xPos 313.49, yPos  64.05, dir  180.0, trkLen  1756.20
# lbl:   E     xPos 283.47, yPos  68.00, dir  180.0, trkLen  1786.67
# lbl:   D     xPos 273.47, yPos  68.00, dir  180.0, trkLen  1796.67
# lbl:   C     xPos 263.47, yPos  68.00, dir  180.0, trkLen  1806.67
# lbl:   B     xPos 253.47, yPos  68.00, dir  180.0, trkLen  1816.67
# lbl:   A     xPos 243.47, yPos  68.00, dir  180.0, trkLen  1826.67
# mvto:  U     xPos 290.06, yPos  58.86, dir    0.0, trkLen  1836.67
# lbl:   Z     xPos 326.06, yPos  58.86, dir    0.0, trkLen  1872.67
**END**

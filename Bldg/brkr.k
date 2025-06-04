
awk '
function ln (x0, y0, x1, y1, col) {
    printf "    line  %4d %4d %4d %4d %s\n", x0*Sc, y0*Sc, x1*Sc, y1*Sc, col
}

function sp (x0, y0)  {
    printf "    space  %4d %4d\n", x0*Sc, y0*Sc
}

BEGIN {
    PixPerFt = 150 / 12.5
    Sc = (1/2) *  PixPerFt * 87 / 12

    c  = "black"

    W   = 14
    dX  = W / 5
    H   = 16
    dSl = 1.5
    dY  = 2

    x0  = x = 1
    y0  = y = 1

    sp(W+2, H+2)
    x1 = x;     y1 = y+H;    ln(x, y, x1, y1, c); x = x1; y = y1
    x1 = x+dX;  y1 = y-dSl;  ln(x, y, x1, y1, c); x = x1; y = y1

    x1 = x;     y1 = y+dSl;  ln(x, y, x1, y1, c); x = x1; y = y1

    x1 = x+dX;  y1 = y-dSl;  ln(x, y, x1, y1, c); x = x1; y = y1
    x1 = x;     y1 = y-dY;   ln(x, y, x1, y1, c); x = x1; y = y1

    x1 = x+dX;  y1 = y-dSl;  ln(x, y, x1, y1, c); x = x1; y = y1
    x1 = x;     y1 = y-dY;   ln(x, y, x1, y1, c); x = x1; y = y1

    x1 = x+dX;  y1 = y-dSl;  ln(x, y, x1, y1, c); x = x1; y = y1
    x1 = x;     y1 = y-dY;   ln(x, y, x1, y1, c); x = x1; y = y1

    x1 = x+dX;  y1 = y-dSl;  ln(x, y, x1, y1, c); x = x1; y = y1
    x1 = x;     y1 = y0;     ln(x, y, x1, y1, c); x = x1; y = y1

    x1 = x0;    y1 = y0;     ln(x, y, x1, y1, c); x = x1; y = y1
}'

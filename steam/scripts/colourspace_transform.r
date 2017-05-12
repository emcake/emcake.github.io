xyzpiv <- function( n )
{
  #return (n > 0.04045 ? Math.Pow((n + 0.055) / 1.055, 2.4) : n / 12.92) * 100.0;
  x <- if (n > 0.04045) ((n+0.055)/1.055)^2.4 else n/12.92;
  
  return (x * 100);
}

rgb2xyz2 <- function( r, g, b )
{  
  rp = xyzpiv( r );
  gp = xyzpiv( g );
  bp = xyzpiv( b );
  
  X<- rp*0.4124 + gp*0.3576 + bp*0.1805;
  Y<- rp*0.2126 + gp*0.7152 + bp*0.0722;
  Z<- rp*0.0193 + gp*0.1192 + bp*0.9505;
  
  return (c(X, Y, Z));
}

rgb2xyz <- function( i )
{
  return (rgb2xyz2( i[1], i[2], i[3]));
}

rgb2xyzM <- function( M )
{
  retM = M;
  
  d = dim( M );
  
  for ( x in 1:d[1] )
  {
    for( y in 1:d[2] )
    {
      retM[x,y,] = rgb2xyz( M[x,y,] );
    }
  }
  
  return (retM );
}

labpiv <- function( n )
{
  eps = 216/24389;
  kap = 24389/27;
  
  p <- if(n < eps) (kap * n + 16) / 116 else n^ (1/3);
  return(p)
}

xyz2lab2 <- function( x, y, z )
{
  white = rgb2xyz2(1, 1, 1);
  
  xn = labpiv(x / white[1]);
  yn = labpiv(y / white[2]);
  zn = labpiv(z / white[3]);
  
  L = max(0, 116*yn - 16);
  A = 500*(xn-yn);
  B = 200*(yn-zn);
  
  return(c(L, A, B));
}

xyz2lab <- function( i )
{
  return (xyz2lab2( i[1], i[2], i[3] ));
}

rgb2lab <- function( r, g, b )
{
  xyz = rgb2xyz( r, g, b );
  
  return (xyz2lab( xyz ));
}

rgb2labM <- function( M )
{
  retM = M;
  
  d = dim(M);
  
  for ( x in 1:d[1] )
  {
    for( y in 1:d[2] )
    {
      retM[x,y,] = xyz2lab( rgb2xyz( M[x,y,] ) );
    }
  }
  
  return( retM );
}

rgb2i <- function( M )
{
  d = dim(M);

  retM = matrix( data=NA, nrow=d[1], ncol=d[2] );
  
  for ( x in 1:d[1] )
  {
    for( y in 1:d[2] )
    {
      retM[x,y] = mean(M[x,y,]);
    }
  }
  
  return (retM);
}

rgb2xyz.Image <- function( i )
{
  lab = rgb2xyz( i[,,1], i[,,2], i[,,3] );
  d=dim( i );
  
  return (Image( lab, dim=d, colormode=Color ));
}

rgb2lab.Image <- function( i )
{
  lab = rgb2lab( i[,,1], i[,,2], i[,,3] );
  d=dim( i );
  
  return (Image( lab, dim=d, colormode=Color ));
}
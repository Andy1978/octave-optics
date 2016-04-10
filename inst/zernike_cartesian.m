## Copyright (C) 2015 Andreas Weber <andy.weber.aw@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {@var{Z} =} zernike_cartesian (@var{x}, @var{y}, @var{n})
## @deftypefnx {Function File} {@var{Z} =} zernike_cartesian (@var{x}, @var{y}, @var{n}, @var{limit_r})
## Return the cartesian zernikes up to order n (as noll's index).
##
## If @var{limit_r} is false (default true), the polynoms for r>1 are @emph{not} set to NaN
## because strictly, the polynoms are only defined for 0 <= r <= 1.
##
## Size of @var{x} must be equal size of @var{y}.
##
## Demo: type "demo zernike_cartesian"
##
## @seealso{zernike_name, zernike_noll_to_nm, zernike_polar, zernike_R_poly}
## @end deftypefn

## TODO: The cartesian zernikes can be calculated quicker for example using a method
## described in "Hedser van Brug: Efficient Cartesian representation of Zernike polynomials."
## Until then the cartesians get mapped to the polar ones.

function Z = zernike_cartesian (x, y, n, limit_r = true)
  if (nargin < 3 || nargin > 4)
    print_usage ();
  elseif (! isscalar (n) || n < 1 || n != fix (n))
    error ("zernike_cartesian: N must be a integer >=1");
  elseif (ndims (x) != ndims (y) || any (size (x) != size (y)))
    error ("zernike_cartesian: X and Y must have the same size")
  endif
  r   = sqrt (x.*x + y.*y);
  phi = atan2 (y, x);
  Z   = zernike_polar (r, phi, n, limit_r);
endfunction

%!demo
%! t = linspace (-1, 1, 80);
%! [x, y] = meshgrid (t, t);
%! max_order = 16;
%! Z = zernike_cartesian (x, y, max_order);
%! for k = 1:max_order
%!   subplot (4, 4, k)
%!   factors = zeros (max_order, 1);
%!   factors(k) = 1;
%!   z = reshape (Z*factors, size (x));
%!   imagesc (z)
%!   axis ("off", "equal")
%!   zname = strrep (zernike_name (k), " ", "\n");
%!   title (zname)
%! endfor

%!demo
%! n=30;
%! [x,y,z] = sombrero (n);
%! z += 0.05 * peaks (x./4, y./4);
%! z += 0.02 * x;
%! figure
%! surf (x, y, z)
%! title ("Original sombrero + peaks + tilt");
%! 
%! ## approximate sombrero+peaks
%! d = 10;
%! x /= d;
%! y /= d;
%! max_order = 50;
%! Z = zernike_cartesian (x, y, max_order, false);
%! f = Z\z(:);
%! ## create approximated plot
%! z_approx = reshape (Z * f, n, n);
%! figure
%! surf (10 * x, 10 * y, z_approx)
%! title ("approximated");

%!assert (zernike_cartesian (0, 0, 1), 1)
%!error (zernike_cartesian (0, 0, 0))
%!error (zernike_cartesian (0, 0, pi))
%!error (zernike_cartesian ())

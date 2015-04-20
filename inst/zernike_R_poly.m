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
## @deftypefn {Function File} {@var{R} =} zernike_R_poly (@var{m}, @var{n})
## Return the first part of the radial zernike polynom R^m_n.
##
## The polynom returned has a length of N+1.
## @seealso{zernike_cartesian, zernike_name, zernike_noll_to_nm, zernike_polar}
## @end deftypefn

function ret = zernike_R_poly (m, n)
  if (nargin != 2)
    print_usage ();
  elseif (! isscalar (m) || m < 0 || m != fix (m) ||
          ! isscalar (n) || n < 0 || n != fix (n))
    error ("zernike_R_poly: M and N must all be non-negative integers");
  endif
  ret = zeros (1, n+1);
  if (! mod (n-m, 2))
    #TODO: try to omit for-loop
    for k = 0:(n-m)/2
      ret(2*k+1) = (-1)^k * bincoeff (n-k, k) * bincoeff (n-2*k, (n-m)/2-k);
    endfor
  endif
endfunction

## see http://en.wikipedia.org/wiki/Zernike_polynomials#Radial_polynomials
## added all examples up to order 6
%!assert (zernike_R_poly (0, 0), [1])
%!assert (zernike_R_poly (1, 1), [1 0])
%!assert (zernike_R_poly (0, 2), [2 0 -1])
%!assert (zernike_R_poly (2, 2), [1 0 0])
%!assert (zernike_R_poly (1, 3), [3 0 -2 0])
%!assert (zernike_R_poly (3, 3), [1 0 0 0])
%!assert (zernike_R_poly (0, 4), [6 0 -6 0 1])
%!assert (zernike_R_poly (2, 4), [4 0 -3 0 0])
%!assert (zernike_R_poly (4, 4), [1 0 0 0 0])
%!assert (zernike_R_poly (1, 5), [10 0 -12 0 3 0])
%!assert (zernike_R_poly (3, 5), [5 0 -4 0 0 0])
%!assert (zernike_R_poly (5, 5), [1 0  0 0 0 0])
%!assert (zernike_R_poly (0, 6), [20 0 -30 0 12 0 -1])
%!assert (zernike_R_poly (2, 6), [15 0 -20 0  6 0  0])
%!assert (zernike_R_poly (4, 6), [ 6 0  -5 0  0 0  0])
%!assert (zernike_R_poly (6, 6), [ 1 0   0 0  0 0  0])

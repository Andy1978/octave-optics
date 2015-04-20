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
## @deftypefn  {Function File} {@var{Z} =} zernike_polar (@var{r}, @var{phi}, @var{n})
## @deftypefnx {Function File} {@var{Z} =} zernike_polar (@var{r}, @var{phi}, @var{n}, @var{limit_r})
## Return the polar zernikes up to order n (as noll's index).
##
## If @var{limit_r} is false (default true), the polynoms for r>1 are @emph{not} set to NaN
## because strictly, the polynoms are only defined for 0 <= r <= 1.
##
## The first argument @var{r} is a matrix containing the radial distance,
## the second argument @var{phi} a matrix with the angles.
##
## Size of @var{r} must be equal size of @var{phi}.
##
## This file hasn't a demo yet but have a look on "demo zernike_cartesian"
## @seealso{zernike_cartesian, zernike_name, zernike_noll_to_nm, zernike_R_poly}
## @end deftypefn

function Z = zernike_polar (r, phi, n, limit_r = true)
  if (nargin < 3 || nargin > 4)
    print_usage ();
  elseif (! isscalar (n) || n < 1 || n != fix (n))
    error ("zernike_polar: n must be a integer >=1");
  elseif (any (size (r) != size (phi)))
    error ("zernike_polar: R and PHI must have the same size")
  endif
  Z = zeros (numel (r), n);
  for k = 1:n
    [m, n] = zernike_noll_to_mn (k);
    P      = zernike_R_poly (abs (m), n);
    r_eval = polyval (P, r(:));
    if (m < 0)
      r_eval = r_eval .* sin (abs (m) * phi(:));
    else
      r_eval = r_eval .* cos (m * phi(:));
    endif
    Z(:, k) = r_eval;
  endfor
  if (limit_r)
    Z(r(:) > 1, :) = NaN;
  endif
endfunction

%!test
%! r   = 0.2;
%! phi = 1.23;
%! n   = 4;
%! ret = zernike_polar (r, phi, n);
%! assert (ret, [1 r*cos(phi) r*sin(phi) 2*r^2-1], 5*eps)

%!test
%! r   = [0.5 0.8]; 
%! phi = [pi/4 pi/4];
%! n   = 4;
%! ret = zernike_polar (r, phi, n);
%! assert (ret, [1 r(1)*cos(phi(1)) r(1)*sin(phi(1)) 2*r(1)^2-1; 1 r(2)*cos(phi(2)) r(2)*sin(phi(2)) 2*r(2)^2-1], 5*eps)

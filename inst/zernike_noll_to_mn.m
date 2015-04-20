## Copyright (C) 2012 Andreas Weber <andy.weber.aw@gmail.com>
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
## @deftypefn {Function File} {[@var{m}, @var{n}] =} zernike_noll_to_mn (@var{j})
## Convert Noll's index @var{j} to @var{m} (Azimuthal degree) and @var{n} (Radial degree).
##
## See sequence A176988 in OEIS (http://oeis.org/A176988)
## @seealso{zernike_cartesian, zernike_name, zernike_polar, zernike_R_poly}
## @end deftypefn

function [m, n] = zernike_noll_to_mn (j)
  if (nargin != 1 || nargout != 2)
    print_usage ();
  elseif (any (j(:) < 1 | j(:) != fix (j(:))) || ! isvector (j))
    error ("zernike_noll_to_mn: j has to be a vector with integers >=1");
  endif
  n  = fix (sqrt (2*j-1) + 0.5) - 1;
  s  = mod (n, 2);
  me = 2 * fix ((2*j + 1 - n.*(n+1)) / 4);        #the even ones
  mo = 2 * fix ((2*(j+1) - n.*(n+1)) / 4) - 1;    #the odd ones
  m  = (mo.*s + me.*(1-s)).*(1 - 2*mod(j,2));
endfunction

## see http://oeis.org/A176988
##
%!test
%! [m,n]=zernike_noll_to_mn(1);
%! assert([m n],[0 0])
%!test
%! [m,n]=zernike_noll_to_mn(2);
%! assert([m n],[1 1])
%!test
%! [m,n]=zernike_noll_to_mn(3);
%! assert([m n],[-1 1])
%!test
%! [m,n]=zernike_noll_to_mn(4);
%! assert([m n],[0 2])
%!test
%! [m,n]=zernike_noll_to_mn(5);
%! assert([m n],[-2 2])

## skipp noll indices 6..19 FIXME: or should we add all to this test?

%!test
%! [m,n]=zernike_noll_to_mn(20);
%! assert([m n],[5 5])

## skipp noll indices 21..33 FIXME: or should we add all to this test?

%!test
%! [m,n]=zernike_noll_to_mn(34);
%! assert([m n],[5 7])
%!test
%! [m,n]=zernike_noll_to_mn(35);
%! assert([m n],[-7 7])
%!test
%! [m,n]=zernike_noll_to_mn(36);
%! assert([m n],[7 7])

## vector test
%!test
%! [m,n]=zernike_noll_to_mn([2 5 8 35]);
%! assert(m,[1 -2 1 -7])
%! assert(n,[1 2 3 7])

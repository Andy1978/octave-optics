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
## @deftypefn {Function File} {@var{name} =} zernike_name (@var{n})
## Return the classic name for noll's index @var{n} or
## "-" (no name defined) without warning if @var{n} > 21.
##
## Examples:
## @example
## @group
## zernike_name(4)
##     @result{} defocus
## zernike_name(21)
##     @result{} vertical pentafoil
## @end group
## @end example
##
## @seealso{zernike_cartesian, zernike_noll_to_nm, zernike_polar, zernike_R_poly}
## @end deftypefn

function name = zernike_name (n)
  ## taken from http://www.telescope-optics.net/zernike_coefficients.htm
  persistent classical_names = ...
  {
    "piston";
    "horizontal tilt";
    "vertical tilt";
    "defocus";
    "oblique primary astigmatism";
    "vertical primary astigmatism";
    "vertical coma";
    "horizontal coma";
    "vertical trefoil";
    "oblique trefoil";
    "primary spherical";
    "vertical secondary astigmatism";
    "oblique secondary astigmatism";
    "vertical quadrafoil";
    "oblique quadrafoil";
    "horizontal secondary coma";
    "vertical secondary coma";
    "oblique secondary trefoil";
    "vertical secondary trefoil";
    "oblique pentafoil";
    "vertical pentafoil";
  };
  if (nargin != 1)
    print_usage ();
  elseif (! isscalar (n) || n < 1 || n != fix (n))
    error ("zernike_name: n must be a integer >=1");
  endif
  if (n > numel (classical_names))
    name = "-";
  else
    name = classical_names{n};
  endif
endfunction

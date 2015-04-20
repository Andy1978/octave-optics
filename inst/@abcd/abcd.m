## Copyright (C) 2015 Andreas Weber <octave@tech-chat.de>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{S} = } abcd(@var{element}, @var{value}, @dots{})
## Create an abcd matrix chain from element/value pairs.
##
## https://en.wikipedia.org/wiki/Ray_transfer_matrix_analysis
##
## Valid elements are:
## @table @samp
##
## @item propagation
## value: [distance]
##
## @item thin-lens
## value: [focal_length]
##
## @item flat-refraction
## value: [n1, n2]
##
## @item curved-refraction
## value: [n1, n2, R]
##
## @item flat-mirror
## value: []
##
## @item curved-mirror
## value: [R]
##
## @item thick-lens
## value: [n1, n2, R1, R2, t]
##
## @end table
##
## See @code{demo @@abcd/trace} for examples.
##
## @seealso{trace}
## @end deftypefn

function ret = abcd (varargin)

  if (mod (nargin, 2) != 0)
    error ("Input has to be element, value pairs.")
  endif

  s.elements = varargin;
  ret = class (s, "abcd");

  ## check inputs
  rout = trace (ret, [1; 1]);

endfunction


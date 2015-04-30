## Copyright (C) 2013 Martin Vogel <octave@martin-vogel.info>
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by the
## Free Software Foundation; either version 3 of the License, or (at your
## option) any later version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
## for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {@var{M} =} mueller_linpolarizer()
## @deftypefnx {Function File} {@var{A} =} mueller_linpolarizer(@var{[m, n, ...]})
## @deftypefnx {Function File} {@var{A} =} mueller_linpolarizer(@var{C})
## Return the Mueller matrix for an ideal linear polarizer.
##
## @itemize @minus
## @item @var{[m, n, ...]} defines the size of the cell array @var{A}
## and therefore the number of linear polarizer matrices returned.
## @item @var{C} is a cell array defining the size of the returned cell array
## @var{A}, @code{size(A)==size(C)}. The content of @var{C} is of not
## evaluated in this case.
## @end itemize
##
## References:
##
## @enumerate
## @item E. Collett, Field Guide to Polarization,
##       SPIE Field Guides vol. FG05, SPIE (2005). ISBN 0-8194-5868-6.
## @item R. A. Chipman, "Polarimetry," chapter 22 in Handbook of Optics II,
##       2nd Ed, M. Bass, editor in chief (McGraw-Hill, New York, 1995)
## @item @url{http://en.wikipedia.org/wiki/Mueller_calculus, "Mueller calculus"},
##       last retrieved on Dec 17, 2013.
## @end enumerate
##
## @seealso{mueller_depolarizer}
## @end deftypefn

function M = mueller_linpolarizer(varargin)

  retcell = true;
  if nargin<1
    sc = [1,1];
    retcell = false;
  elseif isnumeric(varargin{1})
    sc = varargin{1};
  else
    sc = size(varargin{1});
  end

  if prod(sc) > 1 || retcell

    M = cell(sc);
    [M{:}] = deal(s_linpolarizer());

  else

    M = s_linpolarizer();

  end

end

% helper function
function M = s_linpolarizer()

  M = zeros(4,4);

  M(1,1) = 0.5;
  M(1,2) = 0.5;
  M(2,1) = 0.5;
  M(2,2) = 0.5;

end

%!test
%! % applying a linear polarizer twice is identical to
%! % apply it once!
%! A = mueller_linpolarizer();
%! R = A*A-A;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test direct size parameter
%! for dim = 1:5
%!   asize = randi([1 4], 1, dim);
%!   rsize = size(rand(asize));
%!   U = mueller_linpolarizer(rsize);
%!   usize = size(U);
%!   assert(usize == rsize);
%! end
%!
%!test
%! % test indirect size parameter
%! for dim = 1:5
%!   asize = randi([1 4], 1, dim);
%!   C = cell(asize);
%!   csize = size(C);
%!   U = mueller_linpolarizer(C);
%!   usize = size(U);
%!   assert(usize == csize);
%! end
%!


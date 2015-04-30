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
## @deftypefn  {Function File} {@var{M} =} mueller_mirror()
## @deftypefnx {Function File} {@var{A} =} mueller_mirror(@var{[m, n, ...]})
## @deftypefnx {Function File} {@var{A} =} mueller_mirror(@var{C})
## Return mirror Mueller matrices, representing a non-polarizing
## optical element.
##
## @itemize @minus
## @item @var{[m, n, ...]} defines the size of the cell array @var{A}
## and therefore the number of mirror matrices returned.
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
## @seealso{mueller_unity}
## @end deftypefn

function M = mueller_mirror(varargin)

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
    [M{:}] = deal(s_mirror());

  else

    M = s_mirror();

  end

end

% helper function
function M = s_mirror()

  M = zeros(4,4);
  M(1,1) = 1;
  M(2,2) = 1;
  M(3,3) = -1;
  M(4,4) = -1;

end

%!test
%! % test mirror that is its own inverted element
%! A = mueller_mirror();
%! R = (A-1\A);
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test direct size parameter
%! for dim = 1:5
%!   asize = randi([1 4], 1, dim);
%!   rsize = size(rand(asize));
%!   U = mueller_mirror(rsize);
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
%!   U = mueller_mirror(C);
%!   usize = size(U);
%!   assert(usize == csize);
%! end
%!


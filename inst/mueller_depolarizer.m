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
## @deftypefn  {Function File} {@var{M} =} mueller_depolarizer()
## @deftypefnx {Function File} {@var{M} =} mueller_depolarizer(@var{p})
## Return Mueller matrices for a (partial) depolarizer.
##
## @itemize @minus
## @item @var{p} is the depolarization, ranging from 0 to 1,
## if not given or set to [] the default value 0 is used.
## @end itemize
##
## Argument @var{p} can be passed as a scalar or as a matrix or as a
## cell array. In the two latter cases, a cell array @var{M} of
## Mueller matrices of the same size is returned.
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
## @seealso{mueller_linpolarizer}
## @end deftypefn

function M = mueller_depolarizer(varargin)

  depolarization_defv = 0;

  if nargin<1
    depolarization = depolarization_defv;
  else
    depolarization = varargin{1};
  end

  [depolarization, was_cell] = __c2n__(depolarization, depolarization_defv);

  if (numel(depolarization) > 1) || was_cell

    M = cell(size(depolarization));
    M_subs = cell(1,ndims(M));
    for mi=1:numel(M)
      [M_subs{:}] = ind2sub(size(M),mi);
      M{M_subs{:}} = s_depolarizer(depolarization(M_subs{:}));
    end

  else

    M = s_depolarizer(depolarization);

  end

end

% helper function
function M = s_depolarizer(depolarization)

  M = zeros(4,4);
  M(1,1) = 1;
  M(2,2) = depolarization;
  M(3,3) = depolarization;
  M(4,4) = depolarization;

end

%!test
%! % test default return value
%! A = mueller_depolarizer();
%! R = A*A-A;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test serial application of matrix
%! depolarization = rand(1, 1);
%! A1 = mueller_depolarizer(depolarization);
%! A2 = mueller_depolarizer(depolarization^2);
%! R = A1*A1-A2;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % another test of serial application
%! depolarization1 = rand(1, 1);
%! depolarization2 = rand(1, 1);
%! A1 = mueller_depolarizer(depolarization1);
%! A2 = mueller_depolarizer(depolarization2);
%! A12 = mueller_depolarizer(depolarization1*depolarization2);
%! R = A1*A2-A12;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test size of return value
%! for dim = 1:5
%!   asize = randi([1 4], 1, dim);
%!   R = rand(asize);
%!   if numel(R) == 1
%!     R = {R};
%!   end
%!   rsize = size(R);
%!   C = mueller_depolarizer(R);
%!   csize = size(C);
%!   assert(rsize == csize);
%! end


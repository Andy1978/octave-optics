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
## @deftypefn  {Function File} {@var{t} =} mueller_ismueller(@var{M})
## @deftypefnx {Function File} {@var{[t,u,...]} =} mueller_ismueller(@var{M,N,...})
## Check computational validity of Mueller matrix or matrices.
##
## @itemize @minus
## @item @var{M,N,...} define potential (arrays of) Mueller matrices.
## After checking the parameters for validity, the function returns
## boolean arrays @var{t,u,...} of corresponding size.
## @end itemize
##
## @var{M,N,...} can be passed as either numeric matrices or cell arrays
## of potential Mueller matrices.
##
## Note that this function does not check the physical integrity of
## the given matrices; to check that use mueller_checkmueller() instead.
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
## @seealso{mueller_checkmueller}
## @end deftypefn

function varargout = mueller_ismueller(varargin)

  if nargin==0
    print_usage();
    return;
  end

  % loop over parameters
  for vi=1:nargin

    M = varargin{vi};
    if iscell(M)
      ismueller = false(size(M));
      M_subs = cell(1,ndims(M));
      for mi=1:numel(M)
        [M_subs{:}] = ind2sub(size(M),mi);
        ismueller(M_subs{:}) = s_ismueller(M{M_subs{:}});
      end
    else
      ismueller = s_ismueller(M);
    end

    varargout{vi} = ismueller;

  end

end

% helper function
function isMueller = s_ismueller(M)
  if ~isnumeric(M)
    isMueller = false;
  elseif ~all(size(M)==[4,4])
    isMueller = false;
  else
    isMueller = true;
  end

end

%!test
%! % test type check
%! A1 = mueller_unity();
%! A2 = char(A1);
%! t1 = mueller_ismueller(A1);
%! t2 = mueller_ismueller(A2);
%! assert(t1 && ~t2);
%!
%!test
%! % test size check
%! A1 = mueller_unity();
%! A2 = A1;
%! A2(5,5) = 1;
%! t1 = mueller_ismueller(A1);
%! t2 = mueller_ismueller(A2);
%! assert(t1 && ~t2);
%!
%!test
%! % test size of return value
%! A1 = mueller_mirror([2,3,4]);
%! A1{2,2,2} = 0;
%! A2 = mueller_mirror([4,3,2]);
%! A2{1,1,1} = 0;
%! t1 = mueller_ismueller(A1);
%! t2 = mueller_ismueller(A2);
%! assert((size(A1)==size(t1)) && (size(A2)==size(t2)));
%!
%!test
%! % test indivial elements of return value
%! A1 = mueller_mirror([2,3,4]);
%! A1{2,2,2} = 0;
%! A2 = mueller_mirror([4,3,2]);
%! A2{1,1,1} = 0;
%! t1 = mueller_ismueller(A1);
%! t2 = mueller_ismueller(A2);
%! assert(t1(1,1,1) && ~t1(2,2,2) && ~t2(1,1,1) && t2(2,2,2));



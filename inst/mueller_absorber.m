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
## @deftypefn  {Function File} {@var{M} =} mueller_absorber()
## @deftypefnx {Function File} {@var{M} =} mueller_absorber(@var{p})
## Return Mueller matrices for a (partial) absorber.
##
## @itemize @minus
## @item @var{p} is the relative absorbance, ranging from 0 to 1,
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
## @seealso{mueller_lindiattenuator, mueller_circdiattenuator}
## @end deftypefn

function M = mueller_absorber(varargin)

  absorption_defv = 0;

  if nargin<1 
    absorption = absorption_defv;
  else
    absorption = varargin{1};
  end

  [absorption, was_cell] = __c2n__(absorption, absorption_defv);

  if (numel(absorption) > 1) || was_cell
     
    M = cell(size(absorption));
    M_subs = cell(1,ndims(M));
    for mi=1:numel(M)
      [M_subs{:}] = ind2sub(size(M),mi);
      M{M_subs{:}} = s_absorber(absorption(M_subs{:}));
    end
    
  else

    M = s_absorber(absorption);

  end

end

% helper function
function M = s_absorber(absorption)

  M = eye(4)*(1-absorption);

end

%!test
%! % test default return value
%! A = mueller_absorber();
%! R = A*A-A;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test serial appliation of absorptive elements
%! absorption = rand(1, 1);
%! A1 = mueller_absorber(absorption);
%! A2 = mueller_absorber(1-(1-absorption)^2);
%! R = A1*A1-A2;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % another test of serial appliation of absorptive elements
%! absorption1 = rand(1, 1);
%! absorption2 = rand(1, 1);
%! A1 = mueller_absorber(absorption1);
%! A2 = mueller_absorber(absorption2);
%! A12 = mueller_absorber(1-((1-absorption1)*(1-absorption2)));
%! R = A1*A2-A12;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test correct size of return values
%! for dim = 1:5
%!   asize = randi([1 4], 1, dim);
%!   R = rand(asize);
%!   if numel(R) == 1
%!     R = {R};
%!   end
%!   rsize = size(R);
%!   C = mueller_absorber(R);
%!   csize = size(C);
%!   assert(rsize == csize);
%! end


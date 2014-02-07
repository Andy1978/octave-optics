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
## @deftypefn  {Function File} {@var{V} =} jones_lpplus45()
## @deftypefnx {Function File} {@var{V} =} jones_lpplus45(@var{p})
## Return the Jones vector for light with linear polarization at +45 degrees. 
##
## @itemize @minus
## @item @var{p} is the amplitude of the electric field,
## if not given or set to [] the default value 1 is used.
## @end itemize
##
## Argument @var{p} can be passed as a scalar or as a matrix or as a
## cell array. In the two latter cases, a cell array @var{V} of 
## Jones vectors of the same size is returned.
##
## References:
##
## @enumerate
## @item E. Collett, Field Guide to Polarization, 
##       SPIE Field Guides vol. FG05, SPIE (2005). ISBN 0-8194-5868-6.
## @item R. A. Chipman, "Polarimetry," chapter 22 in Handbook of Optics II, 
##       2nd Ed, M. Bass, editor in chief (McGraw-Hill, New York, 1995)
## @item @url{http://en.wikipedia.org/wiki/Jones_calculus, "Jones calculus"}, 
##       last retrieved on Jan 13, 2014.
## @end enumerate
##
## @seealso{jones_lpminus45}
## @end deftypefn

function V = jones_lpplus45(varargin)

  amplitude_defv = 1;

  if nargin<1 
    amplitude = amplitude_defv;
  else
    amplitude = varargin{1};
  end

  [amplitude, was_cell] = __c2n__(amplitude, amplitude_defv);

  if (numel(amplitude) > 1) || was_cell
     
    V = cell(size(amplitude));
    V_subs = cell(1,ndims(V));
    for Vi=1:numel(V)
      [V_subs{:}] = ind2sub(size(V),Vi);
      V{V_subs{:}} = s_lpplus45(amplitude(V_subs{:}));
    end
    
  else

    V = s_lpplus45(amplitude);

  end

end

% helper function
function V = s_lpplus45(amplitude)

  V = [1;1]*amplitude;
  
end

%!test
%! % test default return value
%! V = jones_lpplus45();
%! R = V-[1;1];
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test return value
%! amplitude = rand(1, 1);
%! V = jones_lpplus45(amplitude);
%! R = V-[1;1]*amplitude;
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
%!   C = jones_lpplus45(R);
%!   csize = size(C);
%!   assert(rsize == csize);
%! end









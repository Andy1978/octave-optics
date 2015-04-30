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
## @deftypefn  {Function File} {@var{P} =} stokes_intensity(@var{V})
## @deftypefnx {Function File} {@var{[P,Q,...]} =} stokes_intensity(@var{V,W,...})
## Return intensity of light described by Stokes vectors.
##
## @itemize @minus
## @item @var{V,W,...} define (arrays of) Stokes vectors.
## The function returns their intensity values as numeric arrays
## @var{P,Q,...} of corresponding size.
## @end itemize
##
## @var{V,W,...} can be passed as either numeric vectors or cell arrays
## of Stokes vectors.
##
## References:
##
## @enumerate
## @item E. Collett, Field Guide to Polarization,
##       SPIE Field Guides vol. FG05, SPIE (2005). ISBN 0-8194-5868-6.
## @item R. A. Chipman, "Polarimetry," chapter 22 in Handbook of Optics II,
##       2nd Ed, M. Bass, editor in chief (McGraw-Hill, New York, 1995)
## @item @url{http://en.wikipedia.org/wiki/Stokes_parameters, "Stokes parameters"},
##       last retrieved on Dec 17, 2013.
## @end enumerate
##
## @seealso{stokes_isstokes, stokes_degpolarization}
## @end deftypefn

function varargout = stokes_intensity(varargin)

  if nargin==0
    print_usage();
    return;
  end

  % loop over parameters
  for ni=1:nargin

    V = varargin{ni};
    if iscell(V)
      intensity = zeros(size(V));
      V_subs = cell(1,ndims(V));
      for vi=1:numel(V)
        [V_subs{:}] = ind2sub(size(V),vi);
        intensity(V_subs{:}) = s_intensity(V{V_subs{:}});
      end
    else
      intensity = s_intensity(V);
    end

    varargout{ni} = intensity;

  end

end

% helper function
function intensity = s_intensity(V)

  intensity = V(1);

end

%!test
%! % test size and value of return values
%! r1 = rand(2,3,4);
%! V1 = stokes_unpolarized(r1);
%! r2 = rand(4,3,2);
%! V2 = stokes_unpolarized(r2);
%! i1 = stokes_intensity(V1);
%! i2 = stokes_intensity(V2);
%! assert(all(i1==r1) && all(i2==r2));
%!
%!test
%! % test size and value of return values
%! r1 = rand(2,3,4);
%! V1 = stokes_unpolarized(r1);
%! r2 = rand(1,1);
%! V2 = stokes_unpolarized(r2);
%! [i1,i2] = stokes_intensity(V1,V2);
%! assert(all(i1==r1) && all(i2==r2));

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
## @deftypefn  {Function File} {@var{P} =} stokes_degpolarization(@var{V})
## @deftypefnx {Function File} {@var{[P,Q,...]} =} stokes_degpolarization(@var{V,W,...})
## Return degree of polarization of light described by Stokes vectors.
##
## @itemize @minus
## @item @var{V,W,...} define (arrays of) Stokes vectors.
## The function returns their degrees of polarization as numeric arrays 
## @var{P,Q,...} of corresponding size.
## @end itemize
##
## @var{V,W,...} can be passed as either numeric vectors or cell arrays
## of potential Stokes vectors.
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
## @seealso{stokes_isstokes, stokes_intensity}
## @end deftypefn

function varargout = stokes_degpolarization(varargin)

  if nargin==0
    print_usage();
    return;
  end

  % loop over parameters
  for ni=1:nargin
      
    V = varargin{ni};
    if iscell(V)
      degpolarization = zeros(size(V));
      V_subs = cell(1,ndims(V));
      for vi=1:numel(V)
        [V_subs{:}] = ind2sub(size(V),vi);
        degpolarization(V_subs{:}) = s_degpolarization(V{V_subs{:}});
      end
    else
      degpolarization = s_degpolarization(V);
    end
    
    varargout{ni} = degpolarization;

  end

end

% helper function
function degpolarization = s_degpolarization(V)

  S13 = V(2:4);    
  degpolarization = sqrt(S13'*S13)/V(1);

end

%     t = stokes.degpolarization(stokes.unpolarized()+stokes.cpleft()) 
%     t = 0.5

%!test
%! % test size of return values
%! r1 = rand(2,3,4);
%! V1 = stokes_unpolarized(r1);
%! r2 = rand(4,3,2);
%! V2 = stokes_unpolarized(r2);
%! [d1,d2] = stokes_degpolarization(V1,V2);
%! assert((size(d1)==size(r1)) && size(size(d2)==size(r2))); 
%!
%!test
%! % test return values
%! r1 = rand(1,1);
%! V1 = stokes_cpleft(r1)+stokes_unpolarized(1-r1);
%! r2 = rand(1,1);
%! V2 = stokes_unpolarized(r2);
%! [d1,d2] = stokes_degpolarization(V1,V2);
%! assert((d1==r1) && (d2==0)); 

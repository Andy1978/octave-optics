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
## @deftypefn  {Function File} {@var{t} =} stokes_isstokes(@var{V})
## @deftypefnx {Function File} {@var{[t,u,...]} =} stokes_isstokes(@var{V,W,...})
## Check validity of Stokes vector or vectors. 
##
## @itemize @minus
## @item @var{V,W,...} define potential (arrays of) Stokes vectors.
## After checking the parameters for validity, the function returns
## boolean arrays @var{t,u,...} of corresponding size.
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
## @seealso{stokes_intensity, stokes_degpolarization}
## @end deftypefn

function varargout = stokes_isstokes(varargin)

  if nargin==0
    print_usage();
    return;
  end

  % loop over parameters
  for ni=1:nargin
      
    V = varargin{ni};
    if iscell(V)
      isstokes = false(size(V));
      V_subs = cell(1,ndims(V));
      for vi=1:numel(V)
        [V_subs{:}] = ind2sub(size(V),vi);
        isstokes(V_subs{:}) = s_isstokes(V{V_subs{:}});
      end
    else
      isstokes = s_isstokes(V);
    end
    
    varargout{ni} = isstokes;

  end

end

% helper function
function isstokes = s_isstokes(V)    

  if ~isnumeric(V)
    isstokes = false;
  elseif ~all(size(V)==[4,1])
    isstokes = false;
  else
    isstokes = true;
  end

end

%!test
%! % test type check
%! V1 = stokes_unpolarized();
%! V2 = char(V1);
%! t1 = stokes_isstokes(V1);
%! t2 = stokes_isstokes(V2);
%! assert(t1 && ~t2);
%!
%!test
%! % test size check
%! V1 = stokes_unpolarized();
%! V2 = V1;
%! V2(5,1) = 1;
%! t1 = stokes_isstokes(V1);
%! t2 = stokes_isstokes(V2);
%! assert(t1 && ~t2);
%!
%!test
%! % test size of return value
%! V1 = stokes_unpolarized(ones(2,3,4));
%! V1{2,2,2} = 0;
%! V2 = stokes_unpolarized(ones(4,3,2));
%! V2{1,1,1} = 0;
%! t1 = stokes_isstokes(V1);
%! t2 = stokes_isstokes(V2);
%! assert((size(t1)==size(V1)) && (size(t2)==size(V2))); 
%!
%!test
%! % test size of return value
%! V1 = stokes_unpolarized(ones(2,3,4));
%! V2 = stokes_unpolarized(1);
%! [t1,t2] = stokes_isstokes(V1,V2);
%! assert((size(t1)==size(V1)) && (size(t2)==[1,1])); 
%!
%!test
%! % test indivial elements of return value
%! V1 = stokes_unpolarized(ones(2,3,4));
%! V1{2,2,2} = 0;
%! V2 = stokes_unpolarized(ones(4,3,2));
%! V2{1,1,1} = 0;
%! t1 = stokes_isstokes(V1);
%! t2 = stokes_isstokes(V2);
%! assert(t1(1,1,1) && ~t1(2,2,2) && ~t2(1,1,1) && t2(2,2,2)); 


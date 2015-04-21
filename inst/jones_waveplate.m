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
## @deftypefn  {Function File} {@var{JM} = } jones_waveplate ()
## @deftypefnx {Function File} {@var{JM} = } jones_waveplate (@var{p})
## Return the Jones matrix for a linear wave plate with a phase 
## delay given in wavelength units and long axis rotation of 0 degrees. 
##
## @itemize @minus
## @item @var{p} is the phase delay in wavelength units, ranging from
## 0 to 1; if not given or set to [] the default value 0 is used.
## @end itemize
##
## Argument @var{p} can be passed as a scalar or as a matrix or as a
## cell array. In the two latter cases, a cell array @var{JM} of 
## Jones matrices of the same size is returned.
##
## References:
##
## @enumerate
## @item E. Collett, Field Guide to Polarization, 
##       SPIE Field Guides vol. FG05, SPIE (2005). ISBN 0-8194-5868-6.
## @item R. A. Chipman, "Polarimetry," chapter 22 in Handbook of Optics II, 
##       2nd Ed, M. Bass, editor in chief (McGraw-Hill, New York, 1995)
## @item @url{http://en.wikipedia.org/wiki/Jones_calculus, "Jones calculus"}, 
##       last retrieved on Jan 14, 2013.
## @end enumerate
##
## @seealso{jones_linretarder}
## @end deftypefn

function JM = jones_waveplate(varargin)

  pilu_defv = 0;

  if nargin<1 
    phase_in_lambda_units = pilu_defv;
  else
    phase_in_lambda_units = varargin{1};
  end

  phase_in_lambda_units = __c2n__(phase_in_lambda_units, pilu_defv);

  if numel(phase_in_lambda_units) > 1
     
    JM = cell(size(phase_in_lambda_units));
    JM_subs = cell(1,ndims(JM));
    for jmi=1:numel(JM)
      [JM_subs{:}] = ind2sub(size(JM),jmi);
      JM{JM_subs{:}} = s_waveplate(phase_in_lambda_units(JM_subs{:}));
    end
    
  else

    JM = s_waveplate(phase_in_lambda_units);
    
  end

end

% helper function
function JM = s_waveplate(phase_in_lambda_units)

  JM = zeros(2,2);
  JM(1,1) = 1;
  JM(2,2) = exp(-1i*phase_in_lambda_units*2*pi());

end

%!test
%! % test default return value
%! A = jones_waveplate();
%! R = A*A-A;
%! assert(norm(R,inf), 0, 1e-9);

%!test
%! % test serial application of absorptive elements
%! delay = rand(1, 1);
%! A1 = jones_waveplate(delay);
%! A2 = jones_waveplate(delay*2);
%! R = A1*A1-A2;
%! assert(norm(R,inf), 0, 1e-9);

%!test
%! % another test of serial application of absorptive elements
%! delay1 = rand(1, 1);
%! delay2 = rand(1, 1);
%! A1 = jones_waveplate(delay1);
%! A2 = jones_waveplate(delay2);
%! A12 = jones_waveplate(delay1+delay2);
%! R = A1*A2-A12;
%! assert(norm(R,inf), 0, 1e-9);

%!test
%! % test correct size of return values
%! for dim = 1:5
%!   asize = randi([1 4], 1, dim);
%!   R = rand(asize);
%!   if numel(R) == 1
%!     R = {R}
%!   end
%!   rsize = size(R);
%!   C = jones_waveplate(R);
%!   csize = size(C);
%!   assert(csize, rsize);
%! end

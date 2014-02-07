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
## @deftypefn  {Function File} {@var{JM} =} jones_linretarder()
## @deftypefnx {Function File} {@var{JM} =} jones_linretarder(@var{p})
## @deftypefnx {Function File} {@var{JM} =} jones_linretarder(..., @var{mode})
## Return the Jones matrix for a linear retarder with long axis
## rotation of 0 degrees. 
##
## @itemize @minus
## @item @var{p} is the phase delay in radiant units, i.e. @var{p} is 
## ranging between 0 and 2*pi(). If not given or set to [] the default
## value 0 is used.
## @item @var{mode} is a string defining the units for the phase
## delay: 'radiant' (default), 'degree' (0..360) or 'wavelength'
## (0..1).
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
##       last retrieved on Jan 13, 2014.
## @end enumerate
##
## @seealso{Jones_waveplate}
## @end deftypefn

function JM = jones_linretarder(varargin)

  phase_defv = 0;

  if nargin<1 
    phase = phase_defv;
  else
    phase = varargin{1};
  end

  [phase, was_cell] = __c2n__(phase, phase_defv);

  if nargin>=2 && ischar(varargin{end})
    if strncmpi(varargin{end},'deg',3)
      phase = phase*pi()/180.0;
    elseif strncmpi(varargin{end},'wav',3)
      phase = phase*2*pi();
    end
  end
  
  if (numel(phase) > 1) || was_cell
     
    JM = cell(size(phase));
    JM_subs = cell(1,ndims(JM));
    for jmi=1:numel(JM)
      [JM_subs{:}] = ind2sub(size(JM),jmi);
      JM{JM_subs{:}} = s_linretarder(phase(JM_subs{:}));
    end
    
  else

    JM = s_linretarder(phase);

  end

end

% helper function
function JM = s_linretarder(phase_in_pi_units)

  JM = zeros(2,2);
  JM(1,1) = 1;
  JM(2,2) = exp(-1i*phase_in_pi_units);

end

%!test
%! % test default return value
%! A = jones_linretarder();
%! R = A*A-A;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test serial application of linear retarder elements
%! phase = rand(1, 1);
%! A1 = jones_linretarder(phase);
%! A2 = jones_linretarder(phase*2);
%! R = A1*A1-A2;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % another test of serial application of retarder elements
%! phase1 = rand(1, 1);
%! phase2 = rand(1, 1);
%! A1 = jones_linretarder(phase1);
%! A2 = jones_linretarder(phase2);
%! A12 = jones_linretarder(phase1+phase2);
%! R = A1*A2-A12;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test mode
%! phase = rand(1, 1);
%! A1 = jones_linretarder(phase);
%! A2 = jones_linretarder(phase*180/pi(), 'deg');
%! A3 = jones_linretarder(phase/(2*pi()), 'wav');
%! R1 = A1-A2;
%! R2 = A1-A3;
%! assert(norm(R1,inf)+norm(R2,inf), 0, 1e-9);
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
%!   C = jones_linretarder(R);
%!   csize = size(C);
%!   assert(rsize == csize);
%! end

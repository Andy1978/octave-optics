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
## @deftypefn  {Function File} {@var{JM} =} jones_rotator()
## @deftypefnx {Function File} {@var{JM} =} jones_rotator(@var{p})
## @deftypefnx {Function File} {@var{JM} =} jones_rotator(..., @var{mode})
## Return the Jones matrix for a system rotator.
##
## @itemize @minus
## @item @var{p} is the rotation angle, ranging from 0 to 2*pi,
## if not given or set to [] the default value 0 is used.
## @item @var{mode} is a string defining the units for the angle:
## 'radiant' (default) or 'degree' (0..360)
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
## @seealso{jones_rotate}
## @end deftypefn

function JM = jones_rotator(varargin)

  angle_defv = 0;

  if nargin<1
    angle = angle_defv;
  else
    angle = varargin{1};
  end

  [angle, was_cell] = __c2n__(angle, angle_defv);

  if nargin>=2 && ischar(varargin{end})
    if strncmpi(varargin{end},'deg',3)
      angle = angle*pi()/180.0;
    end
  end

  if (numel(angle) > 1) || was_cell

    JM = cell(size(angle));
    JM_subs = cell(1,ndims(JM));
    for jmi=1:numel(JM)
      [JM_subs{:}] = ind2sub(size(JM),jmi);
      JM{JM_subs{:}} = s_rotator(angle(JM_subs{:}));
    end

  else

    JM = s_rotator(angle);

  end

end

% helper function
function JM = s_rotator(angle_in_radiants)

  JM = zeros(2,2);

  JM(1,1) = cos(angle_in_radiants);
  JM(1,2) = sin(angle_in_radiants);
  JM(2,1) = -sin(angle_in_radiants);
  JM(2,2) = cos(angle_in_radiants);

end

%!test
%! % test default return value
%! A = jones_rotator();
%! R = A*A-A;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test serial application of rotator
%! angle = rand(1, 1);
%! A1 = jones_rotator(angle);
%! A2 = jones_rotator(angle*2);
%! R = A1*A1-A2;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % another test of serial application of rotator
%! angle1 = rand(1, 1);
%! angle2 = rand(1, 1);
%! A1 = jones_rotator(angle1);
%! A2 = jones_rotator(angle2);
%! A12 = jones_rotator(angle1+angle2);
%! R = A1*A2-A12;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test different angle value interpretations
%! angle = rand(1, 1);
%! A1 = jones_rotator(angle);
%! A2 = jones_rotator(-angle*180/pi(), 'deg');
%! R = A2*A1-jones_unity();
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test size of return values
%! for dim = 1:5
%!   asize = randi([1 4], 1, dim);
%!   R = rand(asize);
%!   if numel(R) == 1
%!     R = {R};
%!   end
%!   rsize = size(R);
%!   C = jones_rotator(R);
%!   csize = size(C);
%!   assert(rsize == csize);
%! end


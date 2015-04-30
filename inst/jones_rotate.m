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
## @deftypefn  {Function File} {@var{JM} =} jones_rotate()
## @deftypefnx {Function File} {@var{JM} =} jones_rotate(@var{M}, @var{p})
## @deftypefnx {Function File} {@var{JM} =} jones_rotate(..., @var{mode})
## Return the Jones matrix for rotated Jones elements.
##
## @itemize @minus
## @item @var{M} is the Jones matrix for the unrotated elements.
## Default value is the Jones unity matrix.
## @item @var{p} is the rotation angle, default value is 0.
## @item @var{mode} is a string defining the interpretation of the
## angle value: 'radiants' (default) or 'degree'.
## @end itemize
##
## Argument @var{M} can be passed as numeric matrix or as a cell
## array. Argument @var{p} can be passed as a numeric scalar or as a
## cell array. In the case of at least one cell array provided,
## a cell array @var{M} of Jones matrices is returned. The size of
## @var{M} in each dimension is set to the maximum of the size of
## the passed cell arrays.
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
## @seealso{jones_rotator}
## @end deftypefn

function JM = jones_rotate(varargin)

  angle_defv = 0;

  if nargin<1
    JM = jones_unity();
    return;
  elseif nargin<2
    JM = varargin{1};
    return;
  else
    C = varargin{1};
    angle = varargin{2};
  end

  [angle, angle_was_cell] = __c2n__(angle, angle_defv);

  if nargin>=3 && ischar(varargin{end})
    if strncmpi(varargin{end},'deg',3)
      angle = angle*pi()/180.0;
    end
  end

  if iscell(C) || (numel(angle) > 1) || angle_was_cell

    if ~iscell(C)
      C = {C};
    end

    % adjust dimensions, i.e. fill missing dimensions with 1
    sizeC = size(C);
    sizeangle = size(angle);
    maxdim = max(length(sizeC),length(sizeangle));
    if length(sizeC) < maxdim
      sizeC = [sizeC, ones(1,maxdim-length(sizeC))];
    end
    if length(sizeangle) < maxdim
      sizeangle = [sizeangle, ones(1,maxdim-length(sizeangle))];
    end

    % generate Jones matrices
    maxsize = max([sizeC;sizeangle]);
    JM = cell(maxsize);
    JM_subs = cell(1,ndims(JM));
    numelJM = numel(JM);

    % flatten C and angle arrays
    C = C(:);
    angle = angle(:);
    numelC = numel(C);
    numelangle = numel(angle);

    for jmi=1:numelJM
      [JM_subs{:}] = ind2sub(size(JM),jmi);
      JM{JM_subs{:}} = s_rotate(C{mod(jmi-1,numelC)+1}, angle(mod(jmi-1,numelangle)+1));
    end

  else

    JM = s_rotate(C, angle(1));

  end

end

% helper function
function JM = s_rotate(JM, angle_in_radiants)

  JM = s_rotator(-angle_in_radiants)*JM*s_rotator(angle_in_radiants);

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
%! % default return value: unity matrix
%! A = jones_rotate();
%! R = A*A-A;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % rotation by 0 should do nothing
%! delay = rand(1,1);
%! JM = jones_linretarder(delay);
%! A = jones_rotate(JM, 0);
%! R = JM-A;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % undo rotation by 2nd opposite rotation
%! delay = rand(1,1);
%! angle = rand(1, 1);
%! JM = jones_linretarder(delay);
%! A1 = jones_rotate(JM, angle);
%! A2 = jones_rotate(A1, -angle);
%! R = A2-JM;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test serial application of rotation
%! delay = rand(1,1);
%! angle1 = rand(1, 1);
%! angle2 = rand(1, 1);
%! JM = jones_linretarder(delay);
%! A1 = jones_rotate(JM, angle1);
%! A2 = jones_rotate(A1, angle2);
%! A12 = jones_rotate(JM, angle1+angle2);
%! R = A2-A12;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % testing MODE parameter
%! angle = rand(1, 1);
%! A1 = jones_rotate(jones_waveplate(0.5), angle, 'rad');
%! A2 = jones_rotate(jones_waveplate(0.5), angle*180/pi(), 'deg');
%! R = A2-A1;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % size of return value determined by 1st argument
%! angle = rand(1,1);
%! for dim = 1:5
%!   asize = randi([1 4], 1, dim);
%!   rsize = size(rand(asize));
%!   C = jones_rotate(jones_unity(rsize), angle);
%!   csize = size(C);
%!   assert(rsize == csize);
%! end
%!
%!test
%! % size if return value determined by 2nd argument
%! for dim = 1:5
%!   asize = randi([1 4], 1, dim);
%!   R = rand(asize);
%!   if numel(R) == 1
%!     R = {R};
%!   end
%!   rsize = size(R);
%!   C = jones_rotate(jones_unity(), R);
%!   csize = size(C);
%!   assert(rsize == csize);
%! end
%!
%!test
%! % size if return value determined by both argument
%! JM = jones_unity([4,3,2]);
%! angle = rand(2,3,4);
%! C = jones_rotate(JM, angle);
%! csize = size(C);
%! assert(csize == [4,3,4]);
%!

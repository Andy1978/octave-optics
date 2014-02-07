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
## @deftypefn  {Function File} {@var{M} =} mueller_rotate()
## @deftypefnx {Function File} {@var{M} =} mueller_rotate(@var{M}, @var{p})
## @deftypefnx {Function File} {@var{M} =} mueller_rotate(..., @var{mode})
## Return the Mueller matrix for rotated Mueller elements.
##
## @itemize @minus
## @item @var{M} is the Mueller matrix for the unrotated elements.
## Default value is the Mueller unity matrix.
## @item @var{p} is the rotation angle, default value is 0.
## @item @var{mode} is a string defining the interpretation of the
## angle value: 'radiants' (default) or 'degree'.
## @end itemize
##
## Argument @var{M} can be passed as numeric matrix or as a cell
## array. Argument @var{p} can be passed as a numeric scalar or as a
## cell array. In the case of at least one cell array provided,
## a cell array @var{M} of Mueller matrices is returned. The size of
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
## @item @url{http://en.wikipedia.org/wiki/Mueller_calculus, "Mueller calculus"}, 
##       last retrieved on Dec 17, 2013.
## @end enumerate
##
## @seealso{mueller_rotator}
## @end deftypefn

function M = mueller_rotate(varargin)

  angle_defv = 0;

  if nargin<1
    M = mueller_unity();
    return;
  elseif nargin<2
    M = varargin{1};
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
    
    % generate Mueller matrices
    maxsize = max([sizeC;sizeangle]);
    M = cell(maxsize);
    M_subs = cell(1,ndims(M));
    numelM = numel(M);
    
    % flatten C and angle arrays
    C = C(:);
    angle = angle(:);
    numelC = numel(C);
    numelangle = numel(angle);
    
    for mi=1:numelM
      [M_subs{:}] = ind2sub(size(M),mi);
      M{M_subs{:}} = s_rotate(C{mod(mi-1,numelC)+1}, angle(mod(mi-1,numelangle)+1));
    end
    
  else
      
    M = s_rotate(C, angle(1));

  end

end

% helper function
function M = s_rotate(M, angle_in_radiants)

  M = s_rotator(-angle_in_radiants)*M*s_rotator(angle_in_radiants);

end

% helper function
function M = s_rotator(angle_in_radiants)

  M = zeros(4,4);

  % short cut to avoid "*2" in each line
  angle_in_radiants = angle_in_radiants*2;

  M(1,1) = 1;
  M(2,2) = cos(angle_in_radiants);
  M(2,3) = sin(angle_in_radiants);
  M(3,2) = -sin(angle_in_radiants);
  M(3,3) = cos(angle_in_radiants);
  M(4,4) = 1;

end

%!test
%! % default return value: unity matrix
%! A = mueller_rotate();
%! R = A*A-A;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % rotation by 0 should do nothing
%! delay = rand(1,1);
%! M = mueller_linretarder(delay);
%! A = mueller_rotate(M, 0);
%! R = M-A;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % undo rotation by 2nd opposite rotation
%! delay = rand(1,1);
%! angle = rand(1, 1);
%! M = mueller_linretarder(delay);
%! A1 = mueller_rotate(M, angle);
%! A2 = mueller_rotate(A1, -angle);
%! R = A2-M;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test serial application of rotation
%! delay = rand(1,1);
%! angle1 = rand(1, 1);
%! angle2 = rand(1, 1);
%! M = mueller_linretarder(delay);
%! A1 = mueller_rotate(M, angle1);
%! A2 = mueller_rotate(A1, angle2);
%! A12 = mueller_rotate(M, angle1+angle2);
%! R = A2-A12;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % testing MODE parameter
%! angle = rand(1, 1);
%! A1 = mueller_rotate(mueller_waveplate(0.5), angle, 'rad');
%! A2 = mueller_rotate(mueller_waveplate(0.5), angle*180/pi(), 'deg');
%! R = A2-A1;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % size of return value determined by 1st argument
%! angle = rand(1,1);
%! for dim = 1:5
%!   asize = randi([1 4], 1, dim);
%!   rsize = size(rand(asize));
%!   C = mueller_rotate(mueller_unity(rsize), angle);
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
%!   C = mueller_rotate(mueller_unity(), R);
%!   csize = size(C);
%!   assert(rsize == csize);
%! end
%!
%!test
%! % size if return value determined by both argument
%! M = mueller_unity([4,3,2]);
%! angle = rand(2,3,4);
%! C = mueller_rotate(M, angle);
%! csize = size(C);
%! assert(csize == [4,3,4]);
%!

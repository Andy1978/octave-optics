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
## @deftypefn  {Function File} {@var{M} =} mueller_lindiattenuator()
## @deftypefnx {Function File} {@var{M} =} mueller_lindiattenuator(@var{d})
## @deftypefnx {Function File} {@var{M} =} mueller_lindiattenuator(@var{px},@var{py})
## @deftypefnx {Function File} {@var{M} =} mueller_lindiattenuator(..., @var{mode})
## Return the Mueller matrix for a linear diattenuator at zero
## rotation.
##
## @itemize @minus
## @item @var{d} is the diattenuation of the element, i.e.
## @code{d=(px-py)/(px+py)}. Reversibly, transmission in y direction
## is @code{(1-d)/(1+d)}, if transmission in x direction is 1.
## @item @var{px} is the transmittance in x direction.
## @item @var{py} is the transmittance in y direction.
## @item @var{mode} is a string defining the interpretation of 
## transmittance values: 'intensity' (default) or 'amplitude'. 
## @end itemize
##
## Arguments @var{d}, @var{px} or @var{py} can be passed as a scalar
## or as a matrix or as a cell array. In the two latter cases, a cell 
## array @var{M} of Mueller matrices is returned. The size of @var{M}
## is set to the maximum of the parameters' size.
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
## @seealso{mueller_circdiattenuator, mueller_absorber}
## @end deftypefn

function M = mueller_lindiattenuator(varargin)

  if nargin<1 

    px = 1;
    py = 1;
    was_cell = false;

  elseif nargin==1

    px = varargin{1};
    [px, was_cell] = __c2n__(px, 0);
    py = (1-px)./(1+px);
    px(:) = 1;
    
  else

    px = varargin{1};
    [px, was_cellx] = __c2n__(px, 1);

    py = varargin{2};
    [py, was_celly] = __c2n__(py, 1);

    was_cell = was_cellx || was_celly;

  end

  % check mode    
  s_function = @s_lindiattenuator_int;
  if nargin>=2 && ischar(varargin{end})
    if strncmpi(varargin{end},'amp',3)
      s_function = @s_lindiattenuator_amp;
    end
  end

  % any matrix in parameters?
  if (any([numel(px),numel(py)] > 1)) || was_cell
     
    % adjust dimensions, i.e. fill missing dimensions with 1
    spx = size(px);
    spy = size(py);
    
    maxdim = max([length(spx),length(spy)]);
    if length(spx) < maxdim
      spx = [spx, ones(1,maxdim-length(spx))];
    end
    if length(spy) < maxdim
      spy = [spy, ones(1,maxdim-length(spy))];
    end

    % generate Mueller matrices
    maxsize = max([spx;spy]);
    M = cell(maxsize);
    M_subs = cell(1,ndims(M));
    numelM = numel(M);
    
    % flatten parameter arrays
    px = px(:);
    py = py(:);
    numelpx = numel(px);
    numelpy = numel(py);

    for mi=1:numelM
      [M_subs{:}] = ind2sub(size(M),mi);
      M{M_subs{:}} = s_function(px(mod(mi-1,numelpx)+1), py(mod(mi-1,numelpy)+1));
    end
    
  else

    M = s_function(px, py);

  end

end

% helper function
function M = s_lindiattenuator_amp(px_in_amplitude_domain,py_in_amplitude_domain)

  M = zeros(4,4);

  M(1,1) = (px_in_amplitude_domain^2+py_in_amplitude_domain^2)/2;
  M(1,2) = (px_in_amplitude_domain^2-py_in_amplitude_domain^2)/2;
  M(2,1) = M(1,2);
  M(2,2) = M(1,1);
  M(3,3) = px_in_amplitude_domain*py_in_amplitude_domain;
  M(4,4) = M(3,3);

end

% helper function 2
function M = s_lindiattenuator_int(kx_in_intensity_domain,ky_in_intensity_domain)

  M = zeros(4,4);

  M(1,1) = (kx_in_intensity_domain+ky_in_intensity_domain)/2;
  M(1,2) = (kx_in_intensity_domain-ky_in_intensity_domain)/2;
  M(2,1) = M(1,2);
  M(2,2) = M(1,1);
  M(3,3) = sqrt(kx_in_intensity_domain*ky_in_intensity_domain);
  M(4,4) = M(3,3);

end

%!test
%! % test default return value
%! A = mueller_lindiattenuator();
%! R = A*A-A;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test equality of providing diattenuation or kx and ky
%! d = rand(1, 1);
%! kx = 1;
%! ky = (1-d)./(1+d);
%! A1 = mueller_lindiattenuator(d);
%! A2 = mueller_lindiattenuator(kx, ky);
%! R = A1-A2;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test serial application of linear diattenuators
%! kx = rand(1, 1);
%! ky = rand(1, 1);
%! A1 = mueller_lindiattenuator(kx,ky);
%! A2 = mueller_lindiattenuator(kx*kx,ky*ky);
%! R = A1*A1-A2;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % another test of serial application of retarder elements
%! kx1 = rand(1, 1);
%! kx2 = rand(1, 1);
%! ky1 = rand(1, 1);
%! ky2 = rand(1, 1);
%! A1 = mueller_lindiattenuator(kx1,ky1);
%! A2 = mueller_lindiattenuator(kx2,ky2);
%! A12 = mueller_lindiattenuator(kx1*kx2,ky1*ky2);
%! R = A1*A2-A12;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test mode
%! kx = rand(1, 1);
%! ky = rand(1, 1);
%! A1 = mueller_lindiattenuator(kx,ky);
%! A2 = mueller_lindiattenuator(kx,ky,'int');
%! A3 = mueller_lindiattenuator(sqrt(kx),sqrt(ky),'amp');
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
%!   C = mueller_lindiattenuator(R);
%!   csize = size(C);
%!   assert(rsize == csize);
%! end
%!
%!test
%! % another test correct size of return values
%! kx = rand(3,4,5);
%! ky = rand(5,4,3);
%! C = mueller_lindiattenuator(kx,ky);
%! csize = size(C);
%! assert(csize == [5,4,5]);




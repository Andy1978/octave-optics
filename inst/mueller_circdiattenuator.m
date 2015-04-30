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
## @deftypefn  {Function File} {@var{M} =} mueller_circdiattenuator()
## @deftypefnx {Function File} {@var{M} =} mueller_circdiattenuator(@var{d})
## @deftypefnx {Function File} {@var{M} =} mueller_circdiattenuator(@var{pl},@var{pr})
## @deftypefnx {Function File} {@var{M} =} mueller_circdiattenuator(..., @var{mode})
## Return the Mueller matrix for a linear diattenuator at zero
## rotation.
##
## @itemize @minus
## @item @var{d} is the diattenuation of the element, i.e.
## @code{d=(px-py)/(px+py)}. Reversibly, transmission in y direction
## is @code{(1-d)/(1+d)}, if transmission in x direction is 1.
## @item @var{pl} is the transmittance in x direction.
## @item @var{pr} is the transmittance in y direction.
## @item @var{mode} is a string defining the interpretation of
## transmittance values: 'intensity' (default) or 'amplitude'.
## @end itemize
##
## Arguments @var{d}, @var{pl} or @var{pr} can be passed as a scalar
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
## @seealso{mueller_lindiattenuator, mueller_absorber}
## @end deftypefn

function M = mueller_circdiattenuator(varargin)

  if nargin<1

    pr = 1;
    pl = 1;
    was_cell = false;

  elseif nargin==1

    pr = varargin{1};
    [pr, was_cell] = __c2n__(pr, 0);
    pl = (1-pr)./(1+pr);
    pr(:) = 1;

  else

    pr = varargin{1};
    [pr, was_cellr] = __c2n__(pr, 1);

    pl = varargin{2};
    [pl, was_celll] = __c2n__(pl, 1);

    was_cell = was_cellr || was_celll;

  end

  % check mode
  s_function = @s_circdiattenuator_int;
  if nargin>=2 && ischar(varargin{end})
    if strncmpi(varargin{end},'amp',3)
      s_function = @s_circdiattenuator_amp;
    end
  end

  % any matrix in parameters?
  if (any([numel(pr),numel(pl)] > 1)) || was_cell

    % adjust dimensions, i.e. fill missing dimensions with 1
    spr = size(pr);
    spl = size(pl);

    maxdim = max([length(spr),length(spl)]);
    if length(spr) < maxdim
      spr = [spr, ones(1,maxdim-length(spr))];
    end
    if length(spl) < maxdim
      spl = [spl, ones(1,maxdim-length(spl))];
    end

    % generate Mueller matrices
    maxsize = max([spr;spl]);
    M = cell(maxsize);
    M_subs = cell(1,ndims(M));
    numelM = numel(M);

    % flatten parameter arrays
    pr = pr(:);
    pl = pl(:);
    numelpr = numel(pr);
    numelpl = numel(pl);

    for mi=1:numelM
      [M_subs{:}] = ind2sub(size(M),mi);
      M{M_subs{:}} = s_function(pr(mod(mi-1,numelpr)+1), pl(mod(mi-1,numelpl)+1));
    end

  else

    M = s_function(pr, pl);

  end

end

% helper function
function M = s_circdiattenuator_amp(pr_in_amplitude_domain,pl_in_amplitude_domain)

  M = zeros(4,4);

  M(1,1) = (pr_in_amplitude_domain^2+pl_in_amplitude_domain^2)/2;
  M(1,4) = (pr_in_amplitude_domain^2-pl_in_amplitude_domain^2)/2;
  M(2,2) = pr_in_amplitude_domain*pl_in_amplitude_domain;
  M(3,3) = M(2,2);
  M(4,1) = M(1,4);
  M(4,4) = M(1,1);

end

% helper function 2
function M = s_circdiattenuator_int(kr_in_intensity_domain,kl_in_intensity_domain)

  M = zeros(4,4);

  M(1,1) = (kr_in_intensity_domain+kl_in_intensity_domain)/2;
  M(1,4) = (kr_in_intensity_domain-kl_in_intensity_domain)/2;
  M(2,2) = sqrt(kr_in_intensity_domain*kl_in_intensity_domain);
  M(3,3) = M(2,2);
  M(4,1) = M(1,4);
  M(4,4) = M(1,1);

end

%!test
%! % test default return value
%! A = mueller_circdiattenuator();
%! R = A*A-A;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test equality of providing diattenuation or kx and ky
%! d = rand(1, 1);
%! kr = 1;
%! kl = (1-d)./(1+d);
%! A1 = mueller_circdiattenuator(d);
%! A2 = mueller_circdiattenuator(kr, kl);
%! R = A1-A2;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test serial application of circular diattenuators
%! kr = rand(1, 1);
%! kl = rand(1, 1);
%! A1 = mueller_circdiattenuator(kr,kl);
%! A2 = mueller_circdiattenuator(kr*kr,kl*kl);
%! R = A1*A1-A2;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % another test of serial application of retarder elements
%! kr1 = rand(1, 1);
%! kr2 = rand(1, 1);
%! kl1 = rand(1, 1);
%! kl2 = rand(1, 1);
%! A1 = mueller_circdiattenuator(kr1,kl1);
%! A2 = mueller_circdiattenuator(kr2,kl2);
%! A12 = mueller_circdiattenuator(kr1*kr2,kl1*kl2);
%! R = A1*A2-A12;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test mode
%! kr = rand(1, 1);
%! kl = rand(1, 1);
%! A1 = mueller_circdiattenuator(kr,kl);
%! A2 = mueller_circdiattenuator(kr,kl,'int');
%! A3 = mueller_circdiattenuator(sqrt(kr),sqrt(kl),'amp');
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
%!   C = mueller_circdiattenuator(R);
%!   csize = size(C);
%!   assert(rsize == csize);
%! end
%!
%!test
%! % another test correct size of return values
%! kr = rand(3,4,5);
%! kl = rand(5,4,3);
%! C = mueller_circdiattenuator(kr,kl);
%! csize = size(C);
%! assert(csize == [5,4,5]);

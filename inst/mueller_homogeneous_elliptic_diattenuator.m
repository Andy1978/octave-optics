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
## @deftypefn  {Function File} {@var{M} =} mueller_homogeneous_elliptic_diattenuator()
## @deftypefnx {Function File} {@var{M} =} mueller_homogeneous_elliptic_diattenuator(@var{t0}, @var{d}, @var{azimuth}, @var{ellipticity})
## @deftypefnx {Function File} {@var{M} =} mueller_homogeneous_elliptic_diattenuator(..., @var{azimuthmode})
## Return the Mueller matrix for a homogeneous elliptic diattenuator (see
## references).
##
## @itemize @minus
## @item @var{t0} is the total transmission (default: 1).
## @item @var{d} is the diattenuation value (default: 0).
## @item @var{azimuth} and @var{ellipticity} (default: 0) describe the
##       two orthogonal polarization eigenstates.
## @item @var{azimuthmode} is a string defining the interpretation of 
##       the azimuth angle: 'radiants' (default) or 'degree'.
## @end itemize
##
## Arguments @var{t0}, @var{d}, @var{azimuth}, or
## @var{ellipticity} can be passed as a scalar
## or as a matrix or as a cell array. In the two latter cases, a cell 
## array @var{M} of Mueller matrices is returned. The size of @var{M}
## is given by @code{max(size(t0),size(d),size(azimuth),size(ellipticity))}
## and elements of smaller matrices of @var{t0}, @var{d},
## @var{azimuth} or @var{ellipticity} are used in a loop-over manner.
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
## @item Boulvert et al., "Decomposition algorithm of an experimental
##       Mueller matrix", Opt.Comm. 282(2009):692-704
## @end enumerate
##
## @seealso{mueller_homogeneous_elliptic_retarder}
## @end deftypefn

function M = mueller_homogeneous_elliptic_diattenuator(varargin)

  % TODO: check ref [3] in [4] for decomposition in homogeneous elliptic
  % retarder und retarder 

  switch(nargin)
    case 0
      t0 = 1;
      d = 0;
      azimuth = 0;
      ellipticity = 0;
      was_cell = false;

    case 1
      [t0, was_cell] = __c2n__(varargin{1}, 1);
      d = 0;
      azimuth = 0;
      ellipticity = 0;

    case 2
      [t0, was_cell_t0] = __c2n__(varargin{1}, 1);
      [d, was_cell_d] = __c2n__(varargin{2}, 0);
      azimuth = 0;
      ellipticity = 0;
      was_cell = was_cell_t0 || was_cell_d;

    case 3
      [t0, was_cell_t0] = __c2n__(varargin{1}, 1);
      [d, was_cell_d] = __c2n__(varargin{2}, 0);
      [azimuth, was_cell_azimuth] = __c2n__(varargin{3}, 0);
      ellipticity = 0;
      was_cell = was_cell_t0 || was_cell_d || was_cell_azimuth;

    otherwise
      [t0, was_cell_t0] = __c2n__(varargin{1}, 1);
      [d, was_cell_d] = __c2n__(varargin{2}, 0);
      [azimuth, was_cell_azimuth] = __c2n__(varargin{3}, 0);
      % check special case of homogeneous_elliptic_diattenuator(t0,d,a,'degree')
      if ischar(varargin{4})
        ellipticity = 0;
	was_cell_ellipticity = false;
      else
        [ellipticity, was_cell_ellipticity] = __c2n__(varargin{4}, 0);
      end
      was_cell = was_cell_t0 || was_cell_d || was_cell_azimuth || was_cell_ellipticity;

  end

  % convert azimuth angle if necessary
  if nargin>=4 && ischar(varargin{end})
    if strncmpi(varargin{end},'deg',3)
      azimuth = azimuth*pi()/180.0;
    end
  end

  % any matrix in parameters?
  if (any([numel(t0),numel(d),numel(azimuth),numel(ellipticity)] > 1)) ...
     || was_cell

    % adjust dimensions, i.e. fill missing dimensions with 1
    st0 = size(t0);
    sd = size(d);
    sazimuth = size(azimuth);
    sellipticity = size(ellipticity);
    
    maxdim = max([length(st0),length(sd),length(sazimuth),length(sellipticity)]);
    if length(st0) < maxdim
      st0 = [st0, ones(1,maxdim-length(st0))];
    end
    if length(sd) < maxdim
      sd = [sd, ones(1,maxdim-length(sd))];
    end
    if length(sazimuth) < maxdim
      sazimuth = [sazimuth, ones(1,maxdim-length(sazimuth))];
    end
    if length(sellipticity) < maxdim
      sellipticity = [sellipticity, ones(1,maxdim-length(sellipticity))];
    end
    
    % generate Mueller matrices
    maxsize = max([st0;sd;sazimuth;sellipticity]);
    M = cell(maxsize);
    M_subs = cell(1,ndims(M));
    numelM = numel(M);
    
    % flatten parameter arrays
    t0 = t0(:);
    d = d(:);
    azimuth = azimuth(:);
    ellipticity = ellipticity(:);
    numelt0 = numel(t0);
    numeld = numel(d);
    numelazimuth = numel(azimuth);
    numelellipticity = numel(ellipticity);
    
    for mi=1:numelM
      [M_subs{:}] = ind2sub(size(M),mi);
      M{M_subs{:}} = s_homogenenous_elliptic_diattenuator(t0(mod(mi-1,numelt0)+1),...
							  d(mod(mi-1,numeld)+1),...
							  azimuth(mod(mi-1,numelazimuth)+1), ...
							  ellipticity(mod(mi-1,numelellipticity)+1));
    end
    
  else

    % generate Mueller matrix
    M = s_homogenenous_elliptic_diattenuator(t0,d,azimuth,ellipticity);
    
  end

end

% helper function
function M = s_homogenenous_elliptic_diattenuator(t0,d,azimuth,ellipticity)
  M = zeros(4,4);

  a = cos(2*ellipticity)*cos(2*azimuth);
  b = cos(2*ellipticity)*sin(2*azimuth);
  c = sin(2*ellipticity);

  M(1,1) = 1;
  M(1,2) = a*d;
  M(1,3) = b*d;
  M(1,4) = c*d;
  M(2,1) = M(1,2);
  M(2,2) = sqrt(1-d^2)+a^2*(1-sqrt(1-d^2));
  M(2,3) = a*b*(1-sqrt(1-d^2));
  M(2,4) = a*c*(1-sqrt(1-d^2));
  M(3,1) = M(1,3);
  M(3,2) = M(2,3);
  M(3,3) = sqrt(1-d^2)+b^2*(1-sqrt(1-d^2));
  M(3,4) = b*c*(1-sqrt(1-d^2));
  M(4,1) = M(1,4);
  M(4,2) = M(2,4);
  M(4,3) = M(3,4);
  M(4,4) = sqrt(1-d^2)+c^2*(1-sqrt(1-d^2));

  M = M*t0;

end

%!test
%! % test default return value
%! A = mueller_homogeneous_elliptic_diattenuator();
%! R = A*A-A;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % test modes
%! t0 = rand(1,1);
%! d = rand(1,1);
%! azimuth = rand(1,1);
%! ellipticity = rand(1,1);
%! A1 = mueller_homogeneous_elliptic_diattenuator(t0,d,azimuth,ellipticity);
%! A2 = mueller_homogeneous_elliptic_diattenuator(t0,d,azimuth*180/pi(),ellipticity,'deg');
%! R = (A2-A1);
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % another test correct size of return values
%! t0 = rand(3,4,5);
%! d = rand(4,5,6);
%! azimuth = rand(5,4,3);
%! ellipticity = rand(6,5,4);
%! C = mueller_homogeneous_elliptic_diattenuator(t0,d,azimuth,ellipticity);
%! csize = size(C);
%! assert(csize == [6,5,6]);

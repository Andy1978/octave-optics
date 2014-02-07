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
## @deftypefn  {Function File} {@var{M} =} jones(@var{M})
## @deftypefnx {Function File} {@var{A} =} jones(@var{M,N,...})
## Multiply Jones matrices and vectors. 
##
## @itemize @minus
## @item @var{M,N,...} define Jones matrices or 
## vectors. The function will multiply these from left to right and
## return the result.
## @end itemize
##
## @var{M,N,...} can be passed as either numeric matrices/vectors or
## cell arrays. In this case, the multiplication is carried out in a
## ".*" manner.
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
## @seealso{}
## @end deftypefn

function A = jones(varargin)

  if nargin<1
    print_usage();
    return;
  end

  A = varargin{1};

  for vi=2:nargin
    A = __cellfunc__(@(M1,M2)(M1*M2), A, varargin{vi});
  end

end

%!test
%! % test without arguments
%! A = jones();
%! assert(isempty(A));
%!
%!test
%! % test singular argument, should just be returned
%! M = jones_waveplate(rand(1,1),'wav');
%! MM = jones(M);
%! R = MM-M;
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % send light with horizontal linear polarization through a rotating
%! % 1/2-waveplate and subsequent polarizer: final intensity should
%! % vary as cos(2*angle)^2.
%! % This test feeds jones() with one cell array only!
%! angles = 0:360;
%! wps = jones_rotate(jones_waveplate(0.5, 'wav'), angles, 'deg');
%! lightin = jones_lphorizontal();
%! lightout = jones(jones_linpolarizer(),wps,lightin);
%! ilightout = jones_intensity(lightout);
%! R = ilightout-(cosd(angles.*2).^2);
%! assert(norm(R,inf), 0, 1e-9);
%!
%!test
%! % this is a more thorough test: send light with horizontal linear
%! % polarization through two rotating 1/2-waveplates (combining to
%! % a 1/1-waveplate)  and subsequent polarizer: final intensity
%! % should not vary!
%! % This test feeds jones() with two cell arrays.
%! angles = 0:360;
%! wps1 = jones_rotate(jones_waveplate(0.5, 'wav'), angles, 'deg');
%! wps2 = jones_rotate(jones_waveplate(0.5, 'wav'), angles, 'deg');
%! lightin = jones_lphorizontal();
%! lightout = jones(jones_linpolarizer(),wps2,wps1,lightin);
%! ilightout = jones_intensity(lightout);
%! R = ilightout-1;
%! assert(norm(R,inf), 0, 1e-9);

%!demo
%! angles = 0:360;
%! wps = jones_rotate(jones_waveplate(0.5, 'wav'), angles, 'deg');
%! lightin = jones_lphorizontal();
%! lightout = jones(jones_linpolarizer(),wps,lightin);
%! ilightout = jones_intensity(lightout);
%! figure();
%! plot(angles, ilightout);
%! title('transmitted intensity [should look like cos(2*a)^2');
%! xlabel('angle of halfwave plate axis');
%! ylabel('intensity [a.u.]');
%! legend('transmitted intensity');
%! % -----------------------------------------------------------------
%! % example 1: send light with horizontal linear polarization through 
%! % a rotating, perfect halfwave plate and subsequent polarizer: 
%! % final intensity should vary as cos(2*angle)^2.
%!
%!demo
%! angles = 0:360;
%! wps = jones_rotate(jones_waveplate(0.5, 'wav'), angles, 'deg');
%! wps2 = jones_rotate(jones_waveplate(0.45, 'wav'), angles, 'deg');
%! lightin = jones_lphorizontal();
%! lightout = jones(jones_linpolarizer(),wps,lightin);
%! ilightout = jones_intensity(lightout);
%! lightout2 = jones(jones_linpolarizer(),wps2,lightin);
%! ilightout2 = jones_intensity(lightout2);
%! figure();
%! plot(angles, ilightout, angles, ilightout2);
%! title('transmitted intensity with perfect and non-perfect halfwave plate');
%! xlabel('angle of halfwave plate axis');
%! ylabel('intensity [a.u.]');
%! legend('perfect (0.5-)plate', 'non-perfect (0.45-)plate');
%! % -----------------------------------------------------------------
%! % example 2: send light with horizontal linear polarization through 
%! % a rotating, non-perfect halfwave plate and subsequent polarizer: 
%! % final intensity should deviate from the perfect cos(2*angle)^2
%! % curve, never reaching zero transmission
%!
%!demo
%! angle = 0:360;
%! delay = 0:0.05:1;
%! % angles are in rows, delays in columns
%! angle_all = repmat(angle, [length(delay), 1]);
%! delay_all = repmat(delay', [1, length(angle)]);
%! wps3 = jones_waveplate(delay_all, 'wav');
%! wps3 = jones_rotate(wps3, angle_all, 'deg');
%! lightin = jones_lphorizontal();
%! lightout3 = jones(jones_linpolarizer(),wps3,lightin);
%! ilightout3 = jones_intensity(lightout3);
%! figure();
%! plot(angle, ilightout3);
%! title('transmitted intensity with plates of increasing delay');
%! xlabel('angle of plate axis');
%! ylabel('intensity [a.u.]');
%! legend(cellfun(@(x)sprintf('delay=%.2f',x),num2cell(delay),'UniformOutput',false));
%! % -----------------------------------------------------------------
%! % example 3: send light with horizontal linear polarization through 
%! % rotating waveplates with increasing delay  and subsequent polarizer

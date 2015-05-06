## Copyright (C) 2015 Andreas Weber <octave@tech-chat.de>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{rout} = } trace(@var{abcd}, @var{rin}, @var{do_plot})
## Trace the rays @var{rin} through @var{abcd}.
## If @var{do_plot} is true, create also a plot with the trace.
## @end deftypefn

function rout = trace (abcd, rin, do_plot = false)

  rout = rin;
  e = abcd.elements;
  x_tmp = 0;
  x_dir = 1;
  len = (numel (e) / 2) + 1;
  x = y = zeros (len, columns (rin));
  y(1, :) = rin (1, :);

  k = 1;
  while (numel(e) > 0)

    k += 1;
    switch (e{1})
      case {"propagation"}
        d = e{2};
        tmp = [1, d; 0 1];
        x_tmp += d * x_dir;

      case {"thin-lens"}
        f = e{2};
        tmp = [1, 0; -1/f, 1];

        plot_elements(end + 1).x = x_tmp;
        plot_elements(end).text = sprintf ("thin lens\nf = %.2f", f);

      case {"flat-refraction"}
        n1 = e{2}(1);
        n2 = e{2}(2);
        tmp = [1, 0; 0, n1/n2];

        plot_elements(end + 1).x = x_tmp;
        plot_elements(end).text = sprintf ("flat refraction\nn1 = %.2f\nn2 = %.2f", n1, n2);

      case {"curved-refraction"}
        n1 = e{2}(1);
        n2 = e{2}(2);
        R  = e{2}(3);
        tmp = [1, 0; (n1-n2)/(R*n2), n1/n2];

        plot_elements(end + 1).x = x_tmp;
        plot_elements(end).text = sprintf ("curved refraction\nn1 = %.2f\nn2 = %.2f\nR = %.2f", n1, n2, R);

      case {"flat-mirror"}
        tmp = eye (2);
        x_dir *= -1;
        plot_elements(end + 1).x = x_tmp;
        plot_elements(end).text = sprintf ("flat mirror");

      case {"curved-mirror"}
        R = e{2}(1)
         x_dir *= -1;
        tmp = [1, 0; 2/R, 1];
        plot_elements(end + 1).x = x_tmp;
        plot_elements(end).text = sprintf ("curved mirror\nR = %.2f", R);

      case {"thick-lens"}
        n1 = e{2}(1);
        n2 = e{2}(2);
        R1  = e{2}(3);
        R2  = e{2}(4);
        t  = e{2}(5);
        ###
        tmp = [1, 0; (n1-n2)/(R1*n2), n1/n2];
        plot_elements(end + 1).x = x_tmp;
        plot_elements(end).text = sprintf ("thick lens\nfirst surface\nn1 = %.2f\nn2 = %.2f\nR1 = %.2f", n1, n2, R1);

        rout = tmp * rout;
        x(k, :) = x_tmp * ones (1, columns (rin));
        y(k, :) = rout (1, :);
        k += 1;
        ###
        x_tmp += t * x_dir;
        rout = [1, t; 0, 1] * rout;
        x(k, :) = x_tmp * ones (1, columns (rin));
        y(k, :) = rout (1, :);
        k += 1;
        ###
        tmp = [1, 0; (n2-n1)/(R2*n1), n2/n1];
        plot_elements(end + 1).x = x_tmp;
        plot_elements(end).text = sprintf ("thick lens\nsecond surface\nn1 = %.2f\nn2 = %.2f\nR2 = %.2f", n1, n2, R2);

      otherwise
        error ("Unknown element \"%s\"", e{1});

    endswitch
    e(1:2) = [];

    rout = tmp * rout;

    x(k, :) = x_tmp * ones (1, columns (rin));
    y(k, :) = rout (1, :);

  endwhile

  if (do_plot)
    plot (x, y);
    hold on

    tmp_y = max (abs (y(:)));
    for k = 1: numel (plot_elements)
      plot ([plot_elements(k).x, plot_elements(k).x], [tmp_y, -tmp_y]);
      text (plot_elements(k).x, tmp_y, plot_elements(k).text, "verticalalignment", "bottom", "horizontalalignment", "center");
    endfor

    hold off
  endif

endfunction

%!demo
%! s = abcd ("propagation", 10,
%!           "thin-lens", 5,
%!           "propagation", 12,
%!           "thin-lens", 10,
%!           "propagation", 15);
%!
%! rin = [1 0.5 0 -0.5 -1; 0 0 0 0 0];
%! rout = trace(s, rin, true)

%!demo
%! s = abcd ("propagation", 8,
%!           "thin-lens", 8,
%!           "propagation", 3,
%!           "flat-mirror", [],
%!           "propagation", 15);
%!
%! rin = [1 0.5 0 -0.5 -1; 0 0 0 0 0];
%! rout = trace(s, rin, true)
%~
%!demo
%! s = abcd ("propagation", 2,
%!           "flat-refraction", [1, 1.4],
%!           "propagation", 1,
%!           "flat-refraction", [1.4, 1],
%!           "propagation", 2);
%!
%! rin = [-1 -1 -1 -1 -1; 0.0 0.1 0.2 0.3 0.4];
%! rout = trace(s, rin, true)

%!demo
%! s = abcd ("propagation", 6,
%!           "thick-lens", [1, 1.4, 5, -4, 2],
%!           "propagation", 4);
%!
%! rin = [0 0 0 0 0; 0.0 0.1 0.2 0.3 0.4];
%! rout = trace(s, rin, true)
%! axis([0 12 -2 4])

## Copyright (C) 2013 Martin Vogel
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

function [array, was_cell] = __c2n__(array, defaultvalue)

  % if possible, convert cell array to numeric array, else return an
  % array of default values of same size

  was_cell = false;
  if ~isnumeric(array)
    if iscell(array)
      was_cell = true;
      array2 = cell2mat(array);
      if (ndims(array2)==ndims(array)) && ...
	 all(size(array2)==size(array)) && ...
	 isnumeric(array2)
	array = array2;
      else
	array = ones(size(array))*defaultvalue;
      end
    else
      array(:) = defaultvalue;
    end
  end

end

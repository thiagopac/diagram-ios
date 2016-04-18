/*
  Stockfish, a chess program for iOS.
  Copyright (C) 2004-2014 Tord Romstad, Marco Costalba, Joona Kiiski.

  Stockfish is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Stockfish is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


#if !defined(SCALE_H_INCLUDED)
#define SCALE_H_INCLUDED

////
//// Includes
////

#include "value.h"

namespace Chess {

////
//// Types
////

enum ScaleFactor {
  SCALE_FACTOR_ZERO = 0,
  SCALE_FACTOR_NORMAL = 64,
  SCALE_FACTOR_MAX = 128,
  SCALE_FACTOR_NONE = 255
};


////
//// Inline functions
////

inline Value apply_scale_factor(Value v, ScaleFactor f) {
  return Value((v * f) / int(SCALE_FACTOR_NORMAL));
}

}

#endif // !defined(SCALE_H_INCLUDED)

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


////
//// Includes
////

#include <sstream>
#include <string>

#include "value.h"

namespace Chess {

////
//// Functions
////

/// value_to_tt() adjusts a mate score from "plies to mate from the root" to
/// "plies to mate from the current ply".  Non-mate scores are unchanged.
/// The function is called before storing a value to the transposition table.

Value value_to_tt(Value v, int ply) {
  if(v >= value_mate_in(100))
    return v + ply;
  else if(v <= value_mated_in(100))
    return v - ply;
  else
    return v;
}


/// value_from_tt() is the inverse of value_to_tt():  It adjusts a mate score
/// from the transposition table to a mate score corrected for the current
/// ply depth.

Value value_from_tt(Value v, int ply) {
  if(v >= value_mate_in(100))
    return v - ply;
  else if(v <= value_mated_in(100))
    return v + ply;
  else
    return v;
}


/// value_to_centipawns() converts a value from Glaurung's somewhat unusual
/// scale of pawn = 256 to the more conventional pawn = 100.

int value_to_centipawns(Value v) {
  return (int(v) * 100) / int(PawnValueMidgame);
}


/// value_from_centipawns() converts a centipawn value to Glaurung's internal
/// evaluation scale.  It's used when reading the values of UCI options
/// containing material values (e.g. futility pruning margins).

Value value_from_centipawns(int cp) {
  return Value((cp * 256) / 100);
}


/// value_to_string() converts a value to a string suitable for use with the
/// UCI protocol.

const std::string value_to_string(Value v) {
  std::stringstream s;

  if(abs(v) < VALUE_MATE - 200)
    s << "cp " << value_to_centipawns(v);
  else {
    s << "mate ";
    if(v > 0)
      s << (VALUE_MATE - v + 1) / 2;
    else
      s << -(VALUE_MATE + v) / 2;
  }
  return s.str();
}

}

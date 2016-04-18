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


#if !defined(SQUARE_H_INCLUDED)
#define SQUARE_H_INCLUDED

////
//// Includes
////

#include <cstdlib>
#include <string>

#include "color.h"
#include "misc.h"

namespace Chess {

////
//// Types
////

enum Square {
  SQ_A1, SQ_B1, SQ_C1, SQ_D1, SQ_E1, SQ_F1, SQ_G1, SQ_H1,
  SQ_A2, SQ_B2, SQ_C2, SQ_D2, SQ_E2, SQ_F2, SQ_G2, SQ_H2,
  SQ_A3, SQ_B3, SQ_C3, SQ_D3, SQ_E3, SQ_F3, SQ_G3, SQ_H3,
  SQ_A4, SQ_B4, SQ_C4, SQ_D4, SQ_E4, SQ_F4, SQ_G4, SQ_H4,
  SQ_A5, SQ_B5, SQ_C5, SQ_D5, SQ_E5, SQ_F5, SQ_G5, SQ_H5,
  SQ_A6, SQ_B6, SQ_C6, SQ_D6, SQ_E6, SQ_F6, SQ_G6, SQ_H6,
  SQ_A7, SQ_B7, SQ_C7, SQ_D7, SQ_E7, SQ_F7, SQ_G7, SQ_H7,
  SQ_A8, SQ_B8, SQ_C8, SQ_D8, SQ_E8, SQ_F8, SQ_G8, SQ_H8,
  SQ_NONE
};

enum File {
  FILE_A, FILE_B, FILE_C, FILE_D, FILE_E, FILE_F, FILE_G, FILE_H, FILE_NONE
};

enum Rank {
  RANK_1, RANK_2, RANK_3, RANK_4, RANK_5, RANK_6, RANK_7, RANK_8, RANK_NONE
};

enum SquareDelta {
  DELTA_SSW = -021, DELTA_SS = -020, DELTA_SSE = -017, DELTA_SWW = -012,
  DELTA_SW = -011, DELTA_S = -010, DELTA_SE = -07, DELTA_SEE = -06,
  DELTA_W = -01, DELTA_ZERO = 0, DELTA_E = 01, DELTA_NWW = 06, DELTA_NW = 07,
  DELTA_N = 010, DELTA_NE = 011, DELTA_NEE = 012, DELTA_NNW = 017,
  DELTA_NN = 020, DELTA_NNE = 021
};


////
//// Constants
////

const int FlipMask = 070;
const int FlopMask = 07;


////
//// Inline functions
////

inline File operator+ (File x, int i) { return File(int(x) + i); }
inline File operator+ (File x, File y) { return x + int(y); }
inline void operator++ (File &x, int) { x = File(int(x) + 1); }
inline void operator+= (File &x, int i) { x = File(int(x) + i); }
inline File operator- (File x, int i) { return File(int(x) - i); }
inline void operator-- (File &x, int) { x = File(int(x) - 1); }
inline void operator-= (File &x, int i) { x = File(int(x) - i); }

inline Rank operator+ (Rank x, int i) { return Rank(int(x) + i); }
inline Rank operator+ (Rank x, Rank y) { return x + int(y); }
inline void operator++ (Rank &x, int) { x = Rank(int(x) + 1); }
inline void operator+= (Rank &x, int i) { x = Rank(int(x) + i); }
inline Rank operator- (Rank x, int i) { return Rank(int(x) - i); }
inline void operator-- (Rank &x, int) { x = Rank(int(x) - 1); }
inline void operator-= (Rank &x, int i) { x = Rank(int(x) - i); }

inline Square operator+ (Square x, int i) { return Square(int(x) + i); }
inline void operator++ (Square &x, int) { x = Square(int(x) + 1); }
inline void operator+= (Square &x, int i) { x = Square(int(x) + i); }
inline Square operator- (Square x, int i) { return Square(int(x) - i); }
inline void operator-- (Square &x, int) { x = Square(int(x) - 1); }
inline void operator-= (Square &x, int i) { x = Square(int(x) - i); }
inline Square operator+ (Square x, SquareDelta i) { return Square(int(x) + i); }
inline void operator+= (Square &x, SquareDelta i) { x = Square(int(x) + i); }
inline Square operator- (Square x, SquareDelta i) { return Square(int(x) - i); }
inline void operator-= (Square &x, SquareDelta i) { x = Square(int(x) - i); }
inline SquareDelta operator- (Square x, Square y) {
  return SquareDelta(int(x) - int(y));
}

inline Square make_square(File f, Rank r) {
  return Square(int(f) | (int(r) << 3));
}

inline File square_file(Square s) {
  return File(int(s) & 7);
}

inline Rank square_rank(Square s) {
  return Rank(int(s) >> 3);
}

inline Square flip_square(Square s) {
  return Square(int(s) ^ FlipMask);
}

inline Square flop_square(Square s) {
  return Square(int(s) ^ FlopMask);
}

inline Square relative_square(Color c, Square s) {
  return Square(int(s) ^ (int(c) * FlipMask));
}

inline Rank pawn_rank(Color c, Square s) {
  return square_rank(relative_square(c, s));
}

inline Color square_color(Square s) {
  return Color((int(square_file(s)) + int(square_rank(s))) & 1);
}

inline int file_distance(File f1, File f2) {
  return abs(int(f1) - int(f2));
}

inline int file_distance(Square s1, Square s2) {
  return file_distance(square_file(s1), square_file(s2));
}

inline int rank_distance(Rank r1, Rank r2) {
  return abs(int(r1) - int(r2));
}

inline int rank_distance(Square s1, Square s2) {
  return rank_distance(square_rank(s1), square_rank(s2));
}

#define Max(x, y) (((x) < (y))? (y) : (x))
inline int square_distance(Square s1, Square s2) {
  return Max(file_distance(s1, s2), rank_distance(s1, s2));
}


////
//// Prototypes
////

extern File file_from_char(char c);
extern char file_to_char(File f);
extern Rank rank_from_char(char c);
extern char rank_to_char(Rank r);
extern Square square_from_string(const std::string &str);
extern const std::string square_to_string(Square s);

extern bool file_is_ok(File f);
extern bool rank_is_ok(Rank r);
extern bool square_is_ok(Square s);

}

#endif // !defined(SQUARE_H_INCLUDED)

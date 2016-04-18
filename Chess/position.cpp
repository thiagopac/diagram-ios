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

#include <algorithm>
#include <cassert>

#include <cstdio>
#include <cstring>
#include <iostream>
#include <fstream>
#include <sstream>

#include "mersenne.h"
#include "movegen.h"
#include "movepick.h"
#include "position.h"
#include "psqtab.h"
//#include "ucioption.h"

namespace Chess {

////
//// Variables
////

int Position::castleRightsMask[64];

Key Position::zobrist[2][8][64];
Key Position::zobEp[64];
Key Position::zobCastle[16];
Key Position::zobMaterial[2][8][16];
Key Position::zobSideToMove;

Value Position::MgPieceSquareTable[16][64];
Value Position::EgPieceSquareTable[16][64];


////
//// Functions
////

/// Constructors

Position::Position() { }  // Do we really need this one?

Position::Position(const Position &pos) {
  this->copy(pos);
}

Position::Position(const std::string &fen) {
  this->from_fen(fen);
}


/// Position::from_fen() initializes the position object with the given FEN
/// string. This function is not very robust - make sure that input FENs are
/// correct (this is assumed to be the responsibility of the GUI).

void Position::from_fen(const std::string &fen) {
  File file;
  Rank rank;
  int i;

  this->clear();

  // Board
  rank = RANK_8;
  file = FILE_A;
  for(i = 0; fen[i] != ' '; i++) {
    if(isdigit(fen[i]))
      // Skip the given number of files
      file += (fen[i] - '1' + 1);
    else {
      Square square = make_square(file, rank);
      switch(fen[i]) {
      case 'K': this->put_piece(WK, square); file++; break;
      case 'Q': this->put_piece(WQ, square); file++; break;
      case 'R': this->put_piece(WR, square); file++; break;
      case 'B': this->put_piece(WB, square); file++; break;
      case 'N': this->put_piece(WN, square); file++; break;
      case 'P': this->put_piece(WP, square); file++; break;
      case 'k': this->put_piece(BK, square); file++; break;
      case 'q': this->put_piece(BQ, square); file++; break;
      case 'r': this->put_piece(BR, square); file++; break;
      case 'b': this->put_piece(BB, square); file++; break;
      case 'n': this->put_piece(BN, square); file++; break;
      case 'p': this->put_piece(BP, square); file++; break;
      case '/': file = FILE_A; rank--; break;
      case ' ': break;
      default:
        std::cout << "Error in FEN at character " << i << std::endl;
        return;
      }
    }
  }

  // Side to move
  i++;
  if(fen[i] == 'w')
    sideToMove = WHITE;
  else if(fen[i] == 'b')
    sideToMove = BLACK;
  else {
    std::cout << "Error in FEN at character " << i << std::endl;
    return;
  }

  // Castling rights:
  i++;
  if(fen[i] != ' ') {
    std::cout << "Error in FEN at character " << i << std::endl;
    return;
  }

  i++;
  while(strchr("KQkqabcdefghABCDEFGH-", fen[i])) {
    if(fen[i] == '-') {
      i++; break;
    }
    else if(fen[i] == 'K') this->allow_oo(WHITE);
    else if(fen[i] == 'Q') this->allow_ooo(WHITE);
    else if(fen[i] == 'k') this->allow_oo(BLACK);
    else if(fen[i] == 'q') this->allow_ooo(BLACK);
    else if(fen[i] >= 'A' && fen[i] <= 'H') {
      File rookFile, kingFile = FILE_NONE;
      for(Square square = SQ_B1; square <= SQ_G1; square++)
        if(this->piece_on(square) == WK)
          kingFile = square_file(square);
      if(kingFile == FILE_NONE) {
        std::cout << "Error in FEN at character " << i << std::endl;
        return;
      }
      initialKFile = kingFile;
      rookFile = File(fen[i] - 'A') + FILE_A;
      if(rookFile < initialKFile) {
        this->allow_ooo(WHITE);
        initialQRFile = rookFile;
      }
      else {
        this->allow_oo(WHITE);
        initialKRFile = rookFile;
      }
    }
    else if(fen[i] >= 'a' && fen[i] <= 'h') {
      File rookFile, kingFile = FILE_NONE;
      for(Square square = SQ_B8; square <= SQ_G8; square++)
        if(this->piece_on(square) == BK)
          kingFile = square_file(square);
      if(kingFile == FILE_NONE) {
        std::cout << "Error in FEN at character " << i << std::endl;
        return;
      }
      initialKFile = kingFile;
      rookFile = File(fen[i] - 'a') + FILE_A;
      if(rookFile < initialKFile) {
        this->allow_ooo(BLACK);
        initialQRFile = rookFile;
      }
      else {
        this->allow_oo(BLACK);
        initialKRFile = rookFile;
      }
    }
    else {
      std::cout << "Error in FEN at character " << i << std::endl;
      return;
    }
    i++;
  }
  while(fen[i] == ' ')
    i++;

  // En passant square
  if(i <= int(fen.length()) - 2)
    if(fen[i] >= 'a' && fen[i] <= 'h' && (fen[i+1] == '3' || fen[i+1] == '6'))
      epSquare = square_from_string(fen.substr(i, 2));

  // Various initialisation

  for(Square sq = SQ_A1; sq <= SQ_H8; sq++)
    castleRightsMask[sq] = ALL_CASTLES;
  castleRightsMask[make_square(initialKFile, RANK_1)] ^=
    (WHITE_OO|WHITE_OOO);
  castleRightsMask[make_square(initialKFile, RANK_8)] ^=
    (BLACK_OO|BLACK_OOO);
  castleRightsMask[make_square(initialKRFile, RANK_1)] ^= WHITE_OO;
  castleRightsMask[make_square(initialKRFile, RANK_8)] ^= BLACK_OO;
  castleRightsMask[make_square(initialQRFile, RANK_1)] ^= WHITE_OOO;
  castleRightsMask[make_square(initialQRFile, RANK_8)] ^= BLACK_OOO;

  this->find_checkers();

  key = this->compute_key();
  pawnKey = this->compute_pawn_key();
  materialKey = this->compute_material_key();
  mgValue = this->compute_mg_value();
  egValue = this->compute_eg_value();
  npMaterial[WHITE] = this->compute_non_pawn_material(WHITE);
  npMaterial[BLACK] = this->compute_non_pawn_material(BLACK);
}


/// Position::to_fen() converts the position object to a FEN string. This is
/// probably only useful for debugging.

const std::string Position::to_fen() const {
  char pieceLetters[] = " PNBRQK  pnbrqk";
  std::string result;
  int skip;

  for(Rank rank = RANK_8; rank >= RANK_1; rank--) {
    skip = 0;
    for(File file = FILE_A; file <= FILE_H; file++) {
      Square square = make_square(file, rank);
      if(this->square_is_occupied(square)) {
        if(skip > 0) result += (char)skip + '0';
        result += pieceLetters[this->piece_on(square)];
        skip = 0;
      }
      else skip++;
    }
    if(skip > 0) result += (char)skip + '0';
    result += (rank > RANK_1)? '/' : ' ';
  }

  result += (sideToMove == WHITE)? 'w' : 'b';
  result += ' ';
  if(castleRights == NO_CASTLES) result += '-';
  else {
    if(this->can_castle_kingside(WHITE)) result += 'K';
    if(this->can_castle_queenside(WHITE)) result += 'Q';
    if(this->can_castle_kingside(BLACK)) result += 'k';
    if(this->can_castle_queenside(BLACK)) result += 'q';
  }

  result += ' ';
  if(this->ep_square() == SQ_NONE) result += '-';
  else result += square_to_string(this->ep_square());

  return result;
}


/// Position::print() prints an ASCII representation of the position to
/// the standard output.

void Position::print() const {
  char pieceStrings[][8] =
    {"| ? ", "| P ", "| N ", "| B ", "| R ", "| Q ", "| K ", "| ? ",
     "| ? ", "|=P=", "|=N=", "|=B=", "|=R=", "|=Q=", "|=K="
    };

  for(Rank rank = RANK_8; rank >= RANK_1; rank--) {
    std::cout << "+---+---+---+---+---+---+---+---+\n";
    for(File file = FILE_A; file <= FILE_H; file++) {
      Square sq = make_square(file, rank);
      Piece piece = this->piece_on(sq);
      if(piece == EMPTY)
        std::cout << ((square_color(sq) == WHITE)? "|   " : "| . ");
      else
        std::cout << pieceStrings[piece];
    }
    std::cout << "|\n";
  }
  std::cout << "+---+---+---+---+---+---+---+---+\n";
  std::cout << this->to_fen() << std::endl;
  std::cout << key << std::endl;
}


/// Position::copy() creates a copy of the input position.

void Position::copy(const Position &pos) {
  memcpy(this, &pos, sizeof(Position));
}


/// Position:pinned_pieces() returns a bitboard of all pinned (against the
/// king) pieces for the given color.

Bitboard Position::pinned_pieces(Color c) const {
  Bitboard b1, b2, pinned, pinners, sliders;
  Square ksq = this->king_square(c), s;
  Color them = opposite_color(c);

  pinned = EmptyBoardBB;
  b1 = this->occupied_squares();

  sliders = this->rooks_and_queens(them) & ~this->checkers();
  if(sliders & RookPseudoAttacks[ksq]) {
    b2 = this->rook_attacks(ksq) & this->pieces_of_color(c);
    pinners = rook_attacks_bb(ksq, b1 ^ b2) & sliders;
    while(pinners) {
      s = pop_1st_bit(&pinners);
      pinned |= (squares_between(s, ksq) & b2);
    }
  }

  sliders = this->bishops_and_queens(them) & ~this->checkers();
  if(sliders & BishopPseudoAttacks[ksq]) {
    b2 = this->bishop_attacks(ksq) & this->pieces_of_color(c);
    pinners = bishop_attacks_bb(ksq, b1 ^ b2) & sliders;
    while(pinners) {
      s = pop_1st_bit(&pinners);
      pinned |= (squares_between(s, ksq) & b2);
    }
  }

  return pinned;
}


/// Position:discovered_check_candidates() returns a bitboard containing all
/// pieces for the given side which are candidates for giving a discovered
/// check.  The code is almost the same as the function for finding pinned
/// pieces.

Bitboard Position::discovered_check_candidates(Color c) const {
  Bitboard b1, b2, dc, checkers, sliders;
  Square ksq = this->king_square(opposite_color(c)), s;

  dc = EmptyBoardBB;
  b1 = this->occupied_squares();

  sliders = this->rooks_and_queens(c);
  if(sliders & RookPseudoAttacks[ksq]) {
    b2 = this->rook_attacks(ksq) & this->pieces_of_color(c);
    checkers = rook_attacks_bb(ksq, b1 ^ b2) & sliders;
    while(checkers) {
      s = pop_1st_bit(&checkers);
      dc |= (squares_between(s, ksq) & b2);
    }
  }

  sliders = this->bishops_and_queens(c);
  if(sliders & BishopPseudoAttacks[ksq]) {
    b2 = this->bishop_attacks(ksq) & this->pieces_of_color(c);
    checkers = bishop_attacks_bb(ksq, b1 ^ b2) & sliders;
    while(checkers) {
      s = pop_1st_bit(&checkers);
      dc |= (squares_between(s, ksq) & b2);
    }
  }

  return dc;
}


/// Position::square_is_attacked() checks whether the given side attacks the
/// given square.

bool Position::square_is_attacked(Square s, Color c) const {
  return
    (this->pawn_attacks(opposite_color(c), s) & this->pawns(c)) ||
    (this->knight_attacks(s) & this->knights(c)) ||
    (this->king_attacks(s) & this->kings(c)) ||
    (this->rook_attacks(s) & this->rooks_and_queens(c)) ||
    (this->bishop_attacks(s) & this->bishops_and_queens(c));
}


/// Position::attacks_to() computes a bitboard containing all pieces which
/// attacks a given square. There are two versions of this function: One
/// which finds attackers of both colors, and one which only finds the
/// attackers for one side.

Bitboard Position::attacks_to(Square s) const {
  return
    (this->black_pawn_attacks(s) & this->pawns(WHITE)) |
    (this->white_pawn_attacks(s) & this->pawns(BLACK)) |
    (this->knight_attacks(s) & this->pieces_of_type(KNIGHT)) |
    (this->rook_attacks(s) & this->rooks_and_queens()) |
    (this->bishop_attacks(s) & this->bishops_and_queens()) |
    (this->king_attacks(s) & this->pieces_of_type(KING));
}

Bitboard Position::attacks_to(Square s, Color c) const {
  return this->attacks_to(s) & this->pieces_of_color(c);
}


/// Position::piece_attacks_square() tests whether the piece on square f
/// attacks square t.

bool Position::piece_attacks_square(Square f, Square t) const {
  assert(square_is_ok(f));
  assert(square_is_ok(t));

  switch(this->piece_on(f)) {
  case WP: return this->white_pawn_attacks_square(f, t);
  case BP: return this->black_pawn_attacks_square(f, t);
  case WN: case BN: return this->knight_attacks_square(f, t);
  case WB: case BB: return this->bishop_attacks_square(f, t);
  case WR: case BR: return this->rook_attacks_square(f, t);
  case WQ: case BQ: return this->queen_attacks_square(f, t);
  case WK: case BK: return this->king_attacks_square(f, t);
  default: return false;
  }

  return false;
}


/// Position::find_checkers() computes the checkersBB bitboard, which
/// contains a nonzero bit for each checking piece (0, 1 or 2).  It
/// currently works by calling Position::attacks_to, which is probably
/// inefficient.  Consider rewriting this function to use the last move
/// played, like in non-bitboard versions of Glaurung.

void Position::find_checkers() {
  checkersBB = attacks_to(this->king_square(this->side_to_move()),
                          opposite_color(this->side_to_move()));
}


/// Position::move_is_legal() tests whether a pseudo-legal move is legal.
/// There are two versions of this function:  One which takes only a
/// move as input, and one which takes a move and a bitboard of pinned
/// pieces.  The latter function is faster, and should always be preferred
/// when a pinned piece bitboard has already been computed.

bool Position::move_is_legal(Move m)  const {
  return this->move_is_legal(m, this->pinned_pieces(this->side_to_move()));
}


bool Position::move_is_legal(Move m, Bitboard pinned) const {
  Color us, them;
  Square ksq, from;

  assert(this->is_ok());
  assert(move_is_ok(m));
  assert(pinned == this->pinned_pieces(this->side_to_move()));

  // If we're in check, all pseudo-legal moves are legal, because our
  // check evasion generator only generates true legal moves.
  if(this->is_check()) return true;

  // Castling moves are checked for legality during move generation.
  if(move_is_castle(m)) return true;

  us = this->side_to_move();
  them = opposite_color(us);

  from = move_from(m);
  ksq = this->king_square(us);

  assert(this->color_of_piece_on(from) == us);
  assert(this->piece_on(ksq) == king_of_color(us));

  // En passant captures are a tricky special case.  Because they are
  // rather uncommon, we do it simply by testing whether the king is attacked
  // after the move is made:
  if(move_is_ep(m)) {
    Square to = move_to(m);
    Square capsq = make_square(square_file(to), square_rank(from));
    Bitboard b = this->occupied_squares();

    assert(to == this->ep_square());
    assert(this->piece_on(from) == pawn_of_color(us));
    assert(this->piece_on(capsq) == pawn_of_color(them));
    assert(this->piece_on(to) == EMPTY);

    clear_bit(&b, from); clear_bit(&b, capsq); set_bit(&b, to);
    return
      (!(rook_attacks_bb(ksq, b) & this->rooks_and_queens(them)) &&
       !(bishop_attacks_bb(ksq, b) & this->bishops_and_queens(them)));
  }

  // If the moving piece is a king, check whether the destination
  // square is attacked by the opponent.
  if(from == ksq) return !(this->square_is_attacked(move_to(m), them));

  // A non-king move is legal if and only if it is not pinned or it
  // is moving along the ray towards or away from the king.
  if(!bit_is_set(pinned, from)) return true;
  if(direction_between_squares(from, ksq) ==
     direction_between_squares(move_to(m), ksq))
    return true;

  return false;
}


/// Position::move_is_check() tests whether a pseudo-legal move is a check.
/// There are two versions of this function:  One which takes only a move as
/// input, and one which takes a move and a bitboard of discovered check
/// candidates.  The latter function is faster, and should always be preferred
/// when a discovered check candidates bitboard has already been computed.

bool Position::move_is_check(Move m) const {
  Bitboard dc = this->discovered_check_candidates(this->side_to_move());
  return this->move_is_check(m, dc);
}


bool Position::move_is_check(Move m, Bitboard dcCandidates) const {
  Color us, them;
  Square ksq, from, to;

  assert(this->is_ok());
  assert(move_is_ok(m));
  assert(dcCandidates ==
         this->discovered_check_candidates(this->side_to_move()));

  us = this->side_to_move();
  them = opposite_color(us);

  from = move_from(m);
  to = move_to(m);
  ksq = this->king_square(them);
  assert(this->color_of_piece_on(from) == us);
  assert(this->piece_on(ksq) == king_of_color(them));

  // Proceed according to the type of the moving piece:
  switch(this->type_of_piece_on(from)) {
  case PAWN:
    // Normal check?
    if(bit_is_set(this->pawn_attacks(them, ksq), to))
      return true;
    // Discovered check?
    else if(bit_is_set(dcCandidates, from) &&
            direction_between_squares(from, ksq) !=
            direction_between_squares(to, ksq))
      return true;
    // Promotion with check?
    else if(move_promotion(m)) {
      Bitboard b = this->occupied_squares();
      clear_bit(&b, from);

      switch(move_promotion(m)) {
      case KNIGHT:
        return this->knight_attacks_square(to, ksq);
      case BISHOP:
        return bit_is_set(bishop_attacks_bb(to, b), ksq);
      case ROOK:
        return bit_is_set(rook_attacks_bb(to, b), ksq);
      case QUEEN:
        return bit_is_set(queen_attacks_bb(to, b), ksq);
      default:
        assert(false);
      }
    }
    // En passant capture with check?  We have already handled the case
    // of direct checks and ordinary discovered check, the only case we
    // need to handle is the unusual case of a discovered check through the
    // captured pawn.
    else if(move_is_ep(m)) {
      Square capsq = make_square(square_file(to), square_rank(from));
      Bitboard b = this->occupied_squares();

      clear_bit(&b, from); clear_bit(&b, capsq); set_bit(&b, to);
      return
        ((rook_attacks_bb(ksq, b) & this->rooks_and_queens(us)) ||
         (bishop_attacks_bb(ksq, b) & this->bishops_and_queens(us)));
    }
    return false;

  case KNIGHT:
    // Discovered check?
    if(bit_is_set(dcCandidates, from))
      return true;
    // Normal check?
    else
      return bit_is_set(this->knight_attacks(ksq), to);

  case BISHOP:
    // Discovered check?
    if(bit_is_set(dcCandidates, from))
      return true;
    // Normal check?
    else
      return bit_is_set(this->bishop_attacks(ksq), to);

  case ROOK:
    // Discovered check?
    if(bit_is_set(dcCandidates, from))
      return true;
    // Normal check?
    else
      return bit_is_set(this->rook_attacks(ksq), to);

  case QUEEN:
    // Discovered checks are impossible!
    assert(!bit_is_set(dcCandidates, from));
    // Normal check?
    return bit_is_set(this->queen_attacks(ksq), to);

  case KING:
    // Discovered check?
    if(bit_is_set(dcCandidates, from) &&
       direction_between_squares(from, ksq) !=
       direction_between_squares(to, ksq))
      return true;
    // Castling with check?
    if(move_is_castle(m)) {
      Square kfrom, kto, rfrom, rto;
      Bitboard b = this->occupied_squares();

      kfrom = from;
      rfrom = to;
      if(rfrom > kfrom) {
        kto = relative_square(us, SQ_G1);
        rto = relative_square(us, SQ_F1);
      }
      else {
        kto = relative_square(us, SQ_C1);
        rto = relative_square(us, SQ_D1);
      }

      clear_bit(&b, kfrom); clear_bit(&b, rfrom);
      set_bit(&b, rto); set_bit(&b, kto);

      return bit_is_set(rook_attacks_bb(rto, b), ksq);
    }

    return false;

  default:
    assert(false);
    return false;
  }

  assert(false);
  return false;
}


/// Position::move_is_capture() tests whether a move from the current
/// position is a capture.

bool Position::move_is_capture(Move m) const {
  return
    this->color_of_piece_on(move_to(m)) == opposite_color(this->side_to_move())
    || move_is_ep(m);
}


/// Position::move_attacks_square() tests whether a move from the current
/// position attacks a given square.  Only attacks by the moving piece are
/// considered; the function does not handle X-ray attacks.

bool Position::move_attacks_square(Move m, Square s) const {
  assert(move_is_ok(m));
  assert(square_is_ok(s));

  Square f = move_from(m), t = move_to(m);

  assert(this->square_is_occupied(f));

  switch(this->piece_on(f)) {
  case WP: return this->white_pawn_attacks_square(t, s);
  case BP: return this->black_pawn_attacks_square(t, s);
  case WN: case BN: return this->knight_attacks_square(t, s);
  case WB: case BB: return this->bishop_attacks_square(t, s);
  case WR: case BR: return this->rook_attacks_square(t, s);
  case WQ: case BQ: return this->queen_attacks_square(t, s);
  case WK: case BK: return this->king_attacks_square(t, s);
  default: assert(false);
  }

  return false;
}



/// Position::backup() is called when making a move.  All information
/// necessary to restore the position when the move is later unmade
/// is saved to an UndoInfo object.  The function Position::restore
/// does the reverse operation:  When one does a backup followed by
/// a restore with the same UndoInfo object, the position is restored
/// to the state before backup was called.

void Position::backup(UndoInfo &u) const {
  u.castleRights = castleRights;
  u.epSquare = epSquare;
  u.checkersBB = checkersBB;
  u.key = key;
  u.pawnKey = pawnKey;
  u.materialKey = materialKey;
  u.rule50 = rule50;
  u.lastMove = lastMove;
  u.capture = NO_PIECE_TYPE;
  u.mgValue = mgValue;
  u.egValue = egValue;
}


/// Position::restore() is called when unmaking a move.  It copies back
/// the information backed up during a previous call to Position::backup.

void Position::restore(const UndoInfo &u) {
  castleRights = u.castleRights;
  epSquare = u.epSquare;
  checkersBB = u.checkersBB;
  key = u.key;
  pawnKey = u.pawnKey;
  materialKey = u.materialKey;
  rule50 = u.rule50;
  lastMove = u.lastMove;
  mgValue = u.mgValue;
  egValue = u.egValue;
}


/// Position::do_move() makes a move, and backs up all information necessary
/// to undo the move to an UndoInfo object.  The move is assumed to be legal.
/// Pseudo-legal moves should be filtered out before this function is called.
/// There are two versions of this function, one which takes only the move and
/// the UndoInfo as input, and one which takes a third parameter, a bitboard of
/// discovered check candidates.  The second version is faster, because knowing
/// the discovered check candidates makes it easier to update the checkersBB
/// member variable in the position object.

void Position::do_move(Move m, UndoInfo &u) {
  this->do_move(m, u, this->discovered_check_candidates(this->side_to_move()));
}

void Position::do_move(Move m, UndoInfo &u, Bitboard dcCandidates) {
  assert(this->is_ok());
  assert(move_is_ok(m));

  // Back up the necessary information to our UndoInfo object (except the
  // captured piece, which is taken care of later:
  this->backup(u);

  // Save the current key to the history[] array, in order to be able to
  // detect repetition draws:
  history[gamePly] = key;

  // Increment the 50 moves rule draw counter.  Resetting it to zero in the
  // case of non-reversible moves is taken care of later.
  rule50++;

  if(move_is_castle(m))
    this->do_castle_move(m);
  else if(move_promotion(m))
    this->do_promotion_move(m, u);
  else if(move_is_ep(m))
    this->do_ep_move(m);
  else {
    Color us, them;
    Square from, to;
    PieceType piece, capture;

    us = this->side_to_move();
    them = opposite_color(us);

    from = move_from(m);
    to = move_to(m);

    assert(this->color_of_piece_on(from) == us);
    assert(this->color_of_piece_on(to) == them || this->piece_on(to) == EMPTY);

    piece = this->type_of_piece_on(from);
    capture = this->type_of_piece_on(to);

    if(capture) {
      assert(capture != KING);

      // Remove captured piece:
      clear_bit(&(byColorBB[them]), to);
      clear_bit(&(byTypeBB[capture]), to);

      // Update hash key:
      key ^= zobrist[them][capture][to];

      // If the captured piece was a pawn, update pawn hash key:
      if(capture == PAWN)
        pawnKey ^= zobrist[them][PAWN][to];

      // Update incremental scores:
      mgValue -= this->mg_pst(them, capture, to);
      egValue -= this->eg_pst(them, capture, to);

      // Update material:
      if(capture != PAWN)
        npMaterial[them] -= piece_value_midgame(capture);

      // Update material hash key:
      materialKey ^= zobMaterial[them][capture][pieceCount[them][capture]];

      // Update piece count:
      pieceCount[them][capture]--;

      // Update piece list:
      pieceList[them][capture][index[to]] =
        pieceList[them][capture][pieceCount[them][capture]];
      index[pieceList[them][capture][index[to]]] = index[to];

      // Remember the captured piece, in order to be able to undo the move
      // correctly:
      u.capture = capture;

      // Reset rule 50 counter:
      rule50 = 0;
    }

    // Move the piece:
    clear_bit(&(byColorBB[us]), from);
    clear_bit(&(byTypeBB[piece]), from);
    clear_bit(&(byTypeBB[0]), from); // HACK: byTypeBB[0] == occupied squares
    set_bit(&(byColorBB[us]), to);
    set_bit(&(byTypeBB[piece]), to);
    set_bit(&(byTypeBB[0]), to); // HACK: byTypeBB[0] == occupied squares
    board[to] = board[from];
    board[from] = EMPTY;

    // Update hash key:
    key ^= zobrist[us][piece][from] ^ zobrist[us][piece][to];

    // Update incremental scores:
    mgValue -= this->mg_pst(us, piece, from);
    mgValue += this->mg_pst(us, piece, to);
    egValue -= this->eg_pst(us, piece, from);
    egValue += this->eg_pst(us, piece, to);

    // If the moving piece was a king, update the king square:
    if(piece == KING)
      kingSquare[us] = to;

    // If the move was a double pawn push, set the en passant square.
    // This code is a bit ugly right now, and should be cleaned up later.
    // FIXME
    if(epSquare != SQ_NONE) {
      key ^= zobEp[epSquare];
      epSquare = SQ_NONE;
    }
    if(piece == PAWN) {
      if(abs(int(to) - int(from)) == 16) {
        if((us == WHITE && (this->white_pawn_attacks(from + DELTA_N) &
                            this->pawns(BLACK))) ||
           (us == BLACK && (this->black_pawn_attacks(from + DELTA_S) &
                            this->pawns(WHITE)))) {
          epSquare = Square((int(from) + int(to)) / 2);
          key ^= zobEp[epSquare];
        }
      }
      // Reset rule 50 draw counter.
      rule50 = 0;
      // Update pawn hash key:
      pawnKey ^= zobrist[us][PAWN][from] ^ zobrist[us][PAWN][to];
    }

    // Update piece lists:
    pieceList[us][piece][index[from]] = to;
    index[to] = index[from];

    // Update castle rights:
    key ^= zobCastle[castleRights];
    castleRights &= castleRightsMask[from];
    castleRights &= castleRightsMask[to];
    key ^= zobCastle[castleRights];

    // Update checkers bitboard:
    checkersBB = EmptyBoardBB;
    Square ksq = this->king_square(them);

    switch(piece) {

    case PAWN:
      if(bit_is_set(this->pawn_attacks(them, ksq), to))
        set_bit(&checkersBB, to);
      if(bit_is_set(dcCandidates, from))
        checkersBB |=
          ((this->rook_attacks(ksq) & this->rooks_and_queens(us)) |
           (this->bishop_attacks(ksq) & this->bishops_and_queens(us)));
      break;

    case KNIGHT:
      if(bit_is_set(this->knight_attacks(ksq), to))
        set_bit(&checkersBB, to);
      if(bit_is_set(dcCandidates, from))
        checkersBB |=
          ((this->rook_attacks(ksq) & this->rooks_and_queens(us)) |
           (this->bishop_attacks(ksq) & this->bishops_and_queens(us)));
      break;

    case BISHOP:
      if(bit_is_set(this->bishop_attacks(ksq), to))
        set_bit(&checkersBB, to);
      if(bit_is_set(dcCandidates, from))
        checkersBB |=
          (this->rook_attacks(ksq) & this->rooks_and_queens(us));
      break;

    case ROOK:
      if(bit_is_set(this->rook_attacks(ksq), to))
        set_bit(&checkersBB, to);
      if(bit_is_set(dcCandidates, from))
        checkersBB |=
          (this->bishop_attacks(ksq) & this->bishops_and_queens(us));
      break;

    case QUEEN:
      if(bit_is_set(this->queen_attacks(ksq), to))
        set_bit(&checkersBB, to);
      break;

    case KING:
      if(bit_is_set(dcCandidates, from))
        checkersBB |=
          ((this->rook_attacks(ksq) & this->rooks_and_queens(us)) |
           (this->bishop_attacks(ksq) & this->bishops_and_queens(us)));
      break;

    default:
      assert(false);
      break;
    }
  }

  // Finish
  key ^= zobSideToMove;
  sideToMove = opposite_color(sideToMove);
  gamePly++;

  mgValue += (sideToMove == WHITE)? TempoValueMidgame : -TempoValueMidgame;
  egValue += (sideToMove == WHITE)? TempoValueEndgame : -TempoValueEndgame;

  assert(this->is_ok());
}


/// Position::do_castle_move() is a private method used to make a castling
/// move.  It is called from the main Position::do_move function.  Note that
/// castling moves are encoded as "king captures friendly rook" moves, for
/// instance white short castling in a non-Chess960 game is encoded as e1h1.

void Position::do_castle_move(Move m) {
  Color us, them;
  Square kfrom, kto, rfrom, rto;

  assert(this->is_ok());
  assert(move_is_ok(m));
  assert(move_is_castle(m));

  us = this->side_to_move();
  them = opposite_color(us);

  // Find source squares for king and rook:
  kfrom = move_from(m);
  rfrom = move_to(m);  // HACK: See comment at beginning of function.

  assert(this->piece_on(kfrom) == king_of_color(us));
  assert(this->piece_on(rfrom) == rook_of_color(us));

  // Find destination squares for king and rook:
  if(rfrom > kfrom) { // O-O
    kto = relative_square(us, SQ_G1);
    rto = relative_square(us, SQ_F1);
  }
  else { // O-O-O
    kto = relative_square(us, SQ_C1);
    rto = relative_square(us, SQ_D1);
  }

  // Remove pieces from source squares:
  clear_bit(&(byColorBB[us]), kfrom);
  clear_bit(&(byTypeBB[KING]), kfrom);
  clear_bit(&(byTypeBB[0]), kfrom); // HACK: byTypeBB[0] == occupied squares
  clear_bit(&(byColorBB[us]), rfrom);
  clear_bit(&(byTypeBB[ROOK]), rfrom);
  clear_bit(&(byTypeBB[0]), rfrom); // HACK: byTypeBB[0] == occupied squares

  // Put pieces on destination squares:
  set_bit(&(byColorBB[us]), kto);
  set_bit(&(byTypeBB[KING]), kto);
  set_bit(&(byTypeBB[0]), kto); // HACK: byTypeBB[0] == occupied squares
  set_bit(&(byColorBB[us]), rto);
  set_bit(&(byTypeBB[ROOK]), rto);
  set_bit(&(byTypeBB[0]), rto); // HACK: byTypeBB[0] == occupied squares

  // Update board array:
  board[kfrom] = board[rfrom] = EMPTY;
  board[kto] = king_of_color(us);
  board[rto] = rook_of_color(us);

  // Update king square:
  kingSquare[us] = kto;

  // Update piece lists:
  pieceList[us][KING][index[kfrom]] = kto;
  pieceList[us][ROOK][index[rfrom]] = rto;
  int tmp = index[rfrom];
  index[kto] = index[kfrom];
  index[rto] = tmp;

  // Update incremental scores:
  mgValue -= this->mg_pst(us, KING, kfrom);
  mgValue += this->mg_pst(us, KING, kto);
  egValue -= this->eg_pst(us, KING, kfrom);
  egValue += this->eg_pst(us, KING, kto);
  mgValue -= this->mg_pst(us, ROOK, rfrom);
  mgValue += this->mg_pst(us, ROOK, rto);
  egValue -= this->eg_pst(us, ROOK, rfrom);
  egValue += this->eg_pst(us, ROOK, rto);

  // Update hash key:
  key ^= zobrist[us][KING][kfrom] ^ zobrist[us][KING][kto];
  key ^= zobrist[us][ROOK][rfrom] ^ zobrist[us][ROOK][rto];

  // Clear en passant square:
  if(epSquare != SQ_NONE) {
    key ^= zobEp[epSquare];
    epSquare = SQ_NONE;
  }

  // Update castling rights:
  key ^= zobCastle[castleRights];
  castleRights &= castleRightsMask[kfrom];
  key ^= zobCastle[castleRights];

  // Reset rule 50 counter:
  rule50 = 0;

  // Update checkers BB:
  checkersBB = attacks_to(this->king_square(them), us);
}


/// Position::do_promotion_move() is a private method used to make a promotion
/// move.  It is called from the main Position::do_move function.  The
/// UndoInfo object, which has been initialized in Position::do_move, is
/// used to store the captured piece (if any).

void Position::do_promotion_move(Move m, UndoInfo &u) {
  Color us, them;
  Square from, to;
  PieceType capture, promotion;

  assert(this->is_ok());
  assert(move_is_ok(m));
  assert(move_promotion(m));

  us = this->side_to_move();
  them = opposite_color(us);

  from = move_from(m);
  to = move_to(m);

  assert(pawn_rank(us, to) == RANK_8);
  assert(this->piece_on(from) == pawn_of_color(us));
  assert(this->color_of_piece_on(to) == them || this->square_is_empty(to));

  capture = this->type_of_piece_on(to);

  if(capture) {
    assert(capture != KING);

    // Remove captured piece:
    clear_bit(&(byColorBB[them]), to);
    clear_bit(&(byTypeBB[capture]), to);

    // Update hash key:
    key ^= zobrist[them][capture][to];

    // Update incremental scores:
    mgValue -= this->mg_pst(them, capture, to);
    egValue -= this->eg_pst(them, capture, to);

    // Update material.  Because our move is a promotion, we know that the
    // captured piece is not a pawn.
    assert(capture != PAWN);
    npMaterial[them] -= piece_value_midgame(capture);

    // Update material hash key:
    materialKey ^= zobMaterial[them][capture][pieceCount[them][capture]];

    // Update piece count:
    pieceCount[them][capture]--;

    // Update piece list:
    pieceList[them][capture][index[to]] =
      pieceList[them][capture][pieceCount[them][capture]];
    index[pieceList[them][capture][index[to]]] = index[to];

    // Remember the captured piece, in order to be able to undo the move
    // correctly:
    u.capture = capture;
  }

  // Remove pawn:
  clear_bit(&(byColorBB[us]), from);
  clear_bit(&(byTypeBB[PAWN]), from);
  clear_bit(&(byTypeBB[0]), from); // HACK: byTypeBB[0] == occupied squares
  board[from] = EMPTY;

  // Insert promoted piece:
  promotion = move_promotion(m);
  assert(promotion >= KNIGHT && promotion <= QUEEN);
  set_bit(&(byColorBB[us]), to);
  set_bit(&(byTypeBB[promotion]), to);
  set_bit(&(byTypeBB[0]), to); // HACK: byTypeBB[0] == occupied squares
  board[to] = piece_of_color_and_type(us, promotion);

  // Update hash key:
  key ^= zobrist[us][PAWN][from] ^ zobrist[us][promotion][to];

  // Update pawn hash key:
  pawnKey ^= zobrist[us][PAWN][from];

  // Update material key:
  materialKey ^= zobMaterial[us][PAWN][pieceCount[us][PAWN]];
  materialKey ^= zobMaterial[us][promotion][pieceCount[us][promotion]+1];

  // Update piece counts:
  pieceCount[us][PAWN]--;
  pieceCount[us][promotion]++;

  // Update piece lists:
  pieceList[us][PAWN][index[from]] =
    pieceList[us][PAWN][pieceCount[us][PAWN]];
  index[pieceList[us][PAWN][index[from]]] = index[from];
  pieceList[us][promotion][pieceCount[us][promotion] - 1] = to;
  index[to] = pieceCount[us][promotion] - 1;

  // Update incremental scores:
  mgValue -= this->mg_pst(us, PAWN, from);
  mgValue += this->mg_pst(us, promotion, to);
  egValue -= this->eg_pst(us, PAWN, from);
  egValue += this->eg_pst(us, promotion, to);

  // Update material:
  npMaterial[us] += piece_value_midgame(promotion);

  // Clear the en passant square:
  if(epSquare != SQ_NONE) {
    key ^= zobEp[epSquare];
    epSquare = SQ_NONE;
  }

  // Update castle rights:
  key ^= zobCastle[castleRights];
  castleRights &= castleRightsMask[to];
  key ^= zobCastle[castleRights];

  // Reset rule 50 counter:
  rule50 = 0;

  // Update checkers BB:
  checkersBB = attacks_to(this->king_square(them), us);
}


/// Position::do_ep_move() is a private method used to make an en passant
/// capture.  It is called from the main Position::do_move function.  Because
/// the captured piece is always a pawn, we don't need to pass an UndoInfo
/// object in which to store the captured piece.

void Position::do_ep_move(Move m) {
  Color us, them;
  Square from, to, capsq;

  assert(this->is_ok());
  assert(move_is_ok(m));
  assert(move_is_ep(m));

  us = this->side_to_move();
  them = opposite_color(us);

  // Find from, to and capture squares:
  from = move_from(m);
  to = move_to(m);
  capsq = (us == WHITE)? (to - DELTA_N) : (to - DELTA_S);

  assert(to == epSquare);
  assert(pawn_rank(us, to) == RANK_6);
  assert(this->piece_on(to) == EMPTY);
  assert(this->piece_on(from) == pawn_of_color(us));
  assert(this->piece_on(capsq) == pawn_of_color(them));

  // Remove captured piece:
  clear_bit(&(byColorBB[them]), capsq);
  clear_bit(&(byTypeBB[PAWN]), capsq);
  clear_bit(&(byTypeBB[0]), capsq); // HACK: byTypeBB[0] == occupied squares
  board[capsq] = EMPTY;

  // Remove moving piece from source square:
  clear_bit(&(byColorBB[us]), from);
  clear_bit(&(byTypeBB[PAWN]), from);
  clear_bit(&(byTypeBB[0]), from); // HACK: byTypeBB[0] == occupied squares

  // Put moving piece on destination square:
  set_bit(&(byColorBB[us]), to);
  set_bit(&(byTypeBB[PAWN]), to);
  set_bit(&(byTypeBB[0]), to); // HACK: byTypeBB[0] == occupied squares
  board[to] = board[from];
  board[from] = EMPTY;

  // Update material hash key:
  materialKey ^= zobMaterial[them][PAWN][pieceCount[them][PAWN]];

  // Update piece count:
  pieceCount[them][PAWN]--;

  // Update piece list:
  pieceList[us][PAWN][index[from]] = to;
  index[to] = index[from];
  pieceList[them][PAWN][index[capsq]] =
    pieceList[them][PAWN][pieceCount[them][PAWN]];
  index[pieceList[them][PAWN][index[capsq]]] = index[capsq];

  // Update hash key:
  key ^= zobrist[us][PAWN][from] ^ zobrist[us][PAWN][to];
  key ^= zobrist[them][PAWN][capsq];
  key ^= zobEp[epSquare];

  // Update pawn hash key:
  pawnKey ^= zobrist[us][PAWN][from] ^ zobrist[us][PAWN][to];
  pawnKey ^= zobrist[them][PAWN][capsq];

  // Update incremental scores:
  mgValue -= this->mg_pst(them, PAWN, capsq);
  mgValue -= this->mg_pst(us, PAWN, from);
  mgValue += this->mg_pst(us, PAWN, to);
  egValue -= this->eg_pst(them, PAWN, capsq);
  egValue -= this->eg_pst(us, PAWN, from);
  egValue += this->eg_pst(us, PAWN, to);

  // Reset en passant square:
  epSquare = SQ_NONE;

  // Reset rule 50 counter:
  rule50 = 0;

  // Update checkers BB:
  checkersBB = attacks_to(this->king_square(them), us);
}


/// Position::undo_move() unmakes a move.  When it returns, the position should
/// be restored to exactly the same state as before the move was made.  It is
/// important that Position::undo_move is called with the same move and UndoInfo
/// object as the earlier call to Position::do_move.

void Position::undo_move(Move m, const UndoInfo &u) {
  assert(this->is_ok());
  assert(move_is_ok(m));

  gamePly--;
  sideToMove = opposite_color(sideToMove);

  // Restore information from our UndoInfo object (except the captured piece,
  // which is taken care of later):
  this->restore(u);

  if(move_is_castle(m))
    this->undo_castle_move(m);
  else if(move_promotion(m))
    this->undo_promotion_move(m, u);
  else if(move_is_ep(m))
    this->undo_ep_move(m);
  else {
    Color us, them;
    Square from, to;
    PieceType piece, capture;

    us = this->side_to_move();
    them = opposite_color(us);

    from = move_from(m);
    to = move_to(m);

    assert(this->piece_on(from) == EMPTY);
    assert(color_of_piece_on(to) == us);

    // Put the piece back at the source square:
    piece = this->type_of_piece_on(to);
    set_bit(&(byColorBB[us]), from);
    set_bit(&(byTypeBB[piece]), from);
    set_bit(&(byTypeBB[0]), from); // HACK: byTypeBB[0] == occupied squares
    board[from] = piece_of_color_and_type(us, piece);

    // Clear the destination square
    clear_bit(&(byColorBB[us]), to);
    clear_bit(&(byTypeBB[piece]), to);
    clear_bit(&(byTypeBB[0]), to); // HACK: byTypeBB[0] == occupied squares

    // If the moving piece was a king, update the king square:
    if(piece == KING)
      kingSquare[us] = from;

    // Update piece list:
    pieceList[us][piece][index[to]] = from;
    index[from] = index[to];

    capture = u.capture;

    if(capture) {
      assert(capture != KING);
      // Replace the captured piece:
      set_bit(&(byColorBB[them]), to);
      set_bit(&(byTypeBB[capture]), to);
      set_bit(&(byTypeBB[0]), to);
      board[to] = piece_of_color_and_type(them, capture);

      // Update material:
      if(capture != PAWN)
        npMaterial[them] += piece_value_midgame(capture);

      // Update piece list:
      pieceList[them][capture][pieceCount[them][capture]] = to;
      index[to] = pieceCount[them][capture];

      // Update piece count:
      pieceCount[them][capture]++;
    }
    else
      board[to] = EMPTY;
  }

  assert(this->is_ok());
}


/// Position::undo_castle_move() is a private method used to unmake a castling
/// move.  It is called from the main Position::undo_move function.  Note that
/// castling moves are encoded as "king captures friendly rook" moves, for
/// instance white short castling in a non-Chess960 game is encoded as e1h1.

void Position::undo_castle_move(Move m) {
  Color us;
  Square kfrom, kto, rfrom, rto;

  assert(move_is_ok(m));
  assert(move_is_castle(m));

  // When we have arrived here, some work has already been done by
  // Position::undo_move.  In particular, the side to move has been switched,
  // so the code below is correct.
  us = this->side_to_move();

  // Find source squares for king and rook:
  kfrom = move_from(m);
  rfrom = move_to(m);  // HACK: See comment at beginning of function.

  // Find destination squares for king and rook:
  if(rfrom > kfrom) { // O-O
    kto = relative_square(us, SQ_G1);
    rto = relative_square(us, SQ_F1);
  }
  else { // O-O-O
    kto = relative_square(us, SQ_C1);
    rto = relative_square(us, SQ_D1);
  }

  assert(this->piece_on(kto) == king_of_color(us));
  assert(this->piece_on(rto) == rook_of_color(us));

  // Remove pieces from destination squares:
  clear_bit(&(byColorBB[us]), kto);
  clear_bit(&(byTypeBB[KING]), kto);
  clear_bit(&(byTypeBB[0]), kto); // HACK: byTypeBB[0] == occupied squares
  clear_bit(&(byColorBB[us]), rto);
  clear_bit(&(byTypeBB[ROOK]), rto);
  clear_bit(&(byTypeBB[0]), rto); // HACK: byTypeBB[0] == occupied squares

  // Put pieces on source squares:
  set_bit(&(byColorBB[us]), kfrom);
  set_bit(&(byTypeBB[KING]), kfrom);
  set_bit(&(byTypeBB[0]), kfrom); // HACK: byTypeBB[0] == occupied squares
  set_bit(&(byColorBB[us]), rfrom);
  set_bit(&(byTypeBB[ROOK]), rfrom);
  set_bit(&(byTypeBB[0]), rfrom); // HACK: byTypeBB[0] == occupied squares

  // Update board:
  board[rto] = board[kto] = EMPTY;
  board[rfrom] = rook_of_color(us);
  board[kfrom] = king_of_color(us);

  // Update king square:
  kingSquare[us] = kfrom;

  // Update piece lists:
  pieceList[us][KING][index[kto]] = kfrom;
  pieceList[us][ROOK][index[rto]] = rfrom;
  int tmp = index[rto];  // Necessary because we may have rto == kfrom in FRC.
  index[kfrom] = index[kto];
  index[rfrom] = tmp;
}


/// Position::undo_promotion_move() is a private method used to unmake a
/// promotion move.  It is called from the main Position::do_move
/// function.  The UndoInfo object, which has been initialized in
/// Position::do_move, is used to put back the captured piece (if any).

void Position::undo_promotion_move(Move m, const UndoInfo &u) {
  Color us, them;
  Square from, to;
  PieceType capture, promotion;

  assert(move_is_ok(m));
  assert(move_promotion(m));

  // When we have arrived here, some work has already been done by
  // Position::undo_move.  In particular, the side to move has been switched,
  // so the code below is correct.
  us = this->side_to_move();
  them = opposite_color(us);

  from = move_from(m);
  to = move_to(m);

  assert(pawn_rank(us, to) == RANK_8);
  assert(this->piece_on(from) == EMPTY);

  // Remove promoted piece:
  promotion = move_promotion(m);
  assert(this->piece_on(to)==piece_of_color_and_type(us, promotion));
  assert(promotion >= KNIGHT && promotion <= QUEEN);
  clear_bit(&(byColorBB[us]), to);
  clear_bit(&(byTypeBB[promotion]), to);
  clear_bit(&(byTypeBB[0]), to); // HACK: byTypeBB[0] == occupied squares

  // Insert pawn at source square:
  set_bit(&(byColorBB[us]), from);
  set_bit(&(byTypeBB[PAWN]), from);
  set_bit(&(byTypeBB[0]), from); // HACK: byTypeBB[0] == occupied squares
  board[from] = pawn_of_color(us);

  // Update material:
  npMaterial[us] -= piece_value_midgame(promotion);

  // Update piece list:
  pieceList[us][PAWN][pieceCount[us][PAWN]] = from;
  index[from] = pieceCount[us][PAWN];
  pieceList[us][promotion][index[to]] =
    pieceList[us][promotion][pieceCount[us][promotion] - 1];
  index[pieceList[us][promotion][index[to]]] = index[to];

  // Update piece counts:
  pieceCount[us][promotion]--;
  pieceCount[us][PAWN]++;

  capture = u.capture;
  if(capture) {
    assert(capture != KING);

    // Insert captured piece:
    set_bit(&(byColorBB[them]), to);
    set_bit(&(byTypeBB[capture]), to);
    set_bit(&(byTypeBB[0]), to); // HACK: byTypeBB[0] == occupied squares
    board[to] = piece_of_color_and_type(them, capture);

    // Update material.  Because the move is a promotion move, we know
    // that the captured piece cannot be a pawn.
    assert(capture != PAWN);
    npMaterial[them] += piece_value_midgame(capture);

    // Update piece list:
    pieceList[them][capture][pieceCount[them][capture]] = to;
    index[to] = pieceCount[them][capture];

    // Update piece count:
    pieceCount[them][capture]++;
  }
  else
    board[to] = EMPTY;
}


/// Position::undo_ep_move() is a private method used to unmake an en passant
/// capture.  It is called from the main Position::undo_move function.  Because
/// the captured piece is always a pawn, we don't need to pass an UndoInfo
/// object from which to retrieve the captured piece.

void Position::undo_ep_move(Move m) {
  Color us, them;
  Square from, to, capsq;

  assert(move_is_ok(m));
  assert(move_is_ep(m));

  // When we have arrived here, some work has already been done by
  // Position::undo_move.  In particular, the side to move has been switched,
  // so the code below is correct.
  us = this->side_to_move();
  them = opposite_color(us);

  // Find from, to and captures squares:
  from = move_from(m);
  to = move_to(m);
  capsq = (us == WHITE)? (to - DELTA_N) : (to - DELTA_S);

  assert(to == this->ep_square());
  assert(pawn_rank(us, to) == RANK_6);
  assert(this->piece_on(to) == pawn_of_color(us));
  assert(this->piece_on(from) == EMPTY);
  assert(this->piece_on(capsq) == EMPTY);

  // Replace captured piece:
  set_bit(&(byColorBB[them]), capsq);
  set_bit(&(byTypeBB[PAWN]), capsq);
  set_bit(&(byTypeBB[0]), capsq);
  board[capsq] = pawn_of_color(them);

  // Remove moving piece from destination square:
  clear_bit(&(byColorBB[us]), to);
  clear_bit(&(byTypeBB[PAWN]), to);
  clear_bit(&(byTypeBB[0]), to);
  board[to] = EMPTY;

  // Replace moving piece at source square:
  set_bit(&(byColorBB[us]), from);
  set_bit(&(byTypeBB[PAWN]), from);
  set_bit(&(byTypeBB[0]), from);
  board[from] = pawn_of_color(us);

  // Update piece list:
  pieceList[us][PAWN][index[to]] = from;
  index[from] = index[to];
  pieceList[them][PAWN][pieceCount[them][PAWN]] = capsq;
  index[capsq] = pieceCount[them][PAWN];

  // Update piece count:
  pieceCount[them][PAWN]++;
}


/// Position::do_null_move makes() a "null move": It switches the side to move
/// and updates the hash key without executing any move on the board.

void Position::do_null_move(UndoInfo &u) {
  assert(this->is_ok());
  assert(!this->is_check());

  // Back up the information necessary to undo the null move to the supplied
  // UndoInfo object.  In the case of a null move, the only thing we need to
  // remember is the last move made and the en passant square.
  u.lastMove = lastMove;
  u.epSquare = epSquare;

  // Save the current key to the history[] array, in order to be able to
  // detect repetition draws:
  history[gamePly] = key;

  // Update the necessary information.
  sideToMove = opposite_color(sideToMove);
  if(epSquare != SQ_NONE)
    key ^= zobEp[epSquare];
  epSquare = SQ_NONE;
  rule50++;
  gamePly++;
  key ^= zobSideToMove;

  mgValue += (sideToMove == WHITE)? TempoValueMidgame : -TempoValueMidgame;
  egValue += (sideToMove == WHITE)? TempoValueEndgame : -TempoValueEndgame;

  assert(this->is_ok());
}


/// Position::undo_null_move() unmakes a "null move".

void Position::undo_null_move(const UndoInfo &u) {
  assert(this->is_ok());
  assert(!this->is_check());

  // Restore information from the supplied UndoInfo object:
  lastMove = u.lastMove;
  epSquare = u.epSquare;
  if(epSquare != SQ_NONE)
    key ^= zobEp[epSquare];

  // Update the necessary information.
  sideToMove = opposite_color(sideToMove);
  rule50--;
  gamePly--;
  key ^= zobSideToMove;

  mgValue += (sideToMove == WHITE)? TempoValueMidgame : -TempoValueMidgame;
  egValue += (sideToMove == WHITE)? TempoValueEndgame : -TempoValueEndgame;

  assert(this->is_ok());
}


/// Position::see() is a static exchange evaluator:  It tries to estimate the
/// material gain or loss resulting from a move.  There are two versions of
/// this function: One which takes a move as input, and one which takes a
/// 'from' and a 'to' square.  The function does not yet understand promotions
/// or en passant captures.

int Position::see(Square from, Square to) const {
  // Approximate material values, with pawn = 1:
  static const int seeValues[18] = {
    0, 1, 3, 3, 5, 10, 100, 0, 0, 1, 3, 3, 5, 10, 100, 0, 0, 0
  };
  Color us, them;
  Piece piece, capture;
  Bitboard attackers, occ, b;

  assert(square_is_ok(from));
  assert(square_is_ok(to));

  // Initialize colors:
  us = this->color_of_piece_on(from);
  them = opposite_color(us);

  // Initialize pieces:
  piece = this->piece_on(from);
  capture = this->piece_on(to);

  // Find all attackers to the destination square, with the moving piece
  // removed, but possibly an X-ray attacker added behind it:
  occ = this->occupied_squares();
  clear_bit(&occ, from);
  attackers =
    (rook_attacks_bb(to, occ) & this->rooks_and_queens()) |
    (bishop_attacks_bb(to, occ) & this->bishops_and_queens()) |
    (this->knight_attacks(to) & this->knights()) |
    (this->king_attacks(to) & this->kings()) |
    (this->white_pawn_attacks(to) & this->pawns(BLACK)) |
    (this->black_pawn_attacks(to) & this->pawns(WHITE));
  attackers &= occ;

  // If the opponent has no attackers, we are finished:
  if((attackers & this->pieces_of_color(them)) == EmptyBoardBB)
    return seeValues[capture];

  // The destination square is defended, which makes things rather more
  // difficult to compute.  We proceed by building up a "swap list" containing
  // the material gain or loss at each stop in a sequence of captures to the
  // destianation square, where the sides alternately capture, and always
  // capture with the least valuable piece.  After each capture, we look for
  // new X-ray attacks from behind the capturing piece.
  int lastCapturingPieceValue = seeValues[piece];
  int swapList[32], n = 1;
  Color c = them;
  PieceType pt;

  swapList[0] = seeValues[capture];

  do {
    // Locate the least valuable attacker for the side to move.  The loop
    // below looks like it is potentially infinite, but it isn't.  We know
    // that the side to move still has at least one attacker left.
    for(pt = PAWN; !(attackers&this->pieces_of_color_and_type(c, pt)); pt++)
      assert(pt < KING);

    // Remove the attacker we just found from the 'attackers' bitboard,
    // and scan for new X-ray attacks behind the attacker:
    b = attackers & this->pieces_of_color_and_type(c, pt);
    occ ^= (b & -b);
    attackers |=
      (rook_attacks_bb(to, occ) & this->rooks_and_queens()) |
      (bishop_attacks_bb(to, occ) & this->bishops_and_queens());
    attackers &= occ;

    // Add the new entry to the swap list:
    assert(n < 32);
    swapList[n] = -swapList[n - 1] + lastCapturingPieceValue;
    n++;

    // Remember the value of the capturing piece, and change the side to move
    // before beginning the next iteration:
    lastCapturingPieceValue = seeValues[pt];
    c = opposite_color(c);

    // Stop after a king capture:
    if(pt == KING && (attackers & this->pieces_of_color(c))) {
      assert(n < 32);
      swapList[n++] = 100;
      break;
    }
  } while(attackers & this->pieces_of_color(c));

  // Having built the swap list, we negamax through it to find the best
  // achievable score from the point of view of the side to move:
  while(--n) swapList[n-1] = Min(-swapList[n], swapList[n-1]);

  return swapList[0];
}


int Position::see(Move m) const {
  assert(move_is_ok(m));
  return this->see(move_from(m), move_to(m));
}


/// Position::clear() erases the position object to a pristine state, with an
/// empty board, white to move, and no castling rights.

void Position::clear() {
  int i, j;

  for(i = 0; i < 64; i++) {
    board[i] = EMPTY;
    index[i] = 0;
  }

  for(i = 0; i < 2; i++)
    byColorBB[i] = EmptyBoardBB;

  for(i = 0; i < 7; i++) {
    byTypeBB[i] = EmptyBoardBB;
    pieceCount[0][i] = pieceCount[1][i] = 0;
    for(j = 0; j < 8; j++)
      pieceList[0][i][j] = pieceList[1][i][j] = SQ_NONE;
  }

  checkersBB = EmptyBoardBB;

  lastMove = MOVE_NONE;

  sideToMove = WHITE;
  castleRights = NO_CASTLES;
  initialKFile = FILE_E;
  initialKRFile = FILE_H;
  initialQRFile = FILE_A;
  epSquare = SQ_NONE;
  rule50 = 0;
  gamePly = 0;
}


/// Position::reset_game_ply() simply sets gamePly to 0.  It is used from the
/// UCI interface code, whenever a non-reversible move is made in a
/// 'position fen <fen> moves m1 m2 ...' command.  This makes it possible
/// for the program to handle games of arbitrary length, as long as the GUI
/// handles draws by the 50 move rule correctly.

void Position::reset_game_ply() {
  gamePly = 0;
}


/// Position::put_piece() puts a piece on the given square of the board,
/// updating the board array, bitboards, and piece counts.

void Position::put_piece(Piece p, Square s) {
  Color c = color_of_piece(p);
  PieceType pt = type_of_piece(p);

  board[s] = p;
  index[s] = pieceCount[c][pt];
  pieceList[c][pt][index[s]] = s;

  set_bit(&(byTypeBB[pt]), s);
  set_bit(&(byColorBB[c]), s);
  set_bit(&byTypeBB[0], s); // HACK: byTypeBB[0] contains all occupied squares.

  pieceCount[c][pt]++;

  if(pt == KING)
    kingSquare[c] = s;
}


/// Position::allow_oo() gives the given side the right to castle kingside.
/// Used when setting castling rights during parsing of FEN strings.

void Position::allow_oo(Color c) {
  castleRights |= (1 + int(c));
}


/// Position::allow_ooo() gives the given side the right to castle queenside.
/// Used when setting castling rights during parsing of FEN strings.

void Position::allow_ooo(Color c) {
  castleRights |= (4 + 4*int(c));
}


/// Position::compute_key() computes the hash key of the position.  The hash
/// key is usually updated incrementally as moves are made and unmade, the
/// compute_key() function is only used when a new position is set up, and
/// to verify the correctness of the hash key when running in debug mode.

Key Position::compute_key() const {
  Key result = Key(0ULL);

  for(Square s = SQ_A1; s <= SQ_H8; s++)
    if(this->square_is_occupied(s))
      result ^=
        zobrist[this->color_of_piece_on(s)][this->type_of_piece_on(s)][s];

  if(this->ep_square() != SQ_NONE)
    result ^= zobEp[this->ep_square()];
  result ^= zobCastle[castleRights];
  if(this->side_to_move() == BLACK) result ^= zobSideToMove;

  return result;
}


/// Position::compute_pawn_key() computes the hash key of the position.  The
/// hash key is usually updated incrementally as moves are made and unmade,
/// the compute_pawn_key() function is only used when a new position is set
/// up, and to verify the correctness of the pawn hash key when running in
/// debug mode.

Key Position::compute_pawn_key() const {
  Key result = Key(0ULL);
  Bitboard b;
  Square s;

  for(Color c = WHITE; c <= BLACK; c++) {
    b = this->pawns(c);
    while(b) {
      s = pop_1st_bit(&b);
      result ^= zobrist[c][PAWN][s];
    }
  }
  return result;
}


/// Position::compute_material_key() computes the hash key of the position.
/// The hash key is usually updated incrementally as moves are made and unmade,
/// the compute_material_key() function is only used when a new position is set
/// up, and to verify the correctness of the material hash key when running in
/// debug mode.

Key Position::compute_material_key() const {
  Key result = Key(0ULL);
  for(Color c = WHITE; c <= BLACK; c++)
    for(PieceType pt = PAWN; pt <= QUEEN; pt++) {
      int count = this->piece_count(c, pt);
      for(int i = 0; i <= count; i++)
        result ^= zobMaterial[c][pt][i];
    }
  return result;
}


/// Position::compute_mg_value() and Position::compute_eg_value() compute the
/// incremental scores for the middle game and the endgame.  These functions
/// are used to initialize the incremental scores when a new position is set
/// up, and to verify that the scores are correctly updated by do_move
/// and undo_move when the program is running in debug mode.

Value Position::compute_mg_value() const {
  Value result = Value(0);
  Bitboard b;
  Square s;

  for(Color c = WHITE; c <= BLACK; c++)
    for(PieceType pt = PAWN; pt <= KING; pt++) {
      b = this->pieces_of_color_and_type(c, pt);
      while(b) {
        s = pop_1st_bit(&b);
        assert(this->piece_on(s) == piece_of_color_and_type(c, pt));
        result += this->mg_pst(c, pt, s);
      }
    }
  result += (this->side_to_move() == WHITE)?
    (TempoValueMidgame / 2) : -(TempoValueMidgame / 2);
  return result;
}

Value Position::compute_eg_value() const {
  Value result = Value(0);
  Bitboard b;
  Square s;

  for(Color c = WHITE; c <= BLACK; c++)
    for(PieceType pt = PAWN; pt <= KING; pt++) {
      b = this->pieces_of_color_and_type(c, pt);
      while(b) {
        s = pop_1st_bit(&b);
        assert(this->piece_on(s) == piece_of_color_and_type(c, pt));
        result += this->eg_pst(c, pt, s);
      }
    }
  result += (this->side_to_move() == WHITE)?
    (TempoValueEndgame / 2) : -(TempoValueEndgame / 2);
  return result;
}


/// Position::compute_non_pawn_material() computes the total non-pawn middle
/// game material score for the given side.  Material scores are updated
/// incrementally during the search, this function is only used while
/// initializing a new Position object.

Value Position::compute_non_pawn_material(Color c) const {
  Value result = Value(0);
  Square s;

  for(PieceType pt = KNIGHT; pt <= QUEEN; pt++) {
    Bitboard b = this->pieces_of_color_and_type(c, pt);
    while(b) {
      s = pop_1st_bit(&b);
      assert(this->piece_on(s) == piece_of_color_and_type(c, pt));
      result += piece_value_midgame(pt);
    }
  }
  return result;
}


/// Position::is_mate() returns true or false depending on whether the
/// side to move is checkmated.  Note that this function is currently very
/// slow, and shouldn't be used frequently inside the search.

bool Position::is_mate() {
  if(this->is_check()) {
    MovePicker mp = MovePicker(*this, false, MOVE_NONE, MOVE_NONE, MOVE_NONE,
                               MOVE_NONE, Depth(0));
    return mp.get_next_move() == MOVE_NONE;
  }
  else
    return false;
}


/// Position::is_draw() tests whether the position is drawn by material,
/// repetition, or the 50 moves rule.  It does not detect stalemates, this
/// must be done by the search.

bool Position::is_draw() const {
  // Draw by material?
  if(!this->pawns() &&
     this->non_pawn_material(WHITE) + this->non_pawn_material(BLACK)
     <= BishopValueMidgame)
    return true;

  // Draw by the 50 moves rule?
  if(rule50 > 100 || (rule50 == 100 && !this->is_check()))
    return true;

  // Draw by repetition?
  for(int i = 2; i < Min(gamePly, rule50); i += 2)
    if(history[gamePly - i] == key)
      return true;

  return false;
}


/// Position::is_immediate_draw() is similar to Position::is_draw(),
/// except that it is slower and more precise.  It requires a *third*
/// repeat for a repetition draw, and also detects stalemates.  The
/// return value is a DrawReason.  This function is not used by the
/// engine, but only by the iPhone GUI.

DrawReason Position::is_immediate_draw() const {

  // Draw by material?
  if(!this->pawns() &&
     this->non_pawn_material(WHITE) + this->non_pawn_material(BLACK)
     <= BishopValueMidgame)
    return DRAW_MATERIAL;

  // Draw by the 50 moves rule?
  if(rule50 > 100 || (rule50 == 100 && !this->is_check()))
    return DRAW_50_MOVES;

  // Draw by repetition?
  int repetitionCount = 0;
  for(int i = 2; i < Min(gamePly, rule50); i += 2)
    if(history[gamePly - i] == key) {
      repetitionCount++;
      if(repetitionCount == 2)
        return DRAW_REPETITION;
    }

  // Stalemate?
  Move moves[256];
  if(this->all_legal_moves(moves) == 0 && !this->is_check())
    return DRAW_STALEMATE;

  return NOT_DRAW;
}


/// Position::has_mate_threat() tests whether a given color has a mate in one
/// from the current position.  This function is quite slow, but it doesn't
/// matter, because it is currently only called from PV nodes, which are rare.

bool Position::has_mate_threat(Color c) {
  UndoInfo u1, u2;
  Color stm = this->side_to_move();

  // The following lines are useless and silly, but prevents gcc from
  // emitting a stupid warning stating that u1.lastMove and u1.epSquare might
  // be used uninitialized.
  u1.lastMove = lastMove;
  u1.epSquare = epSquare;

  if(this->is_check())
    return false;

  // If the input color is not equal to the side to move, do a null move
  if(c != stm) this->do_null_move(u1);

  MoveStack mlist[120];
  int count;
  bool result = false;

  // Generate legal moves
  count = generate_legal_moves(*this, mlist);

  // Loop through the moves, and see if one of them is mate.
  for(int i = 0; i < count; i++) {
    this->do_move(mlist[i].move, u2);
    if(this->is_mate()) result = true;
    this->undo_move(mlist[i].move, u2);
  }

  // Undo null move, if necessary
  if(c != stm) this->undo_null_move(u1);

  return result;
}


/// Position::init_zobrist() is a static member function which initializes the
/// various arrays used to compute hash keys.  Some of the initialization below
/// looks a little strange (the initialization of zobCastle[] particular)[]),
/// the explanation is that we want to get exactly the same hash keys as in
/// Glaurung 1.x, in order to be able to use the same book files.

void Position::init_zobrist() {

  for(Piece p = WP; p <= BK; p++)
    for(Square s = SQ_A1; s <= SQ_H8; s++)
      zobrist[color_of_piece(p)][type_of_piece(p)][s] = genrand_int64();

  zobEp[0] = 0ULL;
  for(int i = 1; i < 64; i++)
    zobEp[i] = genrand_int64();

  for(int i = 15; i >= 0; i--)
    zobCastle[(i&8) | (i&1) | ((i&2) << 1) | ((i&4) >> 1)] = genrand_int64();

  zobSideToMove = genrand_int64();

  for(int i = 0; i < 2; i++)
    for(int j = 0; j < 8; j++)
      for(int k = 0; k < 16; k++)
        zobMaterial[i][j][k] = (k > 0)? genrand_int64() : 0LL;

  for(int i = 0; i < 16; i++)
    zobMaterial[0][KING][i] = zobMaterial[1][KING][i] = 0ULL;
}


/// Position::init_piece_square_tables() initializes the piece square tables.
/// This is a two-step operation:  First, the white halves of the tables are
/// copied from the MgPST[][] and EgPST[][] arrays, with a small random number
/// added to each entry if the "Randomness" UCI parameter is non-zero.
/// Second, the black halves of the tables are initialized by mirroring
/// and changing the sign of the corresponding white scores.

void Position::init_piece_square_tables() {
  for(Square s = SQ_A1; s <= SQ_H8; s++) {
    for(Piece p = WP; p <= WK; p++) {
      MgPieceSquareTable[p][s] = Value(MgPST[p][s]);
      EgPieceSquareTable[p][s] = Value(EgPST[p][s]);
    }
  }
  for(Square s = SQ_A1; s <= SQ_H8; s++)
    for(Piece p = BP; p <= BK; p++) {
      MgPieceSquareTable[p][s] = -MgPieceSquareTable[p-8][flip_square(s)];
      EgPieceSquareTable[p][s] = -EgPieceSquareTable[p-8][flip_square(s)];
    }
}


/// Position::flipped_copy() makes a copy of the input position, but with
/// the white and black sides reversed.  This is only useful for debugging,
/// especially for finding evaluation symmetry bugs.

void Position::flipped_copy(const Position &pos) {
  assert(pos.is_ok());

  this->clear();

  // Board
  for(Square s = SQ_A1; s <= SQ_H8; s++)
    if(!pos.square_is_empty(s))
      this->put_piece(Piece(int(pos.piece_on(s)) ^ 8), flip_square(s));

  // Side to move
  sideToMove = opposite_color(pos.side_to_move());

  // Castling rights
  if(pos.can_castle_kingside(WHITE)) this->allow_oo(BLACK);
  if(pos.can_castle_queenside(WHITE)) this->allow_ooo(BLACK);
  if(pos.can_castle_kingside(BLACK)) this->allow_oo(WHITE);
  if(pos.can_castle_queenside(BLACK)) this->allow_ooo(WHITE);

  initialKFile = pos.initialKFile;
  initialKRFile = pos.initialKRFile;
  initialQRFile = pos.initialQRFile;

  for(Square sq = SQ_A1; sq <= SQ_H8; sq++)
    castleRightsMask[sq] = ALL_CASTLES;
  castleRightsMask[make_square(initialKFile, RANK_1)] ^= (WHITE_OO|WHITE_OOO);
  castleRightsMask[make_square(initialKFile, RANK_8)] ^= (BLACK_OO|BLACK_OOO);
  castleRightsMask[make_square(initialKRFile, RANK_1)] ^= WHITE_OO;
  castleRightsMask[make_square(initialKRFile, RANK_8)] ^= BLACK_OO;
  castleRightsMask[make_square(initialQRFile, RANK_1)] ^= WHITE_OOO;
  castleRightsMask[make_square(initialQRFile, RANK_8)] ^= BLACK_OOO;

  // En passant square
  if(pos.epSquare != SQ_NONE)
    epSquare = flip_square(pos.epSquare);

  // Checkers
  this->find_checkers();

  // Hash keys
  key = this->compute_key();
  pawnKey = this->compute_pawn_key();
  materialKey = this->compute_material_key();

  // Incremental scores
  mgValue = this->compute_mg_value();
  egValue = this->compute_eg_value();

  // Material
  npMaterial[WHITE] = this->compute_non_pawn_material(WHITE);
  npMaterial[BLACK] = this->compute_non_pawn_material(BLACK);

  assert(this->is_ok());
}


/// Position::moves_from() finds all legal moves from a given square. The moves
/// are stored in the array mlist[], and the return value of the function is
/// an int representing the number of legal moves from the square. This code is
/// entirely unoptimized, and is only used for the iPhone user interface.

int Position::moves_from(Square s, Move mlist[]) const {
  MoveStack moves[256];
  int i, j, n;

  assert(square_is_ok(s));

  n = generate_legal_moves(*this, moves);
  for(i = 0, j = 0; i < n; i++)
    if(move_from(moves[i].move) == s)
      mlist[j++] = moves[i].move;
  return j;
}


/// Position::moves_to() finds all legal moves to a given square. The moves
/// are stored in the array mlist[], and the return value of the function is
/// an int representing the number of legal moves to the square. This code is
/// entirely unoptimized, and is only used for the iPhone user interface.

int Position::moves_to(Square s, Move mlist[]) const {
  MoveStack moves[256];
  int i, j, n;

  assert(square_is_ok(s));

  n = generate_legal_moves(*this, moves);
  for(i = 0, j = 0; i < n; i++)
    if(move_to(moves[i].move) == s)
      mlist[j++] = moves[i].move;
  return j;
}


/// Position::destination_squares_from() finds all squares a piece on a given
/// squares can legally move to, and store the possible destination squares in
/// an array. The return value is the number of reachable squares. This code is
/// entirely unoptimized, and is only used for the iPhone user interface.

int Position::destination_squares_from(Square s, Square sqlist[]) const {
  Move moves[27];
  int i, n;

  assert(square_is_ok(s));
  n = this->moves_from(s, moves);
  assert(n <= 27);

  for(i = 0; i < n; i++)
    sqlist[i] = move_from(moves[i]);
  return n;
}


/// Position::all_legal_moves() generates all legal moves from the current
/// position, and saves them in the array mlist[]. The number of legal moves
/// is returned.  Used by the iPhone user interface.
int Position::all_legal_moves(Move mlist[]) const {
  MoveStack moves[256];
  int i, n;

  n = generate_legal_moves(*this, moves);
  for(i = 0; i < n; i++)
    mlist[i] = moves[i].move;
  return n;
}


/// Position::is_ok() performs some consitency checks for the position object.
/// This is meant to be helpful when debugging.

bool Position::is_ok(bool slow) const {

  // What features of the position should be verified?
  static const bool debugBitboards = false;
  static const bool debugKingCount = false;
  static const bool debugKingCapture = false;
  static const bool debugCheckerCount = false;
  static const bool debugKey = false;
  static const bool debugMaterialKey = false;
  static const bool debugPawnKey = false;
  static const bool debugIncrementalEval = false;
  static const bool debugNonPawnMaterial = false;
  static const bool debugPieceCounts = false;
  static const bool debugPieceList = false;

  // Side to move OK?
  if(!color_is_ok(this->side_to_move()))
    return false;

  // Are the king squares in the position correct?
  if(this->piece_on(this->king_square(WHITE)) != WK)
    return false;
  if(this->piece_on(this->king_square(BLACK)) != BK)
    return false;

  // Castle files OK?
  if(!file_is_ok(initialKRFile))
    return false;
  if(!file_is_ok(initialQRFile))
    return false;

  // Do both sides have exactly one king?
  if(slow || debugKingCount) {
    int kingCount[2] = {0, 0};
    for(Square s = SQ_A1; s <= SQ_H8; s++)
      if(this->type_of_piece_on(s) == KING)
        kingCount[this->color_of_piece_on(s)]++;
    if(kingCount[0] != 1 || kingCount[1] != 1)
      return false;
  }

  // Can the side to move capture the opponent's king?
  if(slow || debugKingCapture) {
    Color us = this->side_to_move();
    Color them = opposite_color(us);
    Square ksq = this->king_square(them);
    if(this->square_is_attacked(ksq, us))
      return false;
  }

  // Is there more than 2 checkers?
  if((slow || debugCheckerCount) && count_1s(checkersBB) > 2)
    return false;

  // Bitboards OK?
  if(slow || debugBitboards) {
    // The intersection of the white and black pieces must be empty:
    if((this->pieces_of_color(WHITE) & this->pieces_of_color(BLACK))
       != EmptyBoardBB)
      return false;

    // The union of the white and black pieces must be equal to all
    // occupied squares:
    if((this->pieces_of_color(WHITE) | this->pieces_of_color(BLACK))
       != this->occupied_squares())
      return false;

    // Separate piece type bitboards must have empty intersections:
    for(PieceType p1 = PAWN; p1 <= KING; p1++)
      for(PieceType p2 = PAWN; p2 <= KING; p2++)
        if(p1 != p2 && (this->pieces_of_type(p1) & this->pieces_of_type(p2)))
          return false;
  }

  // En passant square OK?
  if(this->ep_square() != SQ_NONE) {
    // The en passant square must be on rank 6, from the point of view of the
    // side to move.
    if(pawn_rank(this->side_to_move(), this->ep_square()) != RANK_6)
      return false;
  }

  // Hash key OK?
  if(debugKey && key != this->compute_key())
    return false;

  // Pawn hash key OK?
  if(debugPawnKey && pawnKey != this->compute_pawn_key())
    return false;

  // Material hash key OK?
  if(debugMaterialKey && materialKey != this->compute_material_key())
    return false;

  // Incremental eval OK?
  if(debugIncrementalEval) {
    if(mgValue != this->compute_mg_value())
      return false;
    if(egValue != this->compute_eg_value())
      return false;
  }

  // Non-pawn material OK?
  if(debugNonPawnMaterial) {
    if(npMaterial[WHITE] != compute_non_pawn_material(WHITE))
      return false;
    if(npMaterial[BLACK] != compute_non_pawn_material(BLACK))
      return false;
  }

  // Piece counts OK?
  if(debugPieceCounts)
    for(Color c = WHITE; c <= BLACK; c++)
      for(PieceType pt = PAWN; pt <= KING; pt++)
        if(pieceCount[c][pt] != count_1s(this->pieces_of_color_and_type(c, pt)))
          return false;

  if(debugPieceList) {
    for(Color c = WHITE; c <= BLACK; c++)
      for(PieceType pt = PAWN; pt <= KING; pt++)
        for(int i = 0; i < pieceCount[c][pt]; i++) {
          if(this->piece_on(this->piece_list(c, pt, i)) !=
             piece_of_color_and_type(c, pt))
            return false;
          if(index[this->piece_list(c, pt, i)] != i)
            return false;
        }
  }

  return true;
}


bool Position::is_valid_fen(const std::string &fen) {
   std::istringstream iss(fen);
   std::string board, side, castleRights, ep;

   if (!iss) return false;

   iss >> board;

   if (!iss) return false;

   iss >> side;

   if (!iss) {
      castleRights = "-";
      ep = "-";
   } else {
      iss >> castleRights;
      if (iss)
         iss >> ep;
      else
         ep = "-";
   }

   // Let's check that all components of the supposed FEN are OK.
   if (side != "w" && side != "b") return false;
   if (castleRights != "-" && castleRights != "K" && castleRights != "Kk"
       && castleRights != "Kkq" && castleRights != "Kq" && castleRights !="KQ"
       && castleRights != "KQk" && castleRights != "KQq" && castleRights != "KQkq"
       && castleRights != "k" && castleRights != "q" && castleRights != "kq"
       && castleRights != "Q" && castleRights != "Qk" && castleRights != "Qq"
       && castleRights != "Qkq")
      return false;
   if (ep != "-") {
      if (ep.length() != 2) return false;
      if (!(ep[0] >= 'a' && ep[0] <= 'h')) return false;
      if (!((side == "w" && ep[1] == '6') || (side == "b" && ep[1] == '3')))
         return false;
   }

   // The tricky part: The board.
   // Seven slashes?
   if (std::count(board.begin(), board.end(), '/') != 7) return false;
   // Only legal characters?
   for (int i = 0; i < board.length(); i++)
      if (!(board[i] == '/' || (board[i] >= '1' && board[i] <= '8')
            || piece_type_is_ok(piece_type_from_char(board[i]))))
         return false;
   // Exactly one king per side?
   if (std::count(board.begin(), board.end(), 'K') != 1) return false;
   if (std::count(board.begin(), board.end(), 'k') != 1) return false;
   // Other piece counts reasonable?
   size_t wp = std::count(board.begin(), board.end(), 'P'),
      bp = std::count(board.begin(), board.end(), 'p'),
      wn = std::count(board.begin(), board.end(), 'N'),
      bn = std::count(board.begin(), board.end(), 'n'),
      wb = std::count(board.begin(), board.end(), 'B'),
      bb = std::count(board.begin(), board.end(), 'b'),
      wr = std::count(board.begin(), board.end(), 'R'),
      br = std::count(board.begin(), board.end(), 'r'),
      wq = std::count(board.begin(), board.end(), 'Q'),
      bq = std::count(board.begin(), board.end(), 'q');
   if (wp > 8 || bp > 8 || wn > 10 || bn > 10 || wb > 10 || bb > 10
       || wr > 10 || br > 10 || wq > 9 || bq > 10
       || wp + wn + wb + wr + wq > 15 || bp + bn + bb + br + bq > 15)
      return false;

   // OK, looks close enough to a legal position. Let's try to parse
   // the FEN and see!
   Position p;
   p.from_fen(board + " " + side + " " + castleRights + " " + ep);
   return p.is_ok(true);
}

}

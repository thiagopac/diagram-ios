////
//// Includes
////

#import "EngineController.h"

#include <iomanip>
#include <sstream>

#include "bitboard.h"
#include "endgame.h"
#include "evaluate.h"
#include "material.h"
#include "san.h"
#include "search.h"
#include "thread.h"
#include "tt.h"
#include "ucioption.h"

using std::string;

namespace {
  string CurrentMove;
  int CurrentMoveNumber, TotalMoveCount;
  int CurrentDepth;
}

////
//// Functions
////

extern void kpk_bitbase_init();

void engine_init() {
   UCI::init(Options);
   Bitboards::init();
   Position::init();
   Bitbases::init_kpk();
   Search::init();
   Pawns::init();
   Eval::init();
   Threads.init();
   TT.resize(Options["Hash"]);
}


void engine_exit() {
   Threads.exit();
}


void pv_to_ui(const string &pv, int depth, int score, int scoreType, bool mate) {
  NSString *string = [[NSString alloc]
                        initWithUTF8String: pv.c_str()];
   dispatch_async(dispatch_get_main_queue(), ^{
      [GlobalEngineController sendPV:string depth:depth score:score scoreType:scoreType
                                mate: (mate ? YES : NO)];
   });
}


void currmove_to_ui(const string currmove, int currmovenum, int movenum,
                    int depth) {
  CurrentMove = currmove;
  CurrentMoveNumber = currmovenum;
  CurrentDepth = depth;
  TotalMoveCount = movenum;
}


void searchstats_to_ui(int64_t nodes, long time) {

   dispatch_async(dispatch_get_main_queue(), ^{
      [GlobalEngineController
            sendCurrentMove:[NSString stringWithUTF8String:CurrentMove.c_str()]
          currentMoveNumber:CurrentMoveNumber
              numberOfMoves:TotalMoveCount
                      depth:CurrentDepth
                       time:time
                      nodes:nodes];
   });
}


void bestmove_to_ui(const string &best, const string &ponder) {
   NSString *bestString = [[NSString alloc] initWithUTF8String: best.c_str()];
   NSString *ponderString = [[NSString alloc] initWithUTF8String: ponder.c_str()];
  [GlobalEngineController sendBestMove: bestString
                            ponderMove: ponderString];
}


extern void execute_command(const string &command);

void command_to_engine(const string &command) {
   execute_command(command);
}


bool command_is_waiting() {
  return [GlobalEngineController commandIsWaiting];
}


string get_command() {
   return string([[GlobalEngineController getCommand] UTF8String]);
}

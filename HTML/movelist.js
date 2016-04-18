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


// HACK: Call Objective-C code by jumping to a fake URL, and
// use the URL to decide what to do on the Objective-C side.
var objcCall = function (category, command) {
   window.location = category + ':' + command
}


// Log to the console using NSLog, for debugging.
var nsLog = function (string) {
   objcCall('log', string)
}


// isOnscreen tests whether an element is currently visible on the screen.
var isOnscreen = function (element) {
   var top, e
   for (top = 0, e = element; e; top += e.offsetTop, e = e.offsetParent) { }
   return top >= window.pageYOffset &&
      top + element.offsetHeight <= (window.pageYOffset + window.innerHeight)
}


// scrollToPly scrolls the view in such a way that the move at the given ply
// is visible.
var scrollToPly = function (ply) {
   var element = document.anchors['ply' + Math.max(0, ply - 1)]
   if (!isOnscreen(element)) {
      window.location.hash = '#ply' + Math.max(0, ply - 1)
   }
}


// addMoveEventHandlers loops throgh all moves in the document and adds
// event handlers for detecting taps on moves and jumping to the right place
// in ghe game.
var addMoveEventHandlers = function () {
   var moves = document.getElementsByClassName('move'), m, i

   for (i = 0; i < moves.length; i++) {
      m = moves[i]

      ;(function () {

         var touchLeftMove
         var move = m

         move.addEventListener(
            'touchstart'
          , function () {
               touchLeftMove = false
               move.classList.add('selected')
            })

         // When the touch moves, check whether we have left the move element.
         move.addEventListener(
            'touchmove'
          , function (event) {
               var touch, x, y
               if (!touchLeftMove) {
                  touch = event.touches[0], x = touch.pageX, y = touch.pageY
                  if (document.elementFromPoint(x, y) !== move) {
                     touchLeftMove = true
                     move.classList.remove('selected')
                  }
               }
            })

         move.addEventListener(
            'touchend'
          , function (event) {
               if (!touchLeftMove) {
                  // Stop the event from propagating up to the document, in
                  // order to avoid misenterpreting this as a swiping gesture.
                  event.stopPropagation()
                  move.classList.remove('selected')
                  objcCall('jumpToPly', move.id.substring(3))
               }
            })
      } ())
   }
}


// Listen to touch events on the document object, in order to detect swiping
// gestures for making/unmaking moves.
;(function () {

   // Variables for tracking finger movements.
   var horizontalSwipe = true
   var touchStartX = 0, touchStartY = 0

   // When the user touches the view, remember the start point, which is used
   // to decide whether the user tried to swipe.
   document.addEventListener(
      'touchstart'
    , function (event) {
         var touch = event.touches[0]
         horizontalSwipe = true
         touchStartX = touch.screenX
         touchStartY = touch.screenY
      })

   // If the touch moves too far vertically, the user is probably trying to
   // scroll, and not to take back/replay a move.
   document.addEventListener(
      'touchmove'
    , function (event) {
         var touch = event.touches[0]
         if (horizontalSwipe &&
             Math.abs(touch.screenX - touchStartX) < 20 &&
             Math.abs(touch.screenY - touchStartY) > 40) {
            horizontalSwipe = false
         }
      })

   // When the touch ends, if the finger hasn't moved too far vertically,
   // and the slope of the line traced by the finger is 1/3 or less, we assume
   // that the user was trying to take back or replay a move.
   document.addEventListener(
      'touchend'
    , function (event) {
         var touch = event.changedTouches[0]
         if (horizontalSwipe &&
             Math.abs(touch.screenY - touchStartY) <= 40 &&
             Math.abs((touch.screenX - touchStartX) /
                      (touch.screenY - touchStartY)) >= 3) {
            if (touch.screenX - touchStartX < 0) {
               objcCall('navigate', 'back')
            } else if (touch.screenX - touchStartX > 0) {
               objcCall('navigate', 'forward')
            }
         }
      })


   // I don't know in what situations the 'touchcancel' event occurs. Log to
   // the console, just in order to detect when it happens.
   document.addEventListener(
      'touchcancel'
    , function () {
         nsLog('touch canceled')
      })

} ())

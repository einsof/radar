/*
Copyright (c) 2010 Trevor McCauley

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. 
*/
package com.senocular.display.transform {
	
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**
	 * Cursor for registration point controls.
	 * @author Trevor McCauley
	 */
	public class CursorRegistration extends Cursor {
		
		/**
		 * Constructor for creating new CursorRegistration instances.
		 */
		public function CursorRegistration() {
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			super.draw();
			graphics.clear();
			
			// don't draw anything if something
			// has been added as a child to
			// this display object as a "skin"
			if (numChildren) return;
			
			with (graphics){
				
				/*beginFill(0xFFFFFF, 1);
				lineStyle(1, 0x000000, 0);
				drawRect(-4,-1, 8, 2);
				drawRect(-1,-4, 2, 8);
				endFill();*/
				
				beginFill(0xFFFFFF, 1);
				lineStyle(1, 0x000000, 1);
				moveTo(-4, 0);
				lineTo(-2, 0);
				moveTo(2, 0);
				lineTo(4, 0);
				
				moveTo(0, -4);
				lineTo(0, -2);
				moveTo(0, 2);
				lineTo(0, 4);
				endFill();
				
			}
		}
	}	
}

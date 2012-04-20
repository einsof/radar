/**
 * Transform Manager, part of segfaultlabs AS3 library
 * Copyright (C) 2010, Mateusz Malczak (http://malczak.info)
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */
package com.segfaultlabs.transform 
{
	import com.segfaultlabs.ui.Mouse;
	import com.segfaultlabs.events.TransformEvent;
	import com.segfaultlabs.transform.TransformMode;
	import com.segfaultlabs.transform.interfaces.ITransformer;
	import com.segfaultlabs.transform.interfaces.ITransformable;
	
	import flash.display.BlendMode;
	import flash.display.CapsStyle;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.InteractiveObject;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/***
	 * Dispatched when transform manager is initialized. That is when new
	 * transformed is set and transformed manager is showed on screen.
	 * 
	 * @eventType com.segfaultsoft.events.TransformEvent.TRANSFORM_INIT
	 */
	[Event(name="transformInit", type="com.segfaultsoft.events.TransformEvent")]
	
	 /***
	 * Dispatched when transformation begins. That is after mouse button
	 * is pressed.
	 *
	 * @eventType com.segfaultsoft.events.TransformEvent.TRANSFORM_BEGIN
	 */	
	[Event(name="transformBegin", type="com.segfaultsoft.events.TransformEvent")]
	 
	 /***
	 * Dispatched when current transformation matrix is appended to transformer.
	 * But before transformed DisplayObject matrix is changed.
	 * 
	 * @eventType com.segfaultsoft.events.TransformEvent.TRANSFORM_APPEND
	 */	
	[Event(name="transformAppend", type="com.segfaultsoft.events.TransformEvent")]
	
	 /***
	 * Dispatched when transformation is finished. That is when mouse button
	 * is released.
	 * 
	 * @eventType com.segfaultsoft.events.TransformEvent.TRANSFORM_COMMIT
	 */	
	[Event(name="transformCommit", type="com.segfaultsoft.events.TransformEvent")]

	 /***
	 * Dispatched when mouse cursor should be changed. Mouse cursor changes when
	 * mouse pointer roll over or rolls out of any active area of transform manager.
	 * Active areas are rotate, scale, skew buttons.
	 *
	 * @eventType com.segfaultsoft.events.TransformEvent.TRANSFORM_CURSOR
	 */	
	[Event(name="transformCursor", type="com.segfaultsoft.events.TransformEvent")]
				
	/**
	 * Interactive transformation manager. Manager handles rotation, skew and scale in the same time.
	 * Type of operation depends on where mouse down event occures, active areas are ilustrated below
	 *
	 * <pre>
	 * (  r  )  skX       skX   (  r  )
	 *  -- [sc]-----[sc]------[sc] --
	 *  skY  |                  |  skY
	 *       |                  |  
	 *     [sc]     [pv]      [sc] 
	 *       |                  |  
	 *  skY  |                  |  skY
	 *  -- [sc]-----[sc]------[sc] --
	 * (  r  )  skX       skX   (  r  )
	 * 
	 * (r) - rotation
	 * (sc) - scale
	 * (sk) - skew X/Y
	 * (pv) - pivot point
	 * 	</pre>
	 *
	 * This manager can be used when all transformed objects have common parent. That is
	 * all transformed at the same time obejcts have to be placed on the same level.
	 * 
	 * @author Mateusz Malczak (http://malczak.info)
	 * 
	 */	
	public class TransformManager extends Sprite 
	{			
		static public const version : String = "1.0";
			
		/**
		 * Transformation 'center' button
		 */		
		static public var centerIcon  : Class;
		
		/**
		 * Transformation handle button 
		 */		
		static public var dotIcon 	  : Class;
								
		/**
		 * Objects initial matrix, extracted when user 
		 * initialized transformation
		 */		
		private var initm     : Matrix;  
		
		/**
		 * Objects total transformation matrix 
		 */
		private var totm 	  : Matrix;  		
		
		/**
		 * Invertion of the total transformation matrix 
		 */
		private var totmI	  : Matrix;  
		
		/**
		 * Current transformation matrix. This is transformation
		 * matrix change calculated when user moves mouse
		 */		
		private var curm      : Matrix;  
		
		/**
		 * buttons 
		 */		
		private var btns    : Array;
		
		/**
		 * transformation center points  
		 */
		private var p1	  : Point;  
		private var p2	  : Point;	
		
		/**
		 * 'center' point corrdinates in 
		 * trasform manager space 
		 */		
		private var perc    : Point;	
		
		/**
		 * center of transformed obejct 
		 */		
		private var pcenter : Point;	

		/**
		 * mouse down coordinates in 
		 * transform coordinate space 
		 */		
		private var mdt     : Point;    
		
		/**
		 * objects boundary box  
		 */		
		private var bbp0    : Point;
		private var bbp1 	: Point;
		private var bbp2 	: Point;
		private var bbp3    : Point;
					
		/**
		 * transformation mode 
		 */		
		private var _mode	  : uint;
		
		/**
		 * event to be dispatched when
		 * objects matrix is changed  
		 */		
		private var _cmevt    : Event; 	  
		
		/**
		 * objects that is currently transformed 
		 */		
		private var obj       : ITransformer; 
		
		/**
		 * level where transformation manager is placed 
		 */		
		private var _drawobj  : Sprite; 		
		
		/**
		 * level there all transformed objects are placed 
		 */		
		private var _oparent  : DisplayObjectContainer 

		/**
		 * skew x/y buttons 
		 */
 		private var skxlvl : Sprite;
		private var skylvl : Sprite;
		
		/**
		 * myVars
		 */
		private var _curBut : String;
		private var _cursorAngle : Number;
		private var _isScrew : Boolean = false;
		private var _isCenterPoint : Boolean = false;
		private var _notProportionalOnly : Boolean = false;
		private var _numPoints : uint;

		
		public function TransformManager()
		{
			super();
			init();
		}
		
		protected function init():void
		{
			var btnObj:Sprite;
			var obj:Sprite;
			var i:int;
            blendMode = BlendMode.INVERT;
			_mode = TransformMode.MODE_ALLOW_ALL | TransformMode.MODE_IDLE;
			curm = new Matrix();
						
					function createButton(name:String):void
					{
						btnObj = new Sprite();
						btnObj.name = name;
						btnObj.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true );
						addChild( btnObj );
						btns.push( btnObj );
                        //scaling button
						obj = new dotIcon();
						obj.addEventListener( MouseEvent.ROLL_OVER, manageCursor );
						obj.addEventListener( MouseEvent.ROLL_OUT, manageCursor );
						obj.name = name;
						btnObj.addChild( obj );
                        //rotation button
						obj = new Sprite();
						obj.addEventListener( MouseEvent.ROLL_OVER, manageCursor );
						obj.addEventListener( MouseEvent.ROLL_OUT, manageCursor );
						obj.name = "rotate";
						btnObj.addChildAt( obj, 0 )

					};
					
			btns = new Array();			
			
            //skew areas
			if(_isScrew){
				skxlvl = new Sprite();
					skxlvl.addEventListener( MouseEvent.ROLL_OVER, manageCursor );
					skxlvl.addEventListener( MouseEvent.ROLL_OUT, manageCursor );
					skxlvl.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
				skxlvl.name = "skxlvl";
				addChild( skxlvl );
				skylvl = new Sprite();
					skylvl.addEventListener( MouseEvent.ROLL_OVER, manageCursor );
					skylvl.addEventListener( MouseEvent.ROLL_OUT, manageCursor);
					skylvl.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
				addChild( skylvl );
				skylvl.name = "skylvl";
			}

            //corner buttons lt, rt, rb, lb
			createButton("btn0");
			createButton("btn1");
			createButton("btn2");
			createButton("btn3");
			
			/* active area for rotation */
			var rot:Number = Math.SQRT2/2; //half angle 45' 
			var tmp:Point = new Point();
			var tmp2:Point = new Point();
			tmp.normalize( 1 );
			tmp2.normalize( 1 );														 
			var p3:Point = new Point( 1 , 0 );			
			tmp.x = 25*( p3.x * rot - p3.y * rot );
			tmp.y = 25*( p3.x * rot + p3.y * rot );
									
			tmp2.x = 25*( p3.x * rot + p3.y * rot );
			tmp2.y = 25*(-p3.x * rot + p3.y * rot );
			p3.normalize(40);
			
CONFIG::version10 {
			obj = btns[0].getChildAt(0);
			obj.graphics.clear();
			obj.graphics.beginFill(0x0000ff,0.0);
			obj.graphics.moveTo(0,0);
			obj.graphics.lineTo(tmp.x, tmp.y);
			obj.graphics.curveTo(p3.x, p3.y, tmp2.x, tmp2.y);
			obj.graphics.lineTo(0,0);
			obj.graphics.endFill();											
			(btns[2].getChildAt(0) as Sprite).graphics.copyFrom( obj.graphics );
			(btns[1].getChildAt(0) as Sprite).graphics.copyFrom( obj.graphics );
			(btns[3].getChildAt(0) as Sprite).graphics.copyFrom( obj.graphics );
};
CONFIG::version9 {
			for each ( obj in btns )
				with ( obj.getChildAt(0) )
				{
					graphics.clear();
					graphics.beginFill(0x0000ff,0.0);
					graphics.moveTo(0,0);
					graphics.lineTo(tmp.x, tmp.y);
					graphics.curveTo(p3.x, p3.y, tmp2.x, tmp2.y);
					graphics.lineTo(0,0);
					graphics.endFill();											
				};
};
											
			//horizontal/vertical scaling
			//if(_numPoints == 8){
				for ( i=4; i<8; i+=1 )
				{					
					btnObj = new dotIcon();
					btnObj.name = "btn"+i;
					addChild( btnObj );
					btns.push( btnObj );
					btnObj.addEventListener( MouseEvent.ROLL_OVER, manageCursor );
					btnObj.addEventListener( MouseEvent.ROLL_OUT, manageCursor );
					btnObj.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
				};
			//}
				
            //center button
			btnObj = new centerIcon();			
			btnObj.name = "btn9";
			btns[9] = btnObj;
			if(_isCenterPoint){
				btnObj.doubleClickEnabled = true;
				btnObj.addEventListener(MouseEvent.DOUBLE_CLICK, centerDblClickHandler, false, 0, true);
				btnObj.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false,0,true);
			}
			
			bbp0 = new Point();
			bbp1 = new Point();
			bbp2 = new Point();
			bbp3 = new Point();
			perc = new Point();
			pcenter = new Point();
		}
				
		public function get transformer():ITransformer { return obj; }; 
		
		public function get active():Boolean { return _drawobj!=null };
		
		public function get mode():uint { return _mode & 0xf };
		
		public function get oparent():DisplayObjectContainer {
			return _oparent;
		}
		
		public function get currentPoint():Point {
			return mdt;
		}
		
		public function get curButton():String {
			return _curBut;
		}
		
		public function get cursorAngle():Number {
			return _cursorAngle;
		}
		
		public function get currentMatrix():Matrix {
			return curm;
		}
		
		public function get RotationX():Number {
			return getDegrees(Math.atan2(totm.b, totm.a));
		}
		
		public function get RotationY():Number {
			return getDegrees(Math.atan2(totm.c, totm.d));
		}
		
		public function getDegrees(radians:Number):Number{
			return Math.floor(radians/(Math.PI/180));
		}
		
		public function get centrer():Point{
			return perc;
		}
		
		/*public function get currentPoint():Point {
			return mdt;
		}*/
		
		
				
		public function activate( object:ITransformer,
                                  drawobj:Sprite,
                                  oparent:DisplayObjectContainer, 
                                  allowedTransforms:uint = TransformMode.MODE_ALLOW_ALL,
								  numPoints:uint = 8 ):void
		
		{
			
			if ( hasEventListener( Event.ACTIVATE ) )
			{
					dispatchEvent( new Event( Event.DEACTIVATE, false, true ) )					
				
				if ( !dispatchEvent( new Event( Event.ACTIVATE, false, true ) ) )
				{
					deactivate();
					return;
				}
			};
			
				if ( !object ) return;
			
			_drawobj = drawobj;
			
			_mode = ( _mode & 0x0FFFFF ) | allowedTransforms;
			
			_numPoints = numPoints;
				
				if ( drawobj!=null )
				{
					drawobj.addChild( this );
					drawobj.addChild( btns[9] );
					
					if(!_isCenterPoint){
						btns[9].visible = false;
						btns[9].mouseEnabled = false;
						
					}
					
                    var b:Boolean;
                    //skew allowed ?
					if(_isScrew){
                    	b = (_mode & TransformMode.MODE_ALLOW_SKEW)==TransformMode.MODE_ALLOW_SKEW;
                    	skxlvl.visible = skylvl.visible = b;
					}
                    //scale allowed ?
					
					b = (_numPoints == 8) ? true : false;

					btns[4].visible =
					btns[5].visible =
					btns[6].visible =
					btns[7].visible = b;
					

					b = (_mode & TransformMode.MODE_ALLOW_SCALE)==TransformMode.MODE_ALLOW_SCALE;
					InteractiveObject(btns[0].getChildAt(1)).mouseEnabled =
					InteractiveObject(btns[1].getChildAt(1)).mouseEnabled =
					InteractiveObject(btns[2].getChildAt(1)).mouseEnabled =
					InteractiveObject(btns[3].getChildAt(1)).mouseEnabled = b;
						
                    //rotation allowed
                    b = (_mode & TransformMode.MODE_ALLOW_ROTATE)==TransformMode.MODE_ALLOW_ROTATE;
                    InteractiveObject(btns[0].getChildAt(0)).mouseEnabled =
                    InteractiveObject(btns[1].getChildAt(0)).mouseEnabled =
                    InteractiveObject(btns[2].getChildAt(0)).mouseEnabled =
                    InteractiveObject(btns[3].getChildAt(0)).mouseEnabled = b;
                    
			
					if ( obj!=object )
					{
						_oparent = oparent;
						obj = object;		
						
						totm = object.initTransformation();
						curm.a = totm.a; curm.b = totm.b;
						curm.c = totm.c; curm.d = totm.d;
						curm.tx = totm.tx; curm.ty = totm.ty;			
						totmI = totm.clone();
						totmI.invert();
	
						updateNow(true, true);
						var tmp:Point = _drawobj.globalToLocal( pcenter );

						btns[9].x = tmp.x;
						btns[9].y = tmp.y;	
						
						calculatePerc();
						dispatchEvent( new TransformEvent( TransformEvent.TRANSFORM_INIT ) );
					};				
					
				};
		};		
		
		public function deactivate( evt:MouseEvent=null ):void
		{				
				if ( hasEventListener( Event.DEACTIVATE ) )
					dispatchEvent( new Event( Event.DEACTIVATE, false, false ) );
			
			Mouse.instance.removeMouseMoveGlobalListener();					
			drawobj = null;
			_oparent = null;
			obj = null;
			totm = null;
			totmI = null;
			initm = null;
		};
		
		private function set drawobj(value:Sprite):void 
		{
				if ( _drawobj )
				{
					_drawobj.removeChild( btns[9] );
					_drawobj.removeChild( this );
					_drawobj.graphics.clear();		
				};
			_drawobj = value;
		}

		
		protected function redraw():void
		{
			var gr:Graphics = graphics;
			gr.clear();
			gr.lineStyle(1, 0x000000, 0.7);
			gr.moveTo( bbp0.x, bbp0.y );
			gr.lineTo( bbp1.x, bbp1.y );
			gr.lineTo( bbp2.x, bbp2.y );
			gr.lineTo( bbp3.x, bbp3.y );
			gr.lineTo( bbp0.x, bbp0.y );
		};	
		
		protected function calculatePerc():void
		{	
			perc = new Point( btns[9].x, btns[9].y );
			perc = _drawobj.localToGlobal( perc );
			perc = _oparent.globalToLocal( perc );
			perc = totmI.transformPoint( perc );
		}
		
		public function update( fullupdate:Boolean=false ):void		
		{
			totm = obj.initTransformation();					
			totmI = totm.clone();
			totmI.invert();
			curm.a = totm.a; curm.b = totm.b;
			curm.c = totm.c; curm.d = totm.d;
			curm.tx = totm.tx; curm.ty = totm.ty;			

			updateNow(true, fullupdate);
			
			dispatchEvent( new TransformEvent( TransformEvent.TRANSFORM_INIT ) );
		};
		
		/**
		 * @param
		 */
		protected function updateNow( updateRefPoint:Boolean=true, isSkew:Boolean=false ):void
		{
			var tmp:Point;
			obj.getCorners( bbp0, bbp1, bbp2, bbp3 );
			
			rotation = Math.atan2( bbp1.y-bbp0.y, bbp1.x-bbp0.x ) * 180 / Math.PI;
						
  			bbp0 = _oparent.localToGlobal(bbp0);			
			bbp1 = _oparent.localToGlobal(bbp1);
			bbp2 = _oparent.localToGlobal(bbp2);
			bbp3 = _oparent.localToGlobal(bbp3);

 				tmp = _drawobj.globalToLocal(bbp0);
 				x = tmp.x; 
				y = tmp.y; 
							
				if ( updateRefPoint )
				{ 
					tmp = curm.transformPoint( perc ); /* !!! */
					tmp = _oparent.localToGlobal( tmp );
					tmp = _drawobj.globalToLocal( tmp ); 
					btns[9].x = tmp.x;
					btns[9].y = tmp.y;					
				};
				
			tmp = new Point( 0.25 * ( bbp0.x + bbp1.x + bbp2.x + bbp3.x ),
				 			 0.25 * ( bbp0.y + bbp1.y + bbp2.y + bbp3.y ) );					
			pcenter.x = tmp.x;
			pcenter.y = tmp.y;							
			
			bbp0 = globalToLocal(bbp0);
			bbp1 = globalToLocal(bbp1);
			bbp2 = globalToLocal(bbp2);
			bbp3 = globalToLocal(bbp3);
				
			btns[0].x = bbp0.x; btns[0].y = bbp0.y;
			btns[1].x = bbp1.x; btns[1].y = bbp1.y;
			btns[2].x = bbp2.x; btns[2].y = bbp2.y;
			btns[3].x = bbp3.x; btns[3].y = bbp3.y;
			
				with ( Point.interpolate( bbp0, bbp1, 0.5 ) ) { btns[4].x = x; btns[4].y = y };				
				with ( Point.interpolate( bbp1, bbp2, 0.5 ) ) { btns[5].x = x; btns[5].y = y };
				with ( Point.interpolate( bbp2, bbp3, 0.5 ) ) { btns[6].x = x; btns[6].y = y };
				with ( Point.interpolate( bbp3, bbp0, 0.5 ) ) { btns[7].x = x; btns[7].y = y };
			
			if(_isScrew){
 				skxlvl.x = skylvl.x = btns[0].x; 
				skxlvl.y = skylvl.y = btns[0].y;
			}

			redraw();

			var g:Graphics;
							
				//if skewing angles between sides changes so we need to update rotation sprites			
				if(_isScrew){
					g = skxlvl.graphics;
					g.clear(); 
					g.lineStyle(2,0xff0000,0.0,false,LineScaleMode.NONE, CapsStyle.SQUARE);
					g.moveTo( 0,0 );
					g.lineTo( bbp1.x=bbp1.x-bbp0.x, bbp1.y=bbp1.y-bbp0.y );
					g.moveTo( bbp3.x=bbp3.x-bbp0.x, bbp3.y=bbp3.y-bbp0.y );
					g.lineTo( bbp2.x=bbp2.x-bbp0.x, bbp2.y=bbp2.y-bbp0.y );
					
					g = skylvl.graphics;
					g.clear();
					g.lineStyle(2,0x00ff00,0.0,false,LineScaleMode.NONE, CapsStyle.SQUARE);
					g.moveTo( bbp1.x, bbp1.y );
					g.lineTo( bbp2.x, bbp2.y );
					g.moveTo( 0,0 );
					g.lineTo( bbp3.x, bbp3.y );

					var tmp2:Point = new Point();
					tmp.x = btns[0].x - btns[1].x; tmp.y = btns[0].y - btns[1].y;
					tmp2.x = btns[0].x - btns[3].x; tmp2.y = btns[0].y - btns[3].y;
					tmp.normalize(1);
					tmp2.normalize(1);
					tmp.x += tmp2.x; tmp.y += tmp2.y;
					tmp2.x = Math.atan2( tmp.y, tmp.x ) * 180 / Math.PI;
					DisplayObjectContainer(DisplayObjectContainer(btns[0]).getChildAt(0)).rotation = tmp2.x;
					DisplayObjectContainer(DisplayObjectContainer(btns[2]).getChildAt(0)).rotation = 180+tmp2.x; 														
					tmp.x = btns[1].x - btns[0].x; tmp.y = btns[1].y - btns[0].y;
					tmp2.x = btns[1].x - btns[2].x; tmp2.y = btns[1].y - btns[2].y;
					tmp.normalize(1);
					tmp2.normalize(1);
					tmp.x += tmp2.x; tmp.y += tmp2.y;
					tmp2.x = Math.atan2( tmp.y, tmp.x ) * 180 / Math.PI;
					DisplayObjectContainer(DisplayObjectContainer(btns[1]).getChildAt(0)).rotation = tmp2.x;
					DisplayObjectContainer(DisplayObjectContainer(btns[3]).getChildAt(0)).rotation = 180+tmp2.x; 														
				}
		};
		
		protected function angle( p:uint, e:uint ):Number
		{
			var pp:Point = new Point( btns[p].x, btns[p].y );
			var ep:Point = new Point( btns[e].x, btns[e].y );
			pp = localToGlobal( pp );
			ep = localToGlobal( ep );
			return Math.atan2( ep.y-pp.y, ep.x-pp.x ) * 180 / Math.PI;
		};
		
		protected function manageCursor( evt:MouseEvent ):void
		{
			var __mode : uint = TransformMode.MODE_IDLE;
			if ( evt.type == MouseEvent.ROLL_OVER )
			{
				_curBut = (evt.target.name == "rotate") ? evt.target.parent.name : evt.target.name;
				var __angle : Number; 
				if ( !Mouse.isDown )
				{	
					switch( evt.target.name )
					{
						case "rotate":
									switch ( evt.target.parent.name )
									{
										case "btn0":
											 __angle = angle( 2, 0 );
											break;
										case "btn1":
											 __angle = angle( 3, 1 );
											break;
										case "btn2":
											 __angle = angle( 0, 2 );
											break;
										case "btn3":
											 __angle = angle( 2, 3 );
											break;
									};
								__mode = TransformMode.MODE_ROTATE;
							break;
						case "btn4":
						case "btn6":
								 __angle = angle( 6, 4 );
								 __mode = TransformMode.MODE_SCALEX;
							break;
						case "btn7":
						case "btn5":
								 __angle = angle( 7, 5 );
								 __mode = TransformMode.MODE_SCALEY;
							break;
						case "btn0":
						case "btn2":
								 __angle = angle( 2, 0 );
								 __mode = TransformMode.MODE_SCALE;
							break;
						case "btn1":
						case "btn3":
								 __angle = angle( 3, 1 );
								 __mode = TransformMode.MODE_SCALE;
							break;
						case "skxlvl":
								 __angle = angle( 1, 0 );
								 __mode = TransformMode.MODE_SKEWX;		
							break;
						case "skylvl":
								 __angle = angle( 1, 2 );			
								 __mode = TransformMode.MODE_SKEWY;		
							break;
						
					};
				_cursorAngle = __angle;
				dispatchEvent( new TransformEvent( TransformEvent.TRANSFORM_CURSOR, __mode, __angle ) ); 
				};
			} else {
				_cursorAngle = 0;
				dispatchEvent( new TransformEvent( TransformEvent.TRANSFORM_CURSOR, __mode ) );
			};
			
		};
		
		protected function mouseDownHandler( evt:MouseEvent ):void
		{
				if ( evt.target.name == "btn9" )
				{
					Mouse.instance.addMouseMoveGlobalListener( revPointMouseMove, revPointMouseDrop );
					return ;
				};

			obj.beginTransformation();
			
			initm = totm.clone();		
			p1 = new Point();
			p2 = new Point( btns[9].x, btns[9].y );
			p2 = _drawobj.localToGlobal( p2 );
				
			mdt = totmI.transformPoint( _oparent.globalToLocal( Mouse.mdown ) );			
				
			var mode:uint = 0x08;
			var btnname:String = evt.target.name;
				switch ( evt.target.name )
				{
					case "rotate":
							btnname = evt.target.parent.name;
							mode = 0x11;				
						break;
					case "skxlvl":
								if ( skxlvl.mouseX < skxlvl.width*0.5 ) btnname = "btn4";
									else btnname = "btn6";
							mode = 0x15;				
						break;
					case "skylvl":
								if ( skylvl.mouseY < skylvl.height*0.5 ) btnname = "btn7";
									else btnname = "btn5";
							mode = 0x12;				
						break;
				};

				switch( btnname )
				 {
					 case "btn0":
							p1.x = btns[2].x;
							p1.y = btns[2].y;
							mode |= 1;
						break;
					 case "btn1":
							p1.x = btns[3].x;
							p1.y = btns[3].y;
							mode |= 1;
						break;
					 case "btn3":
							p1.x = btns[1].x;
							p1.y = btns[1].y;
							mode |= 1;
						break;
					 case "btn2":
							p1.x = btns[0].x;
							p1.y = btns[0].y;
							mode |= 1;
						break;
					 case "btn4":
							p1.x = btns[6].x;
							p1.y = btns[6].y;
							mode |= 4;
						break;
					 case "btn6":
							p1.x = btns[4].x;
							p1.y = btns[4].y;
							mode |= 4;
						break;						
					 case "btn5":
							p1.x = btns[7].x;
							p1.y = btns[7].y;
							mode |= 2;
						break;
					 case "btn7":
							p1.x = btns[5].x;
							p1.y = btns[5].y;
							mode |= 2;
						break;								
				 };				
							 
			p1 = localToGlobal( p1 );
			
			/* get listeners from implementation */
				switch( mode )
				{
					case 0x9:
							Mouse.instance.addMouseMoveGlobalListener( onMouseMove_Scale, deactivateHandler );
							_mode = (_mode & 0xfffffff0) | (TransformMode.MODE_SCALE & 0xf);
						break;
					case 0xa:
							Mouse.instance.addMouseMoveGlobalListener( onMouseMove_ScaleX, deactivateHandler );
							_mode = (_mode & 0xfffffff0) | (TransformMode.MODE_SCALEX & 0xf);
						break;
					case 0xc:
							Mouse.instance.addMouseMoveGlobalListener( onMouseMove_ScaleY, deactivateHandler );
							_mode = (_mode & 0xfffffff0) | (TransformMode.MODE_SCALEY & 0xf);
						break;
					case 0x11:
							Mouse.instance.addMouseMoveGlobalListener( onMouseMove_Rotate, deactivateHandler );
							_mode = (_mode & 0xfffffff0) | (TransformMode.MODE_ROTATE & 0xf);
						break;
					case 0x12:
							Mouse.instance.addMouseMoveGlobalListener( onMouseMove_skewY, deactivateHandler );
							_mode = (_mode & 0xfffffff0) | (TransformMode.MODE_SKEWY & 0xf);
						break;
					case 0x15:
							Mouse.instance.addMouseMoveGlobalListener( onMouseMove_skewX, deactivateHandler );
							_mode = (_mode & 0xfffffff0) | (TransformMode.MODE_SKEWX & 0xf);
						break;
						
				};
								 
				if ( mode != 0x11 )
				{
					p1  = totmI.transformPoint( _oparent.globalToLocal( p1 ) );
					p2  = totmI.transformPoint( _oparent.globalToLocal( p2 ) );
				};
								
			evt.stopImmediatePropagation();
			
 			dispatchEvent( new TransformEvent( TransformEvent.TRANSFORM_BEGIN, _mode  & 0xf ) );
 			_cmevt = new TransformEvent( TransformEvent.TRANSFORM_COMMIT, _mode  & 0xf );
		};		
		
		private function revPointMouseDrop( evt:Event ):void
		{
			calculatePerc();
		}
					
		protected function deactivateHandler( evt:Event ):void
		{
			if ( hasEventListener( Event.CHANGE) ) dispatchEvent( new Event( Event.CHANGE, false, true ) );		
			
			totm = obj.commitTransformation();							
			totmI = totm.clone();
			totmI.invert();
			p1 = null;
			p2 = null;			
			mdt = null;
			curm.identity();		
			
			dispatchEvent( new TransformEvent( TransformEvent.TRANSFORM_COMMIT, _mode & 0xf ) );
			_mode = TransformMode.MODE_IDLE;
		};
		
		private function centerDblClickHandler(e:MouseEvent):void 
		{
			p1 = new Point(pcenter.x,pcenter.y);
			p1 = _drawobj.globalToLocal( p1 );
			btns[9].x = p1.x;	
			btns[9].y = p1.y;		
			calculatePerc();			
			p1 = null;
		}
		
		private function revPointMouseMove( evt:MouseEvent):void
		{					
			p1 = new Point();
				if ( (Math.abs( Mouse.X - pcenter.x ) < 5) && (Math.abs( Mouse.Y - pcenter.y ) < 5) )
				{
					p1.x = pcenter.x;
					p1.y = pcenter.y;
				} else {
					p1.x = Mouse.X;
					p1.y = Mouse.Y;					
				};
			p1 = _drawobj.globalToLocal( p1 );
			btns[9].x = p1.x;	
			btns[9].y = p1.y;			
			calculatePerc();
			p1 = null;
		}
		
 /****
 * ROTATE handling functions
 */		
 		private function onMouseMove_Rotate( evt:MouseEvent ):void
		{
			var gp:Point = (evt.altKey)?p1.clone():p2.clone();
					
			var ms:Point;
			var md:Point;
			ms = new Point( Mouse.X-gp.x, Mouse.Y-gp.y);
			md = new Point( Mouse.downX - gp.x, Mouse.downY - gp.y );	
			var alfa:Number = Math.atan2( md.x * ms.y - md.y * ms.x, md.x * ms.x + md.y * ms.y ); 			

				if ( evt.shiftKey )
				{
					alfa = int( Math.floor( 4 * (alfa) / Math.PI ) );
					alfa = -( Math.PI * ( -alfa + 3) ) / 4;
				};

			gp = _oparent.globalToLocal(gp);
			var locm:Matrix = new Matrix();
			
			locm.translate( -gp.x, -gp.y );
			locm.rotate( alfa );
			locm.translate( gp.x, gp.y );					
			//curm = totm.clone();
			curm.a = totm.a; curm.b = totm.b;
			curm.c = totm.c; curm.d = totm.d;
			curm.tx = totm.tx; curm.ty = totm.ty;			
			curm.concat(locm);
			obj.appendTransformation( curm );			
			
			updateNow( evt.altKey || (_mode & 0x50) );
			
			_mode = _mode | uint( evt.altKey ) << 4; 
			dispatchEvent( _cmevt );			
		};
 
 /****
 * SCALE handling functions
 */
		private function onMouseMove_ScaleY( evt:MouseEvent ):void
		{
			var gp2:Point = (evt.altKey)?p2:p1;
						
			var p:Point = new Point( _oparent.mouseX, _oparent.mouseY );
			p = totmI.transformPoint( p );
			curm.identity();
			p.y = (gp2.y  - p.y ) / ( gp2.y - mdt.y  );
					
			curm.translate( 0, -gp2.y );
			curm.scale( 1, p.y );				
			curm.translate( 0, gp2.y );
			curm.concat( totm );	
			obj.appendTransformation( curm );
			
			updateNow(!evt.altKey || (_mode & 0x50), true);
			
			_mode = _mode | uint( evt.altKey ) << 4;			
			dispatchEvent( _cmevt );
		}
		
		private function onMouseMove_ScaleX( evt:MouseEvent ):void
		{
			var gp2:Point = (evt.altKey)?p2:p1;
						
			var p:Point = new Point( _oparent.mouseX, _oparent.mouseY );
			p = totmI.transformPoint( p );
			curm.identity();
			p.x = (gp2.x - p.x ) / ( gp2.x - mdt.x );

			curm.translate( -gp2.x, 0 );
			curm.scale( p.x, 1 );				
			curm.translate( gp2.x, 0 );
			curm.concat( totm );	
			obj.appendTransformation( curm );
			
			updateNow(!evt.altKey || (_mode & 0x50), true);
			
			_mode = _mode | uint( evt.altKey ) << 4;			
			dispatchEvent( _cmevt );			
		}		
		
		private function onMouseMove_Scale( evt:MouseEvent ):void
		{	
			var gp2:Point = (evt.altKey)?p2:p1;
			
			var p:Point = new Point( _oparent.mouseX, _oparent.mouseY );
			p = totmI.transformPoint( p );
			curm.identity();
			p.x = ( gp2.x - p.x ) / ( gp2.x - mdt.x );
			p.y = ( gp2.y  - p.y ) / ( gp2.y - mdt.y  );
			
			// commented "Shift key" interaction to proportional scale ( for 4 corner transform points )
			// if ( evt.shiftKey ){
					p.x = Math.min(p.x, p.y);
					p.y = p.x;
			// };
					
			curm.translate( -gp2.x, -gp2.y );
			curm.scale( p.x, p.y );				
			curm.translate( gp2.x, gp2.y );
			curm.concat( totm );	
			obj.appendTransformation( curm );
			
			updateNow(!evt.altKey || (_mode & 0x50),true);
			
			_mode = _mode | uint( evt.altKey ) << 4;
			dispatchEvent( _cmevt );			
		};
 /****
 * SKEW handling functions
 */
 		private function onMouseMove_skewX( evt:MouseEvent ):void
		{					
			var gp2:Point = (evt.altKey)?p1:p2;
		
			var p:Point = new Point( _oparent.mouseX, _oparent.mouseY );
			p = totmI.transformPoint( p );			
			var locm:Matrix = new Matrix(1, 0, -( p.x - mdt.x ) / (gp2.y - mdt.y), 1);	
			
			curm.a = curm.d = 1;
			curm.b = curm.c = 0;
			curm.tx = -gp2.x;
			curm.ty = -gp2.y;
			curm.concat(locm);
			curm.translate( gp2.x, gp2.y );			
			curm.concat( totm );			
			
			obj.appendTransformation( curm );
							
			updateNow(evt.altKey || (_mode & 0x50), true);
			
			_mode = _mode | uint( evt.altKey ) << 4;
			dispatchEvent( _cmevt );			
		};
			
 		private function onMouseMove_skewY( evt:MouseEvent ):void
		{					
			var gp2:Point = (evt.altKey)?p1:p2;
			
			var p:Point = new Point( _oparent.mouseX, _oparent.mouseY );
			p = totmI.transformPoint( p );			
			var locm:Matrix = new Matrix(1, ( mdt.y - p.y  ) / ( gp2.x - mdt.x ) );	
			
			curm.a = curm.d = 1;
			curm.b = curm.c = 0;
			curm.tx = -gp2.x;
			curm.ty = -gp2.y; 			
			curm.concat(locm);
			curm.translate( gp2.x, gp2.y );					
			curm.concat( totm );		
			
			obj.appendTransformation( curm );				
			
			updateNow(evt.altKey || (_mode & 0x50), true);
			
			_mode = _mode | uint( evt.altKey ) << 4;
			dispatchEvent( _cmevt );			
		};
	
	};
}
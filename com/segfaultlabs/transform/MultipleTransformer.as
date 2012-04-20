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
	import com.segfaultlabs.transform.interfaces.ITransformer;
	import com.segfaultlabs.transform.interfaces.ITransformable;
	
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
CONFIG::flex{
	import mx.core.mx_internal;
	import mx.core.UIComponent;
}
	
	/**
	 * This class is used to transform a set of DisplayObjects,
	 * all at the same time. Class handles proper initialization
	 * and concatenation of transformation matrices 
	 * 
	 * @author Mateusz Malczak (http://malczak.info)
	 * 
	 */
	public class MultipleTransformer implements ITransformer
	{
		[ArrayElementType("DisplayObject")] 
		private var _objects : Array;
		private var _rect    : Rectangle;
		private var _orgms	 : Dictionary;
		private var _tMtx    : Matrix;
		
		
		public function MultipleTransformer( objects:Array )
		{
			_objects = [];
			_orgms = new Dictionary(true);
			_tMtx = new Matrix();
			data = objects;
		}
		
		public function set data( value:Object ):void
		{		
			_objects.splice(0,_objects.length);
			for ( var key:* in _orgms ) 
				delete _orgms[key];
			
			var tarr:Array = value as Array;
				if ( tarr && tarr.length>0 )
				{
					var obj:DisplayObject;
					
						for each ( obj in tarr )
							_objects.push( obj );
							
					update();
					
						for each ( obj in _objects )
						{
								if ( obj is ITransformable )
									_orgms[obj] = ITransformable(obj).initTransformation().clone(); //this isnt cleaned anywhere
								else			
									_orgms[obj] = obj.transform.matrix.clone();
							_orgms[obj].tx -= _rect.x;
							_orgms[obj].ty -= _rect.y;							
						};
						
					_orgms[this] = _rect.clone();
		
					_tMtx.identity();
					_tMtx.tx = _rect.x;
					_tMtx.ty = _rect.y;
				};						
		};
		
		public function get data():Object
		{
			return _objects;
		};
		
		public function getCorners( bbp0:Point, bbp1:Point, bbp2:Point, bbp3:Point ):void
		{
			var bbp0_:Point = new Point( 0, 0 );
			var bbp2_:Point = new Point( _orgms[this].width,_orgms[this].height );
			var bbp1_:Point = new Point( _orgms[this].width, 0 );
			var bbp3_:Point = new Point( 0, _orgms[this].height );
			bbp0_ = _tMtx.transformPoint(bbp0_);
				bbp0.x = bbp0_.x; bbp0.y = bbp0_.y;
			bbp1_ = _tMtx.transformPoint(bbp1_);
				bbp1.x = bbp1_.x; bbp1.y = bbp1_.y;
			bbp2_ = _tMtx.transformPoint(bbp2_);
				bbp2.x = bbp2_.x; bbp2.y = bbp2_.y;
 			bbp3_ = _tMtx.transformPoint(bbp3_);			
				bbp3.x = bbp3_.x; bbp3.y = bbp3_.y;
		};		
		
		public function initTransformation():Matrix
		{
			var fds:DisplayObject = _objects[0];
				for each ( fds in _objects )
					if ( fds is ITransformable )
						ITransformable( fds ).initTransformation();
			return _tMtx;
		};
		
		public function beginTransformation():void 
		{ 
			var fds:DisplayObject;
				for each ( fds in _objects )
				{
						if ( fds is ITransformable )
							ITransformable( fds ).beginTransformation();
				};
		};
		
		public function appendTransformation( mtx:Matrix ):void 
		{
			var obj:DisplayObject;
			var m:Matrix;
				for each (obj in _objects) 
				{
					m = _orgms[obj].clone();
					m.concat( mtx );
						if ( obj is ITransformable )
							ITransformable( obj ).appendTransformation( m )
						else 
							obj.transform.matrix = m;
				};
			_tMtx = mtx.clone();
		}
		
		public function commitTransformation():Matrix 
		{ 
			update();			
			return _tMtx; 			
		};

		private function update(targetCoordinateSpace:DisplayObject = null):void 
		{
				if ( !targetCoordinateSpace ){
					targetCoordinateSpace = _objects[0].parent;
									
 CONFIG::flex {
				if ( _objects[0] is UIComponent ) targetCoordinateSpace = _objects[0].mx_internal::$parent; 
};

				};

			_rect = _objects[0].getBounds( targetCoordinateSpace );
			var i:int = _objects.length-1;
				while ( i>0 ) _rect = _rect.union( _objects[i--].getBounds( targetCoordinateSpace ) );
		}
						

	}
}
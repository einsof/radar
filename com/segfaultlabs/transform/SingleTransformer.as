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
	import com.segfaultlabs.transform.interfaces.ITransformable;
	import com.segfaultlabs.transform.interfaces.ITransformer;
	
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;	
		
	/**
	 * This class is used to transform single DisplayObject
	 * instance. All it does is updates objects transformation
	 * matrix
	 * 
	 * @author Mateusz Malczak (http://malczak.info)
	 * 
	 */	
	public class SingleTransformer implements ITransformer
	{
		private var _object : DisplayObject;
		
		public function SingleTransformer( object:DisplayObject )
		{
			_object = object;
		}
		
		public function set data( obj:Object ):void
		{
			_object = obj as DisplayObject;
		};
		
		public function get data():Object
		{
			return _object;
		};
		
		public function getCorners( bbp0:Point, bbp1:Point, bbp2:Point, bbp3:Point ):void
		{
			var r:Rectangle = _object.getRect( _object as DisplayObject );
			var mtx:Matrix = _object.transform.matrix;
			var bbp0_:Point = r.topLeft;
			var bbp2_:Point = r.bottomRight;
			var bbp1_:Point = new Point( bbp2_.x, bbp0_.y );
			var bbp3_:Point = new Point( bbp0_.x, bbp2_.y );						
			bbp0_ = mtx.transformPoint(bbp0_);
				bbp0.x = bbp0_.x; bbp0.y = bbp0_.y;
			bbp1_ = mtx.transformPoint(bbp1_);
				bbp1.x = bbp1_.x; bbp1.y = bbp1_.y;
			bbp2_ = mtx.transformPoint(bbp2_);
				bbp2.x = bbp2_.x; bbp2.y = bbp2_.y;
 			bbp3_ = mtx.transformPoint(bbp3_);			
				bbp3.x = bbp3_.x; bbp3.y = bbp3_.y;
		};
		
		/**
	     *  This function is used to initialize transformations
	     * 
	     *  @return Current transformation matrix of proxied object
	     */	
		public function initTransformation():Matrix
		{		
			var trans:ITransformable = _object as ITransformable;
			var mtx:Matrix = ( trans ) ? trans.initTransformation() : _object.transform.matrix;		
			return mtx;
		};
		
		/** 
		 *  Function appends given transformation matrix to 
		 *  proxied objects, and (if its needed) adjusts objects 
		 *  position -> not any more
	     * 
		 *  @param mtx Transformation matrix to be appended to proxied object
		 *  @param X coordinate adjustement
		 *  @param Y coordinate adjustement
	     */	
		public function appendTransformation( mtx:Matrix ):void
		{
			var omtx:Matrix = _object.transform.matrix;
			var trans:ITransformable = _object as ITransformable;
					if ( !trans )
						_object.transform.matrix = mtx;
							else trans.appendTransformation(mtx);
		};	
		
		public function commitTransformation():Matrix
		{
			var trans:ITransformable = _object as ITransformable;
			var rmtx:Matrix = _object.transform.matrix;		
				if ( trans ) rmtx = trans.commitTransformation();
			return rmtx;
		};
		
		public function beginTransformation():void
		{
			var trans:ITransformable = _object as ITransformable;		
				if ( trans ) trans.beginTransformation();
		};		

	}
}
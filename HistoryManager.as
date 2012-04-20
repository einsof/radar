package  {
	
	/**
	 * com.silanin.utils.HistoryManager
	 * 
	 * @version v1.0
	 * @since March 25, 2012
	 * 
	 * @author Mike Silanin
	 * @see http://mike.silanin.com
	 * 
	 * About HistoryManager
	 * 
	 * HistoryManager is a set of methods to stor and manage History
	 * for objects of different types (MovieClips, Sprites, Shapes, TextFields, Bitmaps); 
	 * 
	 * Licensed under a Creative Commons Attribution 3.0 License
	 * http://creativecommons.org/licenses/by/3.0/
	 * 
	 * Usage:
	 * 
	 * // create a instance of HistoryManager
	 * private var history : HistoryManager;
	 * history = HistoryManager.getInstance;
	 * 
	 * // use method storeChages() to store object to history
	 * history.storeChages({obj:"circle1", x:"234", colorTransform:"#CCCCCC"});
	 * 
	 * // use method undo() to go one step back
	 * history.undo();
	 * 
	 * // use method redo() to go one step forward
	 * history.redo();
	 * 
	 * // use method clear() to clear all objects from history
	 * history.clear();
	 * 
	 */
	
	import flash.display.MovieClip;
	
	
	public class HistoryManager extends MovieClip {
		
		private static var mSingleton : HistoryManager;
		private var mHistory:Vector.<Object> = new Vector.<Object>();
		private var currentHistoryIndex : int = -1; // текущий номер истории (0-9)
		private var searchState : Object; // искомое состояние для undo() и для redo()
		
		public function HistoryManager() {
			
			if ( mSingleton != null )
				throw new Error("You cannot create more than 1 HistoryManager. Use the static getInstance function instead.");
			
			mSingleton = this;
		}
		
		/** Получаем singleton HistoryManager'а */
		public static function get getInstance() : HistoryManager
		{
			if ( mSingleton == null )
				mSingleton = new HistoryManager();
	 
			return mSingleton;
		}

		/** Добавляем елемент в историю */
		public function storeChages( obj:Object ){
			
			//trace("Пишем " + obj.o_name + " в историю, тип: " + obj.o_type + "; событие: " + obj.o_event);
			
			// если по истории перемещались - очищаем лишние шаги
			if(currentHistoryIndex != mHistory.length - 1) clearSteps( currentHistoryIndex );
			// сохраняем изменения обьекта и номер шага
			mHistory.push(obj);
			currentHistoryIndex = mHistory.length - 1;
			// objectsDump();
		}
		
		/** Очищаем ненужные больше шаги */
		private function clearSteps( from:int ){
			var num: int = mHistory.length - 1 - from;
			// trace("Очищаем шаги, начиная с обьекта: " + mHistory[from].obj + " + ещё " + num);
			mHistory.splice(from + 1, num);
		}
		
		/** Дамп объектов */
		public function objectsDump(){
			trace("--------------- Делаем дамп обьектов ------------------");
			for each(var o:Object in mHistory){
				//var c_obj: = mHistory[o];
				trace("--------- Объект '" + o.o_name + "' ----------");
				for(var s:String in o) {
					trace("Параметр " + s + ": " + o[s]);
				}
				trace("-------------------------------------");
			}
			
			trace("------------------- Конец дампа ----------------------");
			
		}
		
		/** На шаг назад */
		public function undo() : void {
			
			trace("На шаг назад");
			
			if(currentHistoryIndex >= 0){
				// ищем шаг с поcледним изменением этого обьекта (по его имени)
				var searchNum : int = vectorSearch(mHistory, 'o_name', mHistory[currentHistoryIndex].o_name, currentHistoryIndex);
				// запоминаем предыдущее состояние или помечаеем на удаление (если такого не нашли)
				searchState = (searchNum != -1) ? mHistory[searchNum] : null;
				// отнимаем единичку от глобального номера шага, сохраняем
				currentHistoryIndex--;
			}
			
		}
		
		/** На шаг вперёд */
		public function redo() : void{
			
			trace("На шаг вперёд");
			
			if(currentHistoryIndex < mHistory.length - 1){
				// прибавляем единичку к глобальному номеру шага, сохраняем
				currentHistoryIndex++;
				// ищем обьект и парсим его состояние
				searchState = mHistory[currentHistoryIndex];
			}

		}
		
		/** Очищаем историю */
		public function clear() : void{
			trace("Очищаем историю");
			mHistory.splice( 0, mHistory.length );
			currentHistoryIndex = -1;
		}
		
		public function get currentStep():Object {
			return searchState;
		}
		
		public function get currentNumber():int {
			return currentHistoryIndex;
		}
		
		public function get currentLength():int {
			return mHistory.length;
		}
		
		/**
		* Search custom param in vector elements and return first result 
		* that has been found (starting from end of the vector)
		* 
		* @param c_vect
		* 
		* The target Vector instance
		* Vector, с которым работаем
		* 
		* @param c_param
		* 
		* Param we'll search for in Vector elements
		* Параметр, который нужно искать в элементах вектора
		* 
		* @param c_string
		* 
		* Sting we'll compare with search param
		* Строка, с которой сравниваем искомый параметр
		* 
		* @param c_num
		* 
		* Search limit (number). Search starts from 0 to this number in target Vector
		* Номер для ограничения диапазона поиска (ищем начиная с "0" елемента, по елемент с этим номером)
		*/
		
		private function vectorSearch( c_vect:Vector.<Object>, c_param:String, c_string:String, c_num:int = 0 ):int {
			while( c_num-- ){
				if (mHistory[c_num][c_param] == c_string) return c_num;
			}
			return -1;
		}

	}
	
}

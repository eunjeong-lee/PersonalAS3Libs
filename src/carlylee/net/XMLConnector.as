package carlylee.net
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import carlylee.events.XMLLoaderEvent;
	
	
	/**
	 * XMLConnector
	 * Using 'XMLConnector', you can call the XML with only one sentence.
	 * How to use :
	 * XMLConnector.getInstance().requestXML( "test.xml", connecterComplete, urlVar ... );
	 * 
	 * author: Eunjeong, Lee(carly.l86@gmail.com).
	 * created: Dec 12, 2013
	 */
	
	public class XMLConnector extends EventDispatcher
	{
		private static var _instance:XMLConnector;
		private var _completeFunc:Function;
		
		public function XMLConnector(target:IEventDispatcher=null){}
		
		public static function getInstance():XMLConnector{
			if( !_instance ) _instance = new XMLConnector;
			return _instance;
		}
		
		/**
		 * 
		 * @param $url
		 * @param $completeFunc
		 * @param $urlVariables
		 * @param $urlMethod
		 * @param $isZipped
		 * @param $maxTryNumber
		 * @param $progressFunc
		 * @param $errorFunc
		 * @param $obj
		 * @param $charSet
		 * @param $random
		 * 
		 */		
		public function requestXML( $url:String,
									$completeFunc:Function, 
									$urlVariables:URLVariables=null,
									$urlMethod:String=URLRequestMethod.GET,
									$isZipped:Boolean=false, 
									$maxTryNumber:int = 3, 
									$progressFunc:Function=null,
									$errorFunc:Function=null, 
									$obj:Object=null,
									$charSet:String="UTF-8", 
									$random:Boolean=false ):void{
			
			var loader:XMLLoader = new XMLLoader();
			loader.init( $url, null, null, $urlVariables, null, $urlMethod, $isZipped, $maxTryNumber );
			loader.completeFunc = $completeFunc;
			loader.errorFunc = $errorFunc;
			loader.data = $obj;
			
			if( $progressFunc != null ){
				loader.progressFunc = $progressFunc;
				loader.addEventListener( ProgressEvent.PROGRESS, $progressFunc, false, 0, true );
			}
			
			loader.addEventListener( XMLLoaderEvent.DATA_COMPLETE, onComplete, false, 0, true );
			loader.addEventListener( XMLLoaderEvent.COMPLETE_ERROR, onError, false, 0, true );
			loader.load( $charSet, $random );
		}
		
		private function onComplete( $e:XMLLoaderEvent ):void{
			var loader:XMLLoader = $e.currentTarget as XMLLoader;
			loader.removeEventListener( XMLLoaderEvent.DATA_COMPLETE, onComplete );
			loader.removeEventListener( XMLLoaderEvent.COMPLETE_ERROR, onError );
			
			if( loader.progressFunc != null ){
				loader.removeEventListener( ProgressEvent.PROGRESS, loader.progressFunc );
			}
			
			var xml:XML = $e.xml;
			if( loader.completeFunc != null ) loader.completeFunc( xml );
		}
		
		private function onError( $e:XMLLoaderEvent ):void{
			var loader:XMLLoader = $e.currentTarget as XMLLoader;
			loader.removeEventListener( XMLLoaderEvent.DATA_COMPLETE, onComplete );
			loader.removeEventListener( XMLLoaderEvent.COMPLETE_ERROR, onError );
			
			if( loader.progressFunc != null ){
				loader.removeEventListener( ProgressEvent.PROGRESS, loader.progressFunc );
			}
			
			if( loader.errorFunc != null ) loader.errorFunc( $e );
		}
	}
}
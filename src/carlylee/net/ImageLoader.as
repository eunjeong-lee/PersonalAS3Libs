﻿package carlylee.net
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import carlylee.events.ImageLoaderEvent;

	public class ImageLoader extends EventDispatcher
	{
		public static const RETRY_DELAY:int = 1000;
		
		private var _loader:Loader;
		private var _urlRequest:URLRequest;
		private var _tryNumber:int = 0;
		private var _maxTryNumber:int = 3;
		private var _startTime:int;
		private var _lastTime:int;
		
		public var smoothing:Boolean = false;
		public var error:String;
		public var initFunc:Function;
		public var completeFunc:Function;
		public var errorFunc:Function;
		public var progressFunc:Function;
		public var data:Object;
		public var displayObject:DisplayObject;
		
		public function ImageLoader(){}
		
		/**
		 * 
		 * @param $url(String)
		 * @param $completeFunc(Function this)
		 * @param $errorFunc(Function)
		 * @param $progressFunc(Function)
		 * @param $maxTryNumber(int 3)
		 * @param $smoothing(Boolean false)
		 * @param $initFunc(Function)
		 * 
		 */		
		public function init( $url:String,
							  $completeFunc:Function,
							  $errorFunc:Function,
							  $progressFunc:Function=null,
							  $maxTryNumber:int=3,
							  $smoothing:Boolean=false,
							  $initFunc:Function=null ):void{
			
			this._maxTryNumber = $maxTryNumber;
			this.completeFunc = $completeFunc;
			this.errorFunc = $errorFunc;
			this.progressFunc = $progressFunc;
			this.smoothing = $smoothing;
			this.initFunc = $initFunc;
			this._urlRequest = new URLRequest( $url );
			
			_loader = new Loader;
			_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onComplete );
			_loader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, onProgress );
			_loader.contentLoaderInfo.addEventListener( Event.INIT, onInit );
			_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
		}
		
		/**
		 * @param $random(Boolean) if it's true 'url?545465', it's not true 'url'.
		 */		
		public function load( $random:Boolean=false ):void{
			_startTime = getTimer();
			if( $random ){
				if( _lastTime >= _startTime ) _startTime = _lastTime+1;
				var _urlVar:URLVariables = new URLVariables;
				_urlVar.random = String( Math.random() );
				_urlRequest.data = _urlVar;
			}
			_tryNumber ++;
			_loader.load( this._urlRequest );
		}
		
		private function onProgress( $e:ProgressEvent ):void{
			if ( this.progressFunc == null ) {
				dispatchEvent( $e.clone() );
			}else {
				this.progressFunc( $e );
			}
		}
		
		private function onInit( $e:Event ):void{
			_loader.contentLoaderInfo.removeEventListener( Event.INIT, onInit );
			if( this.initFunc == null ){
				this.dispatchEvent( $e.clone() );
			}else{
				this.initFunc( $e );
			}
		}
				
		private function onComplete( $e:Event ): void{
			_loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onComplete );
			_loader.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS, onProgress );
			_loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, onIOError );
			var elapsedTime:int = getTimer() - _startTime;
			trace( "ImageLoader loading image is succeed : " + _urlRequest.url );
			trace( "Elapsed Time: " + elapsedTime + "ms. Try number: " + _tryNumber );	
			this.displayObject = $e.target.content;
			if( smoothing ){
				try{
					Bitmap( displayObject ).smoothing = true;
				}catch($e:Error){}
			}
			if( this.completeFunc == null ){
				this.dispatchEvent( new ImageLoaderEvent( ImageLoaderEvent.LOAD_COMPLETE, displayObject, this.data ));	
			}else{
				this.completeFunc( this );
			}
		}
		
		private function onIOError( $e:IOErrorEvent ):void{
			_loader.contentLoaderInfo.removeEventListener( Event.INIT, onInit );
			_loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onComplete );
			_loader.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS, onProgress );
			_loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, onIOError );
			trace( "ImageLoader IOError: " + _urlRequest.url +"/ tryNumber: " + _tryNumber );
			if( _tryNumber < _maxTryNumber ){
				this.reload();
			}else{
				if( this.errorFunc == null ){
					this.dispatchEvent( $e.clone() );
				}else{
					this.error = $e.toString();
					this.errorFunc( this.error );
				}
				_loader = null;
			}
		}
		
		private function reload():void{
			_loader = new Loader;
			_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onComplete );
			_loader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, onProgress );
			_loader.contentLoaderInfo.addEventListener( Event.INIT, onInit );
			_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
			setTimeout( load, RETRY_DELAY );
		}
	}
}













package {
	import flash.display.Sprite;
	import com.longtailvideo.jwplayer.utils.Logger;
	import com.longtailvideo.jwplayer.player.*;
	import com.longtailvideo.jwplayer.plugins.*;
	import com.longtailvideo.jwplayer.events.*;
	import mx.rpc.http.*;
	import mx.rpc.events.*;

  import com.google.analytics.GATracker;
  import com.google.analytics.AnalyticsTracker;

	public class Analyze extends Sprite implements IPlugin {

		/** Configuration list of the plugin. **/
		private var config:PluginConfig;
		/** Reference to the JW Player API. **/
		private var api:IPlayer;

		/** Awesm API key **/
		private var awesmApiKey:String;
		/** Awesm ID **/
		private var awesmUrl:String;

    /** GA Tracker **/
    public var tracker:AnalyticsTracker;
    /** GA Tracking ID **/
    private var gaApiKey:String;
    /** GA Event Action **/
    private var gaAction:String;

		/** Already recorded semaphore variable **/
		private var alreadyRecordedThisPlay:Boolean = false;

		/** This function is automatically called by the player after the plugin has loaded. **/
		public function initPlugin(player:IPlayer, conf:PluginConfig):void {
			api = player;
			config = conf;
			awesmApiKey = conf.awesmkey;
			awesmUrl = player.config.awesm;
			Logger.log('awesmkey: ' + awesmApiKey, 'Analyze');
			Logger.log('id: ' + awesmUrl, 'Analyze');
      gaApiKey = conf.gakey;
      tracker = new GATracker( this, gaApiKey, "AS3", false );
			gaAction = "Media Played: " + player.config.ga_action;
			Logger.log('gakey: ' + gaApiKey, 'Analyze');
			Logger.log('Event: ' + gaAction, 'Analyze');

			// Listen for play position callbacks.
			api.addEventListener(MediaEvent.JWPLAYER_MEDIA_TIME, playPosition);
			// and media loaded callbacks to reset the alreadyRecordedThisPlay variable
			api.addEventListener(MediaEvent.JWPLAYER_MEDIA_LOADED, mediaLoaded);
		}

		/** This should be a unique, lower-case identifier (e.g. "myplugin") **/
		public function get id():String {
			return "analytics";
		}

		/** Called when the player has resized.  The dimensions of the plugin are passed in here. **/
		public function resize(width:Number, height:Number):void {
			// Lay out plugin here, if necessary.
		}

		/* Private */

		private function mediaLoaded(event:MediaEvent):void { alreadyRecordedThisPlay = false; }

		private function playPosition(event:MediaEvent):void {
			if (alreadyRecordedThisPlay) return;

			var fraction:Number = (event.position / event.duration);
			// Logger.log("Play percentage: " + fraction * 100, 'Analyze');
			if (fraction >= 0.2) {
				recordAwesmConversion();
        tracker.trackEvent("Event", gaAction);
			}
		}

		private function recordAwesmConversion():void {
			if (alreadyRecordedThisPlay) return;
			alreadyRecordedThisPlay = true;

			Logger.log('Beginning awesm conversion call...', 'Analyze');

			// make the call to awesm
			var http:HTTPService = new HTTPService();

			// register event handlers (resultHandler and faultHandler functions)
			http.addEventListener( ResultEvent.RESULT, resultHandler );
			http.addEventListener( FaultEvent.FAULT, faultHandler );

			// specify the url to request, the method and result format
			http.url = "http://api.awe.sm/conversions/new";
			http.method = "GET";
			http.resultFormat = "text";

			var params:Object = { key: awesmApiKey, awesm_url: awesmUrl, conversion_type: 'goal_3', conversion_value: 1 };

			// send the request
			http.send(params);

			Logger.log('Awesm conversion call sent...', 'Analyze');
		}

		private function resultHandler(event:ResultEvent):void {
			Logger.log('Awesm play conversion successful.', 'Analyze');
			Logger.log(event.result, 'Analyze');
		}

		private function faultHandler(event:FaultEvent):void {
			Logger.log('Awesm play conversion failed.', 'Analyze');
		}
	}
}

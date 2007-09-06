/**
 * @author Ignacio Delgado
 * 
 * OSCConnection object
 * 
 * (c) 2007 http://www.h-umus.it
 * 
 */
	 
package it.h_umus.osc 
{ 
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.XMLSocket;
	import flash.events.SecurityErrorEvent;
	
	public final class OSCConnection extends EventDispatcher {		
		
		private var _Socket:XMLSocket;
		private var _Port:Number;
		private var _Ip:String;
		
		protected var mDefaultSendPort:Number;
		protected var mDefaultSendIp:Number;
		
		/**
		 * 
		 * @param inIp
		 * @param inPort
		 * @return 
		 * 
		 */		
		public function OSCConnection(inIp:String, inPort:Number) {
			super();
			_Ip = inIp;
			_Port = inPort;			
		}

	
		/**
		 * 
		 * 
		 */		
		public function connect () : void 
		{
			_Socket = new XMLSocket();
			
			_Socket.addEventListener(Event.CONNECT,onConnect);
			_Socket.addEventListener(Event.CLOSE,onClose);
			_Socket.addEventListener(DataEvent.DATA,onXml);
			_Socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_Socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);

			_Socket.connect(_Ip,_Port);
		}


		/**
		 * 
		 * 
		 */		
		public function disconnect () : void 
		{
			_Socket.close();
		}
		
		
		/**
		 * @private
		 * @param e
		 * 
		 * Event handler for incoming XMLDocument-encoded OSC packets
		 */		
		protected function onXml (e:DataEvent) : void 
		{
			// parse out the packet information
			try{
				var inXML:XML = new XML(String(e.data));
				if(inXML.localName() == "OSCPACKET")
					parseXml(inXML);
			}
			catch(e:Error)
			{
			}
		}
	
	
		/**
		 * @private
		 * @param event
		 * Event handler to respond to successful connection attempt and to
		 * redispatch the event
		 */		
		protected function onConnect (event:Event) : void 
		{
			dispatchEvent(event);
		}
	
	
		/**
		 * @private
		 * @param event
		 * 
		 * Event handler called when server kills the connection and to
		 * redispatch the event
		 */		
		protected function onClose (event:Event) : void {
			dispatchEvent(event);
		}
	
	
		/**
		 * @private
		 * @param event
		 * 
		 * Event handler called when an IOError occurs and to
		 * redispatch the event
		 */		
		protected function onIOError(event:IOErrorEvent) : void 
		{		
			dispatchEvent(event);
		}
		
		
		/**
		 * @private
		 * @param event
		 * 
		 * Event handler called when a Security Error occurs and to
		 * redispatch the event
		 */		
		protected function onSecurityError(event:Event) : void 
		{		
			dispatchEvent(event);
		}
		
		
		/**
		 * @private
		 * @param node
		 * 
		 * Parse the messages from some XMLDocument-encoded OSC packet
		 */			
		protected function parseXml(node:XML) : void 
		{
			//trace("OSCConnection.parseXml(node)");
			//trace ("\n"+node+"\n");
			
			var packet:OSCPacket = new OSCPacket(node.@TIME, node.@ADDRESS, node.@PORT);
			
			for each( var message:XML in node.MESSAGE) 
			{
				var oscMessage:OSCMessage = new OSCMessage(message.@NAME);
				for each( var argumentNode:XML in message.ARGUMENT) 
				{
					var type:String = String(argumentNode.@TYPE);
					var nodeValue:String = String(argumentNode.@VALUE);
					var value:Object = null;
					switch(type) 
					{
						case OSCArgument.T:
							value=true;
							break;
						case OSCArgument.F:
							value=false;
							break;
						case OSCArgument.f:
							value=parseFloat(nodeValue);
							break;
						case OSCArgument.i:
							value=parseInt(nodeValue);
							break;
						case OSCArgument.s:
							value=String(nodeValue);
							break;
						case OSCArgument.h:
							value=Number(nodeValue);
							break;
						default:
							value=null;
					}
					if(value!=null)
						oscMessage.addArg(new OSCArgument(type, value));
				}
				packet.addMessage(oscMessage);
			}
			dispatchEvent(new OSCConnectionEvent(OSCConnectionEvent.ON_PACKET_IN,packet));
		}
	
	
		// *** build and send XMLDocument-encoded OSC
		/**
		 * 
		 * @param outPacket
		 * 
		 */		
		public function sendOSCPacket(outPacket:OSCPacket) : void 
		{
			if (_Socket && _Socket.connected) 
			{
				_Socket.send(outPacket.getXML());
				dispatchEvent(new OSCConnectionEvent(OSCConnectionEvent.ON_PACKET_OUT,outPacket));
			}
		}
	}
}
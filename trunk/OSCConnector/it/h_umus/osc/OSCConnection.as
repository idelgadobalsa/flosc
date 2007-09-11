/**
 * @author Ignacio Delgado
 * @version 1.0
 * 
 * OSCConnection object
 * 
 * (c) 2007 http://www.h-umus.it
 * 
 * last-modified : 10-set-2007
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
		private var _Port:int;
		private var _Ip:String;
		
		
		/**
		 * 
		 * @param inIp
		 * @param inPort
		 * 
		 * Constructor
		 */		
		public function OSCConnection(inIp:String, inPort:int) {
			super();
			_Ip = inIp;
			_Port = inPort;			
		}

	
		/**
		 * 
		 * Start OSC connection
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
		 * Close OSC connection
		 */		
		public function disconnect () : void 
		{
			_Socket.close();
			removeListeners();
		}
		
		
		/**
		 * 
		 * @param outPacket
		 * 
		 * Build and send XMLDocument-encoded OSC
		 */		
		public function sendOSCPacket(outPacket:OSCPacket) : void 
		{
			if (_Socket && _Socket.connected) 
			{
				_Socket.send(outPacket.getXML());
				dispatchEvent(new OSCConnectionEvent(OSCConnectionEvent.ON_PACKET_OUT,outPacket));
			}
		}
		
		public function get ip() : String
		{
			return _Ip;
		}
		
		public function get port() : int
		{
			return _Port;
		}
		
		public function isConnected() : Boolean 
		{
			if(_Socket)
				return _Socket.connected;
				
			return false;
		}
		
		/**
		 * @private
		 * @param e
		 * 
		 * Event handler for incoming XML-encoded OSC packets
		 */		
		private function onXml (e:DataEvent) : void 
		{
			// parse out the packet information
			try
			{
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
		private function onConnect (event:Event) : void 
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
		private function onClose (event:Event) : void {
			dispatchEvent(event);
			removeListeners();
		}
	
	
		/**
		 * @private
		 * @param event
		 * 
		 * Event handler called when an IOError occurs and to
		 * redispatch the event
		 */		
		private function onIOError(event:IOErrorEvent) : void 
		{		
			dispatchEvent(event);
			removeListeners();
		}
		
		
		/**
		 * @private
		 * @param event
		 * 
		 * Event handler called when a Security Error occurs and to
		 * redispatch the event
		 */		
		private function onSecurityError(event:Event) : void 
		{		
			dispatchEvent(event);
			removeListeners();
		}
		
		
		/**
		 * @private
		 * @param node
		 * 
		 * Parse the messages from some XMLDocument-encoded OSC packet
		 */			
		private function parseXml(node:XML) : void 
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
	
	
		private function removeListeners() : void
		{
			_Socket.removeEventListener(Event.CONNECT,onConnect);
			_Socket.removeEventListener(Event.CLOSE,onClose);
			_Socket.removeEventListener(DataEvent.DATA,onXml);
			_Socket.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_Socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		}
	}
}
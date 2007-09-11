/**
* @author Ignacio Delgado
* 
* OSCPacket object
* 
* (c) 2007 http://www.h-umus.it
* 
*/
	 
package it.h_umus.osc 
{ 
	public final class OSCPacket 
	{
		public var address 		: String;
		public var port 		: Number;
		//private var _time 		: Date;
		private var _time		:Number;
		
		public var messages:Array;	
		
		public function OSCPacket(...args)
		{
			switch(args.length){
				case 0:
					OSCPacket_constructor1();
					break;
				case 3:
					OSCPacket_constructor1();
					OSCPacket_constructor2(args[0], args[1], args[2]);
					break;
			}
		}
		
		
		private function OSCPacket_constructor1():void
		{
			_time=0;
			messages = new Array();
		}
		
		
		private function OSCPacket_constructor2(time:Number, inAddress:String, inPort:int):void
		{
			_time=time;
			address = inAddress;
			port = inPort;
		}
		
		
		public function get time():Number
		{
			return _time;
		}
		
		
		public function set time(value:Number):void
		{
			_time=value;
		}
		
				
		public function addMessage(message:OSCMessage):void
		{
			messages.push(message);
		}
		
		
		public function getXML():XML
		{
			var packetXML:XML = <OSCPACKET ADDRESS={address} PORT={port} TIME={time} />;
			for each( var message:OSCMessage in messages)
				packetXML.MESSAGE+=message.getXML();
			return packetXML;
		}
	}
}
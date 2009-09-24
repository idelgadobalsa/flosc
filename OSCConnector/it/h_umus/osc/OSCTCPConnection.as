package it.h_umus.osc
{
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * Dispatched when an OSC packet incomes
	 * 
	 * @eventType it.h_umus.osc.OSCConnectionEvent.OSC_PACKET_IN
	 **/
	[Event(name="OSCPacketIn", type="it.h_umus.osc.OSCConnectionEvent")]
	
	/**
	 * Dispatched when an OSC packet outgoes
	 * 
	 * @eventType it.h_umus.osc.OSCConnectionEvent.OSC_PACKET_OUT
	 **/
	[Event(name="OSCPacketOut", type="it.h_umus.osc.OSCConnectionEvent")]
	
	[Exclude(name="send", kind="method")]
	
	/**
	 * The OSCTCPConnection object allows "virtual" OSC communication. It makes use
	 * of the UDP-to-TCP server that translates UDP/OSC packets into TCP/OSC like
	 * packets. Servers like the memo.tv or touchgateway do that job.
	 * 
	 * <p>The OSCTCPConnection object extends a Socket connection, communicating with 
	 * an UDP/OSC-to-TCP/OSC server, receiving data. The two main events defined 
	 * by the OSCTCPConnectionEvent allow knowing when an OSC packet is recieved.</p>
	 * 
	 * <p>@copy 2009 http://www.h-umus.it</p>
	 * 
	 * @author Ignacio Delgado
	 * @see http://code.google.com/p/flosc
	 * @see http://www.memo.tv/udp-tcp-bridge
	 * @see http://www.touchgateway.com
	 * @see http://opensoundcontrol.org
	 * @see flash.net.Socket
	 * @see it.h_umus.osc.OSCConnectionEvent
	 * @see it.h_umus.osc.OSCConnection
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 9+
	 */
	public class OSCTCPConnection extends Socket
	{
		/**
		 * Creates a new OSCTCPConnection. The OSCTCPConnection object is not initially 
		 * connected to any server. You must call the OSCTCPConnection.connect() 
		 * method to connect the object to a server.
		 * 
		 * @param inIp A fully qualified DNS domain name or an IP address in the 
		 * form aaa.bbb.ccc.ddd. You can also specify null to connect to the host 
		 * server on which the SWF file resides. If the SWF file issuing this call 
		 * is running in a web browser, host must be in the same domain as the SWF file.
		 * @param inPort The TCP port number on the host used to establish a 
		 * connection. The port number must be 1024 or greater, unless a policy 
		 * file is being used.
		 * 
		 * @see flash.net.Socket.connect
		 */	
		public function OSCTCPConnection(host:String=null, port:int=0)
		{
			super(host, port);
			addEventListener(ProgressEvent.SOCKET_DATA, onData);
		}
		
		/**
		 * This method is based on the touchgateway.com as3 classes by Dean North
		*/
		private function onData(e:ProgressEvent):void{
			var bytes:ByteArray = new ByteArray();
			readBytes(bytes);
			
			bytes.endian = Endian.BIG_ENDIAN;
			
			while(bytes.bytesAvailable > 0)
			{		
				var packet:OSCPacket = new OSCPacket();
				var path:String = readString(bytes);
				if(path != "")
				{
					if(path == "#bundle")
					{
						bytes.position+=8;
						var bundlelength:int = bytes.readInt();
						path = readString(bytes);
					}
					var datatypes:String = readString(bytes);
					var message:OSCMessage = new OSCMessage(path);
					for(var i:int=1;i<datatypes.length;i++)
					{
						switch (datatypes.charAt(i))
						{
							case "s" :
								var _string:String = readString(bytes); 
								message.addArg(new OSCArgument("s", _string));
								break;
							case "i" :
								var _int:int = bytes.readInt();
								message.addArg(new OSCArgument("i", _int));
								break;
							case "f" :
								var _float:float = bytes.readFloat();
								message.addArg(new OSCArgument("f", _float));
								break;
						}
					}
					packet.addMessage(message);
					dispatchEvent(new OSCConnectionEvent(OSCConnectionEvent.OSC_PACKET_IN,packet));
				}
			}
		}
		
		/**
		 * This method is get from the touchgateway.com as3 classes by Dean North
		 */
		private function readString(byteArray:ByteArray):String
		{
			var str:String = "";
			while(byteArray.readByte() != 0)
			{
				byteArray.position-=1;
				str += byteArray.readUTFBytes(1);
			}
			byteArray.position += 3-(str.length % 4)
			return str;
		}
	}
}
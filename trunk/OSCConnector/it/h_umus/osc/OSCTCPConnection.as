package it.h_umus.osc
{
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class OSCTCPConnection extends Socket
	{
		public function OSCTCPConnection(host:String=null, port:int=0)
		{
			super(host, port);
			addEventListener(ProgressEvent.SOCKET_DATA, onData);
		}
		
		private function onData(e:ProgressEvent):void{
			var bytes:ByteArray = new ByteArray();
			readBytes(bytes);
			
			bytes.endian = Endian.BIG_ENDIAN;
			
			while(bytes.bytesAvailable > 0){
			
				var packet:OSCPacket = new OSCPacket();
				
				var path:String = readString(bytes);
				if(path != ""){
					if(path == "#bundle"){
						bytes.position+=8;
						var bundlelength:int = bytes.readInt();
						path = readString(bytes);
					}
				
					var datatypes:String = readString(bytes);
					
					//var data:Array = new Array();
					//data.push(path);
					
					var message:OSCMessage = new OSCMessage(path);
					
					for(var i:int=1;i<datatypes.length;i++){
						switch (datatypes.charAt(i)){
							case "s" :
								var _string:String = readString(bytes); 
								//data.push(_string);
								message.addArg(new OSCArgument("s", _string));
								break;
							case "i" :
								var _int:int = bytes.readInt();
								//data.push(_int);
								message.addArg(new OSCArgument("i", _int));
								break;
							case "f" :
								var _float:float = bytes.readFloat();
								//data.push(_float);
								message.addArg(new OSCArgument("f", _float));
								break;
						}
					}
					
					packet.addMessage(message);
					
					//this.dispatchEvent(new MessageEvent(MessageEvent.MESSAGE_RECEIVED,true,true,data));
					//trace(data);
					dispatchEvent(new OSCConnectionEvent(OSCConnectionEvent.OSC_PACKET_IN,packet));
				}
				
			}
		}
		
		
		 private function readString(byteArray:ByteArray):String{
			var str:String = "";
			while(byteArray.readByte() != 0){
				byteArray.position-=1;
				str += byteArray.readUTFBytes(1);
			}
			byteArray.position += 3-(str.length % 4)
			return str;
		}
		
	}
}
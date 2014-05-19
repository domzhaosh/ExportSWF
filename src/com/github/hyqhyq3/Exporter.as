package com.github.hyqhyq3
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.PNGEncoder;
	import mx.utils.StringUtil;

	public class Exporter
	{
		private var _path:String;
		private var _singleFile:Boolean;
		private var _mc:Object;
		
		
		private var _blocks:Array;
		private var _root:Object;
		private var _filename:String = "";
		
		public function Exporter(mc:Object, path:String, singleFile:Boolean, filename:String = "")
		{
			_mc = mc;
			_path = path;
			_singleFile = singleFile;
			_filename = filename;
			if(_singleFile)
			{
				_blocks = [];
				for(var name:String in mc)
				{
					_blocks = _blocks.concat(mc[name]);
				}
				var packer:BinPacker = new BinPacker();
				packer.fit(_blocks);
				_root = packer.root;
			} else {
				_root = {};
				for(var name:String in mc)
				{
					var packer:BinPacker = new BinPacker();
					packer.fit(mc[name]);
					_root[name] = packer.root;
				}
			}
		}
		
		private function drawBitmapArray(w:int, h:int, data:Array):BitmapData
		{
			var bd:BitmapData = new BitmapData(w, h, true, 0);
			for(var i = 0; i < data.length; i++)
			{
				var mat:Matrix = new Matrix();
				mat.translate(data[i].fit.x, data[i].fit.y);
				bd.draw(data[i].bitmap, mat);
			}
			return bd;
		}
		
		private function writeDataToFile(data:ByteArray, filename:String):void
		{
			var png:FileStream = new FileStream;
			png.open(new File(filename), FileMode.WRITE);
			png.writeBytes(data);
			png.close();
		}
		
		private function writeBitmapToFile(bitmap:BitmapData, filename:String):void
		{
			var encoder:PNGEncoder = new PNGEncoder;
			var ba:ByteArray = encoder.encode(bitmap);
			writeDataToFile(ba, filename);
		}
		
		private function exportSingle():void
		{
			var plist:Object = {};
			plist.frames = {};
			for(var i = 0; i < _blocks.length; i++)
			{
				var data:Object = _blocks[i];
				var frame:Object = {};
				frame.sourceColorRect = "{{0,0},{" + data.w + "," + data.h + "}}";
				frame.spriteOffset = "{0,0}";
				frame.spriteSize = "{" + data.w + "," + data.h + "}";
				frame.spriteSourceSize = "{" + data.w + "," + data.h + "}";
				frame.spriteTrimmed = false;
				frame.textureRect = "{{" + data.fit.x + "," + data.fit.y + "},{" + data.w + "," + data.h + "}}";
				frame.textureRotated = false;
				frame.aliases = [];
				plist.frames[data.name] = frame;
			}
			plist.metadata = {
				format: 3,
				size: "{" + _root.w + "," + _root.h + "}",
				target: {
					name: _filename + ".png",
					textureFileName: _filename,
					textureExtension: "png",
					premultipliedAlpha: true
				}
			};
			
			writePlistToFile(plist, _path + "/" + _filename + ".plist");
			
			var bd:BitmapData = drawBitmapArray(_root.w, _root.h, _blocks);
			writeBitmapToFile(bd, _path + "/" + _filename + ".png");
		}
		
		private function writePlistToFile(plist:Object, filename:String):void
		{;
			var root:XML = <plist version="1.0"></plist>;
			var nodes:Array = [];
			nodes.push({xml:root, object:plist});
			while(nodes.length > 0)
			{
				var v:Object = nodes.shift();
				if(v.key)
				{
					v.xml.appendChild(<key>{v.object}</key>);
				}
				else if(v.object is Array)
				{
					var array:XML = <array/>;
					v.xml.appendChild(array);
					for each(var value:String in v.object)
					{
						nodes.push({xml:array, object: value});
					}
				}
				else if(typeof v.object == "object")
				{
					var dict:XML = <dict/>;
					v.xml.appendChild(dict);
					for(var name:String in v.object)
					{
						nodes.push({xml:dict, object:name, key: true});
						nodes.push({xml:dict, object:v.object[name]});
					}
				} 
				else if(typeof v.object == "string")
				{
					var string:XML = <string>{v.object}</string>;
					v.xml.appendChild(string);
				}
				else if(typeof v.object == "boolean")
				{
					if(v.object)
						v.xml.appendChild(<true/>);
					else
						v.xml.appendChild(<false/>);
				}
				else if(typeof v.object == "number")
				{
					v.xml.appendChild(<integer>{v.object}</integer>);
				}
			}
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(root.toString());
			writeDataToFile(ba, filename);
		}
		
		public function doExport():void
		{
			if(_singleFile)
			{
				exportSingle();
			} 
			else 
			{
				exportSeperate();
			}
		}
		
		private function exportSeperate():void
		{

			for(var name:String in _mc)
			{
				var bd:BitmapData = null;
				var bitmap:BitmapData = drawBitmapArray(_root[name].w, _root[name].h, _mc[name]);
				writeBitmapToFile(bitmap, _path + "/" + name + ".png");
				
				var plist:Object = {};
				plist.frames = {};
				for(var i = 0; i < _mc[name].length; i++)
				{
					var data:Object = _mc[name][i];
					var frame:Object = {};
					frame.sourceColorRect = "{{0,0},{" + data.w + "," + data.h + "}}";
					frame.spriteOffset = "{0,0}";
					frame.spriteSize = "{" + data.w + "," + data.h + "}";
					frame.spriteSourceSize = "{" + data.w + "," + data.h + "}";
					frame.spriteTrimmed = false;
					frame.textureRect = "{{" + data.fit.x + "," + data.fit.y + "},{" + data.w + "," + data.h + "}}";
					frame.textureRotated = false;
					plist.frames[data.name] = frame;
				}
				plist.metadata = {
					format: 3,
					size: "{" + _root[name].w + "," + _root[name].h + "}",
						target: {
							name: name + ".png",
								textureFileName: name,
								textureExtension: "png",
								premultipliedAlpha: true
						}
				};
				
				writePlistToFile(plist, _path + "/" + name + ".plist");
			}
		}
		
		protected function calcSize(width:Number, height:Number, num:Number):Rectangle
		{
			var n:Number = 0;
			var p:Point = new Point;
			var row:Number = 0;
			var col:Number = 0;
			while(n < num)
			{
				if(p.y >= p.x)
				{
					col++;
					p.x = p.x + width;
				} else {
					row++;
					p.y = p.y + height;
				}
				n = col*row;
			}
			return new Rectangle(0, 0, col * width, row * height);
		}
		
	}
}
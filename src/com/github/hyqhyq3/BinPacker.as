package com.github.hyqhyq3
{
	public class BinPacker
	{
		private var _root:Object;
		public function BinPacker()
		{
		}
		
		public function get root():Object
		{
			return _root;
		}

		public function fit(blocks:Array):void
		{
			var node:Object;
			_root = {x:0, y:0, w:blocks[0].w, h:blocks[0].h };
			for(var n:int; n < blocks.length; n++)
			{
				var block:Object = blocks[n];
				node = findNode(_root, block.w, block.h);
				if(node != null)
				{
					block.fit = splitNode(node, block.w, block.h);
				}
				else 
				{
					block.fit = growNode(block.w, block.h);
				}
			}
		}
		
		private function findNode(_root:Object, w:int, h:int):Object
		{
			if (_root.used)
			{
				return findNode(_root.right, w, h) || findNode(_root.down, w, h);
			} 
			else if ((w <= _root.w) && (h <= _root.h)) 
			{
				return _root;
			}
			else
			{
				return null;
			}
		}
		
		private function splitNode(node:Object, w:int, h:int):Object
		{
			node.used = true;
			node.down  = { x: node.x,     y: node.y + h, w: node.w,     h: node.h - h };
			node.right = { x: node.x + w, y: node.y,     w: node.w - w, h: h          };
			return node;
		}
		
		private function growNode(w:int, h:int):Object
		{
			var canGrowDown:Boolean  = (w <= _root.w);
		    var canGrowRight:Boolean = (h <= _root.h);
		
		    var shouldGrowRight:Boolean = canGrowRight && (_root.h >= (_root.w + w)); // attempt to keep square-ish by growing right when height is much greater than width
		    var shouldGrowDown:Boolean  = canGrowDown  && (_root.w >= (_root.h + h)); // attempt to keep square-ish by growing down  when width  is much greater than height
			
			if (shouldGrowRight)
				return growRight(w, h);
			else if (shouldGrowDown)
				return growDown(w, h);
			else if (canGrowRight)
				return growRight(w, h);
			else if (canGrowDown)
				return growDown(w, h);
			else
				return null;
		}
		
		private function growRight(w:int, h:int):Object
		{
			_root = {
				used: true,
				x: 0,
				y: 0,
				w: _root.w + w,
					h: _root.h,
					down: _root,
					right: { x: _root.w, y: 0, w: w, h: _root.h }
			};
			var node:Object = findNode(_root, w, h); 
			if (node)
				return splitNode(node, w, h);
			else
				return null
		}
		
		private function growDown(w:int, h:int):Object
		{
			_root = {
				used: true,
				x: 0,
				y: 0,
				w: _root.w,
					h: _root.h + h,
					down:  { x: 0, y: _root.h, w: _root.w, h: h },
					right: _root
			};
			var node:Object = findNode(_root, w, h)
			if (node)
			{
				return splitNode(node, w, h);
			}
			else
			{
				return null;
			}
		}
	}
}
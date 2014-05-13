package com.github.hyqhyq3
{
	public class ZeroPadded
	{
		private static const _ZEROS:String = "0000000000000000000000000000000000000000"; // 40 zeros, shorten/expand as you wish
		
		/*
		* f: positive integer value
		* z: maximum number of leading zeros of the numeric part (sign takes one extra digit)
		*/
		public static function uint_Zeropadded(f:uint, z:int = 0):String {
			var result:String = f.toString();
			while (result.length < z)
				result = _ZEROS.substr(0, z - result.length) + result;
			return result;
		}
	}
}
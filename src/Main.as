package {
	
	import flash.display.MovieClip;
	
	[SWF(width="462", height="692", backgroundColor = "0xffffff", frameRate="60")]
	public class Main extends MovieClip {
		
		private var _calculator:JiuMiTaxCalculator;
		
		public function Main() {
			// constructor code
			
			_calculator = new JiuMiTaxCalculator();
			addChild(_calculator);
		}
	}
	
}

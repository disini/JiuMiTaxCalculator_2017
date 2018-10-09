package
{
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	/**
	 * 
	 * @author LiuSheng  QQ:532230294
	 * 创建时间 : 2017-3-15 下午4:22:02
	 *
	 */
	public class JiuMiTaxCalculator extends Calculator_Clip
	{
		public static const VERSION_DESC:String="五险一金个税计算器-2017版V1.0.0";
		public static const SITE_DESC:String="访问官网";
		public static const SITE_URL:String="http://blog.csdn.net/jinshelj";
		public static const CEILING_NUMBER:Number = 21258;
		public static const BOTTOM_NUMBER:Number = 2835;
		private var _alertPanel1:AlertPanel1 = new AlertPanel1();
		private var _alertPanel2:AlertPanel2 = new AlertPanel2();
		
		private var versionMenu:ContextMenuItem;
		private var siteMenu:ContextMenuItem;
		private var menu:ContextMenu=new ContextMenu();
		
		private var  _taxRateArr:Array = [3, 10, 20, 25, 30, 35, 45];
		private var  _rapidDeductionArr:Array = [0, 105, 555, 1005, 2755, 5505, 13505];
		
		/** 税前月收入 */
		private var _originSalary:Number;
		/** 税后月收入 */
		private var _finalSalary:Number;
		/** 缴纳个税 */
		private var _tax:Number;
		
		// --------------------------------------------------------------个人部分--------------------------------------------------//
		
		/** 个人缴费合计 */
		private var _selfAffordInsurance:Number;
		/** 应纳税额总计 */
		private var _salaryTocalculateTax:Number;
		/** 养老(个人部分) */
		private var _selfAffordPension:Number;
		/** 医疗(个人部分) */
		private var _selfAffordMedical:Number;
		/** 失业(个人部分) */
		private var _selfAffordEmploymentInsurance:Number;
		/** 公积金(个人部分) */
		private var _selfAffordReservedFund:Number;
		
		
		/** 养老险 百分比(个人部分) */
		private var _selfAffordPensionRate:Number;
		/** 医疗险 百分比(个人部分) */
		private var _selfAffordMedicalRate:Number;
		/** 失业险 百分比(个人部分) */
		private var _selfAffordEmploymentInsuranceRate:Number;
		/** 公积金(个人部分) */
		private var _selfAffordReservedFundRate:Number;
		
		// --------------------------------------------------------------单位部分--------------------------------------------------//
		
		/** 单位缴费合计 */
		private var _employerAffordInsurance:Number;
		/** 单位支出总计 */
		private var _totalPayByEmployer:Number;
		/** 养老(单位部分) */
		private var _employerAffordPension:Number;
		/** 医疗(单位部分) */
		private var _employerAffordMedical:Number;
		/** 失业(单位部分) */
		private var _employerAffordEmploymentInsurance:Number;
		/** 工伤(单位部分) */
		private var _employerAffordIndustrialInjuryInsurance:Number;
		/** 生育(单位部分) */
		private var _employerAffordFertilityInsurance:Number;
		
		/** 公积金(单位部分) */
		private var _employerAffordReservedFund:Number;
		
		
		/** 养老险 百分比(单位部分) */
		private var _employerAffordPensionRate:Number;
		/** 医疗险 百分比(单位部分) */
		private var _employerAffordMedicalRate:Number;
		/** 失业险 百分比(单位部分) */
		private var _employerAffordEmploymentInsuranceRate:Number;
		/** 工伤险 百分比(单位部分) */
		private var _employerAffordIndustrialInjuryInsuranceRate:Number;
		/** 生育险 百分比(单位部分) */
		private var _employerAffordFertilityInsuranceRate:Number;
		/** 公积金(单位部分) */
		private var _employerAffordReservedFundRate:Number;
		
		// --------------------------------------------------------------底栏（缴费基数，封顶数， 个税起征点）-------------------------------------------------//
		
		/** 缴费基数：社保 */
		private var _insuranceBase:Number;
		/** 公积金 */
		private var _reservedFundBase:Number;
		/** 封顶数*/
		private var _ceilingNumber:Number;
		/** 个税起征点 */
		private var _taxExemptionThreshold:Number;
		
		public function JiuMiTaxCalculator()
		{
			initContextMenu();
			initTfs();
			initButtons();
//			initPanel();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStageHandler);
		}
		
		protected function onAddedToStageHandler(event:Event):void
		{
			initPanel();
		}
		
		private function initPanel():void
		{
			// TODO Auto Generated method stub
//			_alertPanel1.x = (stage.stageWidth - _alertPanel1.width) / 2;
//			_alertPanel1.y = (stage.stageHeight- _alertPanel1.height) / 2;
			_alertPanel1.x = stage.stageWidth / 2;
			_alertPanel1.y = stage.stageHeight / 2;
			addChild(_alertPanel1);
			_alertPanel1.visible = false;
			_alertPanel1.enter_btn.addEventListener(MouseEvent.CLICK, onCloseAlertPanel1);
			_alertPanel1.close_btn.addEventListener(MouseEvent.CLICK, onCloseAlertPanel1);
			
			_alertPanel2.x = stage.stageWidth / 2;
			_alertPanel2.y = stage.stageHeight / 2;
			addChild(_alertPanel2);
			_alertPanel2.visible = false;
			_alertPanel2.enter_btn.addEventListener(MouseEvent.CLICK, onCloseAlertPanel1);
			_alertPanel2.close_btn.addEventListener(MouseEvent.CLICK, onCloseAlertPanel1);
		}
		
		private function initContextMenu():void
		{
			// TODO Auto Generated method stub
			versionMenu=new ContextMenuItem(VERSION_DESC);
			siteMenu = new ContextMenuItem(SITE_DESC);
			siteMenu.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItem_click);
			menu.hideBuiltInItems();
			menu.customItems.push(versionMenu, siteMenu);
			this.contextMenu=menu;
		}
		
		protected function menuItem_click(evt:ContextMenuEvent):void
		{
			navigateToURL(new URLRequest(SITE_URL));
		}
		
		private function initTfs():void
		{
			// TODO Auto Generated method stub
			for(var i:int = 0; i < this.numChildren;i++)
			{
				var tf:TextField = this.getChildAt(i) as TextField;
				if(tf && (tf.type == TextFieldType.INPUT || tf.type == TextFieldType.INPUT))
				{
					tf.restrict = "0-9\\.";
//					tf.maxChars = 12;
					trace("tf.name == " + tf.name);
				}
			}
		}
		
		private function initButtons():void
		{
			// TODO Auto Generated method stub
			calc_Btn.addEventListener(MouseEvent.CLICK, onCalculateHandler);
			reverseCalc_Btn.addEventListener(MouseEvent.CLICK, onReverseCalculateHandler);
			reset_Btn.addEventListener(MouseEvent.CLICK, onResetHandler);
		}
		
		protected function onCalculateHandler(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
//			if(originSalary_txt.text == "" || selfAffordPensionRate_txt.text == "" || selfAffordMedicalRate_txt.text == "" || selfAffordEmploymentInsuranceRate_txt.text == "" || selfAffordReservedFundRate_txt.text == "" || employerAffordPensionRate_txt.text == "" || employerAffordMedicalRate_txt.text == "" || employerAffordEmploymentInsuranceRate_txt.text == "" || employerAffordIndustrialInjuryInsuranceRate_txt.text == "" || employerAffordFertilityInsuranceRate_txt.text == "" || employerAffordReservedFundRate_txt.text == "" || insuranceBase_txt.text == "" || reservedFundBase_txt.text == "" || ceilingNumber_txt.text == "" || taxExemptionThreshold_txt.text == "")
			if(originSalary_txt.text == "" || selfAffordPensionRate_txt.text == "" || selfAffordMedicalRate_txt.text == "" || selfAffordEmploymentInsuranceRate_txt.text == "" || selfAffordReservedFundRate_txt.text == "" || employerAffordPensionRate_txt.text == "" || employerAffordMedicalRate_txt.text == "" || employerAffordEmploymentInsuranceRate_txt.text == "" || employerAffordIndustrialInjuryInsuranceRate_txt.text == "" || employerAffordFertilityInsuranceRate_txt.text == "" || employerAffordReservedFundRate_txt.text == "" || ceilingNumber_txt.text == "" || taxExemptionThreshold_txt.text == "")
			{
				return;
			}else
			{
				// 取值：
				_originSalary = Number(originSalary_txt.text);
				if(_originSalary < BOTTOM_NUMBER)
				{
					onSalaryTooLowAlert();
					return;
				}
				
				/*_reservedFundBase = _insuranceBase = _originSalary < BOTTOM_NUMBER ? BOTTOM_NUMBER : (_originSalary < CEILING_NUMBER ? _originSalary : CEILING_NUMBER);
				if(Number(insuranceBase_txt.text) != 0 && Number(insuranceBase_txt.text) <= _originSalary)
				{
					_insuranceBase = Number(insuranceBase_txt.text);
				}
				else
				{
					insuranceBase_txt.text = String(_insuranceBase);
				}
				
				if(Number(reservedFundBase_txt.text) != 0 && Number(reservedFundBase_txt.text) <= _originSalary)
				{
					_reservedFundBase = Number(reservedFundBase_txt.text);
				}
				else
				{
					reservedFundBase_txt.text = String(_reservedFundBase);
				}*/
				
				commonGetValues();
				
				if(Number(insuranceBase_txt.text) != 0)
				{
					_reservedFundBase = _insuranceBase = _insuranceBase < BOTTOM_NUMBER ? BOTTOM_NUMBER : (_insuranceBase < CEILING_NUMBER ? _insuranceBase : CEILING_NUMBER);
				}
				
				commonCaculate();
				
				// 应纳税额总计:
				_salaryTocalculateTax = _originSalary - _selfAffordInsurance - _taxExemptionThreshold;// 税前月收入 - 个人缴费合计 - 个税起征点
				if(_salaryTocalculateTax > 0)
				{
					// ------------------------------------------------------顶部红字部分--------------------------------------------------------------//
					
					
					_tax = calculateTax1(_salaryTocalculateTax);
				}
				else
				{
					_salaryTocalculateTax = 0;
					_tax = 0;
				}
				
				// 单位支出总计:（税前月收入 + 单位缴费合计）
				_totalPayByEmployer = _originSalary + _employerAffordInsurance;
				totalPayByEmployer_txt.text = formatStr1(_totalPayByEmployer);
				
				salaryTocalculateTax_txt.text = formatStr1(_salaryTocalculateTax);
				tax_txt.text = formatStr1(_tax);
				
				_finalSalary = _originSalary - _selfAffordInsurance - _tax;
				finalSalary_txt.text = formatStr1(_finalSalary);
			}
		}
		
		private function commonGetValues():void
		{
			// TODO Auto Generated method stub
			_selfAffordPensionRate = Number(selfAffordPensionRate_txt.text);
			_selfAffordMedicalRate = Number(selfAffordMedicalRate_txt.text);
			_selfAffordEmploymentInsuranceRate = Number(selfAffordEmploymentInsuranceRate_txt.text);
			_selfAffordReservedFundRate = Number(selfAffordReservedFundRate_txt.text);
			_employerAffordPensionRate = Number(employerAffordPensionRate_txt.text); 
			_employerAffordMedicalRate = Number(employerAffordMedicalRate_txt.text);
			_employerAffordEmploymentInsuranceRate = Number(employerAffordEmploymentInsuranceRate_txt.text);
			_employerAffordIndustrialInjuryInsuranceRate = Number(employerAffordIndustrialInjuryInsuranceRate_txt.text); 
			_employerAffordFertilityInsuranceRate = Number(employerAffordFertilityInsuranceRate_txt.text);
			_employerAffordReservedFundRate = Number(employerAffordReservedFundRate_txt.text);
			
			_insuranceBase = Number(insuranceBase_txt.text);
			_reservedFundBase = Number(reservedFundBase_txt.text);
			
			if(insuranceBase_txt.text == "")
			{
				insuranceBase_txt.text = "0";
			}
			
			if(reservedFundBase_txt.text == "")
			{
				reservedFundBase_txt.text = "0";
			}
				
			
			
			
			
			_ceilingNumber = Number(ceilingNumber_txt.text);
			_taxExemptionThreshold = Number(taxExemptionThreshold_txt.text);
		}
		
		private function commonCaculate():void
		{
			// TODO Auto Generated method stub
			//计算：
			// ------------------------------------------------------个人部分--------------------------------------------------------------//
			// 养老 （个人）
			_selfAffordPension = (_insuranceBase * _selfAffordPensionRate / 100);
			selfAffordPension_txt.text = formatStr1(_selfAffordPension);
			// 医疗（个人）
			_selfAffordMedical = _insuranceBase > 0 ?(_insuranceBase * _selfAffordMedicalRate / 100) + 3 : 0;
			selfAffordMedical_txt.text = formatStr1(_selfAffordMedical);
			// 失业（个人）
			_selfAffordEmploymentInsurance = (_insuranceBase * _selfAffordEmploymentInsuranceRate / 100);
			selfAffordEmploymentInsurance_txt.text = formatStr1(_selfAffordEmploymentInsurance);
			// 公积金（个人）
			_selfAffordReservedFund = (_insuranceBase * _selfAffordReservedFundRate / 100);
			selfAffordReservedFund_txt.text = formatStr1(_selfAffordReservedFund);
			
			
			// 个人缴费合计:
			_selfAffordInsurance = _selfAffordPension + _selfAffordMedical + _selfAffordEmploymentInsurance + _selfAffordReservedFund;
			selfAffordInsurance_txt.text = formatStr1(_selfAffordInsurance);
			
			
			
			// ------------------------------------------------------单位部分--------------------------------------------------------------//
			// 养老（单位）
			_employerAffordPension = (_insuranceBase * _employerAffordPensionRate / 100);
			employerAffordPension_txt.text = formatStr1(_employerAffordPension);
			
			// 医疗（单位）
			_employerAffordMedical = (_insuranceBase * _employerAffordMedicalRate / 100);
			employerAffordMedical_txt.text = formatStr1(_employerAffordMedical);
			
			// 失业（单位）
			_employerAffordEmploymentInsurance = (_insuranceBase * _employerAffordEmploymentInsuranceRate / 100);
			employerAffordEmploymentInsurance_txt.text = formatStr1(_employerAffordEmploymentInsurance);
			
			// 工伤（单位）
			_employerAffordIndustrialInjuryInsurance = (_insuranceBase * _employerAffordIndustrialInjuryInsuranceRate / 100);
			employerAffordIndustrialInjuryInsurance_txt.text = formatStr1(_employerAffordIndustrialInjuryInsurance);
			
			// 生育（单位）
			_employerAffordFertilityInsurance = (_insuranceBase * _employerAffordFertilityInsuranceRate / 100);
			employerAffordFertilityInsurance_txt.text = formatStr1(_employerAffordFertilityInsurance);
			
			// 公积金（单位）
			_employerAffordReservedFund = (_insuranceBase * _employerAffordReservedFundRate / 100);
			employerAffordReservedFund_txt.text = formatStr1(_employerAffordReservedFund);
			
			// 单位缴费合计:
			_employerAffordInsurance = _employerAffordPension + _employerAffordMedical + _employerAffordEmploymentInsurance + _employerAffordIndustrialInjuryInsurance + _employerAffordFertilityInsurance + _employerAffordReservedFund;  
			employerAffordInsurance_txt.text = formatStr1(_employerAffordInsurance);
		}
		
		/**
		 * 计算所得税（正推）
		 * @param salaryTocalc
		 * @return 
		 * 
		 */		
		private function calculateTax1(salaryTocalc:Number):Number
		{
			// TODO Auto Generated method stub
			
			if(salaryTocalc <= 0)
				return 0;
			var curStage:int;
			
			curStage = calculateSalaryStage1(salaryTocalc);
			
			
			/*个人所得税计算公式
			应纳税所得额 = 税前工资收入金额 － 五险一金(个人缴纳部分) － 起征点(3500元)
			应纳税额 = 应纳税所得额 x 税率 － 速算扣除数*/
			return salaryTocalc * _taxRateArr[curStage] / 100 - _rapidDeductionArr[curStage];
		}
		
		/**
		 * 计算所得税（反推）
		 * @param salaryTocalc
		 * @return 
		 * 
		 */		
		private function calculateTax2(finalSalary:Number):Number
		{
			// TODO Auto Generated method stub
			var curStage:int;
			
			curStage = calculateSalaryStage2(finalSalary);
			
			
			/*个人所得税计算公式
			应纳税所得额 = 税前工资收入金额 － 五险一金(个人缴纳部分) － 起征点(3500元)
			应纳税额 = 应纳税所得额 x 税率 － 速算扣除数*/
//			return salaryTocalc * _taxRateArr[curStage] / 100 - _rapidDeductionArr[curStage];
			return 0;
		}
		
		
		
		
		private function calculateSalaryStage1(salaryTocalc:Number):int
		{
			// TODO Auto Generated method stub
			var curStage:int;
			if(salaryTocalc > 0 && salaryTocalc <= 1500)
			{
				curStage = 0;
			}
			else if(salaryTocalc > 1500 && salaryTocalc <= 4500)
			{
				curStage = 1;
			}
			else if(salaryTocalc > 4500 && salaryTocalc <= 9000)
			{
				curStage = 2;
			}
			else if(salaryTocalc > 9000 && salaryTocalc <= 35000)
			{
				curStage = 3;
			}
			else if(salaryTocalc > 35000 && salaryTocalc <= 55000)
			{
				curStage = 4;
			}
			else if(salaryTocalc > 55000 && salaryTocalc <= 80000)
			{
				curStage = 5;
			}
			else if(salaryTocalc > 80000)
			{
				curStage = 6;
			}
			
			return curStage;
		}
		
		private function calculateSalaryStage2(finalSalary:Number):int
		{
			var curStage:int;
			if(finalSalary > 0 && finalSalary <= 4955)
			{
				curStage = 0;
			}
			else if(finalSalary > 4955 && finalSalary <= 7655)
			{
				curStage = 1;
			}
			else if(finalSalary > 7655 && finalSalary <= 11255)
			{
				curStage = 2;
			}
			else if(finalSalary > 11255 && finalSalary <= 30755)
			{
				curStage = 3;
			}
			else if(finalSalary > 30755 && finalSalary <= 44755)
			{
				curStage = 4;
			}
			else if(finalSalary > 44755 && finalSalary <= 61005)
			{
				curStage = 5;
			}
			else if(finalSalary > 61005)
			{
				curStage = 6;
			}
			
			return curStage;
		}	
		
		
		private function calculateSalaryStage3(tax:Number):int
		{
			var curStage:int;
			if(tax > 0 && tax <= 45)
			{
				curStage = 0;
			}
			else if(tax > 45 && tax <= 345)
			{
				curStage = 1;
			}
			else if(tax > 345 && tax <= 1245)
			{
				curStage = 2;
			}
			else if(tax > 1245 && tax <= 7745)
			{
				curStage = 3;
			}
			else if(tax > 7745 && tax <= 13745)
			{
				curStage = 4;
			}
			else if(tax > 13745 && tax <= 22495)
			{
				curStage = 5;
			}
			else if(tax > 22495)
			{
				curStage = 6;
			}
			
			return curStage;
		}	
		
		/**
		 * 反推 
		 * @param event
		 * 
		 */		
		protected function onReverseCalculateHandler(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			
			if((finalSalary_txt.text == "" && tax_txt.text == "") || selfAffordPensionRate_txt.text == "" || selfAffordMedicalRate_txt.text == "" || selfAffordEmploymentInsuranceRate_txt.text == "" || selfAffordReservedFundRate_txt.text == "" || employerAffordPensionRate_txt.text == "" || employerAffordMedicalRate_txt.text == "" || employerAffordEmploymentInsuranceRate_txt.text == "" || employerAffordIndustrialInjuryInsuranceRate_txt.text == "" || employerAffordFertilityInsuranceRate_txt.text == "" || employerAffordReservedFundRate_txt.text == "" || insuranceBase_txt.text == "" || reservedFundBase_txt.text == "" || ceilingNumber_txt.text == "" || taxExemptionThreshold_txt.text == "")
			{
				return;
			}else
			{
			
				_finalSalary = Number(finalSalary_txt.text);
				_tax = Number(tax_txt.text);
				var curStage:int;
				var _finalSalary2:Number = _finalSalary - _taxExemptionThreshold;
//				_insuranceBase = Number(insuranceBase_txt.text);
//				_reservedFundBase = Number(reservedFundBase_txt.text);
				
				if(_finalSalary != 0)
				{
					
					commonGetValues();				
					commonCaculate();
					curStage = calculateSalaryStage2(_finalSalary);
					_salaryTocalculateTax = (_rapidDeductionArr[curStage] - _finalSalary2) / (_taxRateArr[curStage] / 100 - 1);
					salaryTocalculateTax_txt.text =formatStr1(_salaryTocalculateTax);// 应纳税额总计
					
					
					_tax = _salaryTocalculateTax - _finalSalary2;
					tax_txt.text = formatStr1(_tax);// 缴纳个税
				}
				else if(_tax != 0)
				{
					commonGetValues();				
					commonCaculate();
					curStage = calculateSalaryStage3(_tax);
//					_tax = (_rapidDeductionArr[curStage] - _finalSalary2) / (_taxRateArr[curStage] / 100 - 1) - _finalSalary2;
//					tax_txt.text = formatStr1(_tax);// 缴纳个税
					
					_salaryTocalculateTax = (_tax + _rapidDeductionArr[curStage]) / (_taxRateArr[curStage] / 100);
					salaryTocalculateTax_txt.text =formatStr1(_salaryTocalculateTax);// 应纳税额总计
					
					_finalSalary = _salaryTocalculateTax  - _tax + _taxExemptionThreshold;
					finalSalary_txt.text = formatStr1(_finalSalary);// 税后月收入
				}
				
				_originSalary = _salaryTocalculateTax + _selfAffordInsurance + _taxExemptionThreshold;
				originSalary_txt.text =formatStr1(_originSalary);// 税前月收入
				
				_totalPayByEmployer = _originSalary + _employerAffordInsurance;
				totalPayByEmployer_txt.text = formatStr1(_totalPayByEmployer);
			}
			
		
			
			
		}
		
		/**
		 * 重置 
		 * @param event
		 * 
		 */		
		protected function onResetHandler(event:MouseEvent):void
		{
			// 税前月收入
			_originSalary = 0;
			originSalary_txt.text = "";
			// 养老	（个人）
			_selfAffordPension = 0;
			selfAffordPension_txt.text = "";
			// 医疗（个人）
			_selfAffordMedical = 0;
			selfAffordMedical_txt.text = "";
			// 失业（个人）
			_selfAffordEmploymentInsurance = 0;
			selfAffordEmploymentInsurance_txt.text = "";
			// 公积金（个人）
			_selfAffordReservedFund = 0;
			selfAffordReservedFund_txt.text = "";
			
			
			// 个人缴费合计:
			_selfAffordInsurance = 0;
			selfAffordInsurance_txt.text = "";
			
			// 应纳税额总计:
			_salaryTocalculateTax = 0;
			salaryTocalculateTax_txt.text = "";
			
			// ------------------------------------------------------单位部分--------------------------------------------------------------//
			// 养老（单位）
			_employerAffordPension = 0;
			employerAffordPension_txt.text = "";
			
			// 医疗（单位）
			_employerAffordMedical = 0;
			employerAffordMedical_txt.text = "";
			
			// 失业（单位）
			_employerAffordEmploymentInsurance = 0;
			employerAffordEmploymentInsurance_txt.text = "";
			
			// 工伤（单位）
			_employerAffordIndustrialInjuryInsurance = 0;
			employerAffordIndustrialInjuryInsurance_txt.text = "";
			
			// 生育（单位）
			_employerAffordFertilityInsurance = 0;
			employerAffordFertilityInsurance_txt.text = "";
			
			// 公积金（单位）
			_employerAffordReservedFund = 0;
			employerAffordReservedFund_txt.text = "";
			
			// 单位缴费合计:
			_employerAffordInsurance = 0;
			employerAffordInsurance_txt.text = "";
			
			// 单位支出总计:（税前月收入 + 单位缴费合计）
			_totalPayByEmployer = 0;
			totalPayByEmployer_txt.text = "";
			
			// ------------------------------------------------------顶部红字部分--------------------------------------------------------------//
			
			_tax = 0;
			tax_txt.text = "";
			
			_finalSalary = 0;
			finalSalary_txt.text = "";
		}
		
		private function formatStr1(value:Number):String
		{
			var str:String = value.toFixed(2);
			return str;
		}
		
		private function onSalaryTooLowAlert():void
		{
			_alertPanel1.visible = true;
		}
		
		private function onNeedToInputValues():void
		{
			_alertPanel2.visible = true;
		}
		
		
		private function onCloseAlertPanel1(e:MouseEvent):void
		{
			_alertPanel1.visible = false;
		}
		
		private function onCloseAlertPanel2(e:MouseEvent):void
		{
			_alertPanel2.visible = false;
		}
		
	}
}
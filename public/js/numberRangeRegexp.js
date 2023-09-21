// https://www.simple-edition.com/js/numberRangeRegexp.js
//
//繰り返し文字列の作成
String.prototype.repeat = function(num) {
	for (var str = ""; (this.length * num) > str.length; str += this);
	return str;
};

//全角から半角へ変換
function toHalfWidth(strVal){
  // 半角変換
  var halfVal = strVal.replace(/[\uff08-\uff5e]/g,
    function( tmpStr ) {
      // 文字コードをシフト
      return String.fromCharCode( tmpStr.charCodeAt(0) - 0xFEE0 );
    }
  );
  // 文字コードシフトで対応できない文字の変換
  return halfVal
  	.replace(/＋/g, "+")
    .replace(/ー/g, "-")
    .replace(/−/g, "-")
    .replace(/×/g, "*")
    .replace(/÷/g, "/")
    .replace(/　/g, " ")
    ;
}

//正規表現パーツ文字の生成
function makeBrackets(str1, str2){
	str1 = String(str1);
	str2 = String(str2);
	if( str1 === str2 ){
		return str1;
	}else{
		return '[' + str1 + '-' + str2 + ']';
	}
}
function makeBraces(str1){
	str1 = String(str1);
	if (parseInt(str1) == 1){
		return '';
	}else{
		return '{' + str1 + '}';
	}
}


//数値範囲の正規表現を生成
function makeNumberRangeRegexp(start, end){
	if(start === '' && end === ''){//どちらも空の場合、終了
		return '';
	}else if(start === '' || end === ''){//どちらかの値が空の場合、同じ値を入れる
		if(start === '') start = end;
		if(end === '') end = start;
	}
	
	var start_value = parseInt(start);
	var end_value = parseInt(end);

	var isMinus = false;
	
	if( start_value < 0 && end_value < 0){//どちらもマイナス値の場合
		isMinus = true;
		start_value = -start_value;
		end_value = -end_value;
	}

	if(start_value == end_value){//start = end の場合
		return String(start_value);
	}else if(start_value > end_value){//start > end の場合、値を入れ替える
		var temp = start_value;
		start_value = end_value;
		end_value = temp;
	}

	/*if(end_value - start_value == 1){//差が１の場合
		return String(start_value) + '|' + String(end_value);
	}*/
	
	if(start_value < 0 && end_value >= 0){//startのみマイナス値の場合
		return makeNumberRangeRegexp(String(start_value), '-1') + '|'+ makeNumberRangeRegexp('0', String(end_value));
	}
	
	var start_str = String(start_value);
	var start_digit = start_str.length;//startの桁数
	var end_str = String(end_value);
	var end_digit = end_str.length;//endの桁数
	
	if(start_digit == end_digit){//start,endの桁数が同じ場合
		var diff_digit = 0;
		for(i = 0; i < start_digit; i++){
			if(start_str.charAt(i) !== end_str.charAt(i)){
				diff_digit = start_digit - i;
				break;
			}
		}
		if(diff_digit == 1){//start,endの違いが1桁目だけの場合
			var ex = '';
			if(start_digit > 1){
				ex = start_str.substr(0, start_digit - 1);
			}
			ex = ex + makeBrackets(start_str.charAt(start_digit - 1),end_str.charAt(start_digit - 1));
			return ex;
		}
	}

	var lower_thre;//下位領域のしきい値
	var upper_thre;//上位領域のしきい値

	var exL = ""; //下位領域
	if(start_str.match(/^[1-9]0+$/)){//startがx000...の場合
		lower_thre = start_str;
	}else if(start_str.match(/^[1-9]9+$/)){//startがx999...の場合
		exL = start_str + '|';
		lower_thre = String(parseInt(start_str) + 1);
	}else{
		if(start_digit == 1){
			exL = makeBrackets(start_str,9) + '|'; //startが１桁の場合
			lower_thre = String('10');
		}else{
			for(var i = 1; i < start_digit; i++){
				if(i == 1){
					exL = exL + start_str.substr(0, start_digit - i) + makeBrackets(parseInt(start_str.charAt(start_digit - i)),9)  + '|';
				}else if(parseInt(start_str.charAt(start_digit - i)) != 9){
					if(parseInt(start_str.substr(0, start_digit - i) + '9'.repeat(i)) <= end_value){
						exL = exL + start_str.substr(0, start_digit - i) + makeBrackets(parseInt(start_str.charAt(start_digit - i)) + 1,9) ;
						if(i-1 > 0){
							exL = exL + '[0-9]' + makeBraces(i-1) ;
						}
						exL = exL + '|';
					}
				}
			}
			lower_thre = String(parseInt(start_str.charAt(0)) + 1) + '0'.repeat(start_digit - 1);
		}
	}
//	window.console.log('lower_thre:' + lower_thre);

	var exU = ''; //上位領域
	if(end_str.match(/^[1-9]9+$/)){
		upper_thre = end_str;
	}else if(end_str.match(/^[1-9]0+$/)){
		exU = end_str;
		upper_thre = String(parseInt(end_str) - 1);
	}else{
		for(var i = 1; i < end_digit - 1; i++){
			if(parseInt(end_str.charAt(i)) >= 1){
				if(parseInt(end_str.substr(0, i) + String(parseInt(end_str.charAt(i)) - 1) + '9'.repeat(end_digit - i -1)) <= end_value &&
				   parseInt(end_str.substr(0, i) + String(parseInt(end_str.charAt(i)) - 1) + '0'.repeat(end_digit - i -1)) >= start_value  ){
					exU = exU + end_str.substr(0, i) + makeBrackets(0, parseInt(end_str.charAt(i)) - 1) + '[0-9]' + makeBraces(end_digit - i -1) + '|';
				}
			}
		}
		exU = exU + end_str.substr(0, end_digit - 1) + makeBrackets(0, end_str.charAt(end_digit - 1));
		upper_thre = String(parseInt(String(parseInt(end_str.charAt(0)) - 1) + '9'.repeat(end_digit - 1)));
	}
//	window.console.log('upper_thre:' + upper_thre);

	var exM = ""; //中位領域

	if(lower_thre < upper_thre){
		var lower_digit = lower_thre.length;
		var upper_digit = upper_thre.length;
		
		for(var i = 0; i <= upper_digit - lower_digit; i++){
			if(lower_digit + i < upper_digit){
				exM = exM + makeBrackets(lower_thre.charAt(0), 9) + '[0-9]' + makeBraces(parseInt(lower_digit) + i - 1) + '|';
				lower_thre = '1' + '0'.repeat(lower_digit + i + 1);
			}else{
				exM = exM + makeBrackets(lower_thre.charAt(0), upper_thre.charAt(0)) + '[0-9]' + makeBraces(lower_digit + i - 1) + '|';
			}
		}　
	}
//	window.console.log('下位:'+exL);
//	window.console.log('中位:'+exM);
//	window.console.log('上位:'+exU);

	var ex = exL+exM+exU;
	if(ex.charAt(ex.length - 1) == '|') ex = ex.substr(0, ex.length - 1);
	//ex = '(' + ex + '(.[0-9]+)?)|' + String(end_value);
	if(isMinus) ex = '-(' + ex + ')';
	return ex;
	//window.console.log(ex);
}

//数値範囲の正規表現を生成
//実数もマッチ
function makeNumberRangeRegexp2(start, end){
	if(start === '' && end === ''){//どちらも空の場合、終了
		return '';
	}else if(start === '' || end === ''){//どちらかの値が空の場合、同じ値を入れる
		if(start === '') start = end;
		if(end === '') end = start;
	}
	
	var start_value = parseInt(start);
	var end_value = parseInt(end);

	var isMinus = false;
	
	if( start_value < 0 && end_value < 0){//どちらもマイナス値の場合
		isMinus = true;
		start_value = -start_value;
		end_value = -end_value;
	}

	if(start_value == end_value){//start = end の場合
		return String(start_value);
	}else if(start_value > end_value){//start > end の場合、値を入れ替える
		var temp = start_value;
		start_value = end_value;
		end_value = temp;
	}

	if(end_value - start_value == 1){//差が１の場合
		return '(' + String(start_value) + '(.[0-9]+)?)|' + String(end_value);
	}
	
	if(start_value < 0 && end_value >= 0){//startのみマイナス値の場合
		return makeNumberRangeRegexp(String(start_value), '-1') + '|'+ makeNumberRangeRegexp('0', String(end_value));
	}
	
	var end_value2 = end_value - 1;//小数点以下の数字にもマッチングさせるため-1
	var start_str = String(start_value);
	var start_digit = start_str.length;//startの桁数
	var end_str = String(end_value2);
	var end_digit = end_str.length;//endの桁数
	
	if(start_digit == end_digit){//start,endの桁数が同じ場合
		var diff_digit = 0;
		for(i = 0; i < start_digit; i++){
			if(start_str.charAt(i) !== end_str.charAt(i)){
				diff_digit = start_digit - i;
				break;
			}
		}
		if(diff_digit == 1){//start,endの違いが1桁目だけの場合
			var ex = '';
			if(start_digit > 1){
				ex = start_str.substr(0, start_digit - 1);
			}
			ex = '(' + ex + makeBrackets(start_str.charAt(start_digit - 1),end_str.charAt(start_digit - 1)) + '(.[0-9]+)?)|' + String(end_value);
			return ex;
		}
	}

	var lower_thre;//下位領域のしきい値
	var upper_thre;//上位領域のしきい値

	var exL = ""; //下位領域
	if(start_str.match(/^[1-9]0+$/)){//startがx000...の場合
		lower_thre = start_str;
	}else if(start_str.match(/^[1-9]9+$/)){//startがx999...の場合
		exL = start_str + '|';
		lower_thre = String(parseInt(start_str) + 1);
	}else{
		if(start_digit == 1){
			exL = makeBrackets(start_str,9) + '|'; //startが１桁の場合
			lower_thre = String('10');
		}else{
			for(var i = 1; i < start_digit; i++){
				if(i == 1){
					exL = exL + start_str.substr(0, start_digit - i) + makeBrackets(parseInt(start_str.charAt(start_digit - i)),9)  + '|';
				}else if(parseInt(start_str.charAt(start_digit - i)) != 9){
					if(parseInt(start_str.substr(0, start_digit - i) + '9'.repeat(i)) <= end_value2){
						exL = exL + start_str.substr(0, start_digit - i) + makeBrackets(parseInt(start_str.charAt(start_digit - i)) + 1,9) ;
						if(i-1 > 0){
							exL = exL + '[0-9]' + makeBraces(i-1) ;
						}
						exL = exL + '|';
					}
				}
			}
			lower_thre = String(parseInt(start_str.charAt(0)) + 1) + '0'.repeat(start_digit - 1);
		}
	}
//	window.console.log('lower_thre:' + lower_thre);

	var exU = ''; //上位領域
	if(end_str.match(/^[1-9]9+$/)){
		upper_thre = end_str;
	}else if(end_str.match(/^[1-9]0+$/)){
		exU = end_str;
		upper_thre = String(parseInt(end_str) - 1);
	}else{
		for(var i = 1; i < end_digit - 1; i++){
			if(parseInt(end_str.charAt(i)) >= 1){
				if(parseInt(end_str.substr(0, i) + String(parseInt(end_str.charAt(i)) - 1) + '9'.repeat(end_digit - i -1)) <= end_value2 &&
				   parseInt(end_str.substr(0, i) + String(parseInt(end_str.charAt(i)) - 1) + '0'.repeat(end_digit - i -1)) >= start_value  ){
					exU = exU + end_str.substr(0, i) + makeBrackets(0, parseInt(end_str.charAt(i)) - 1) + '[0-9]' + makeBraces(end_digit - i -1) + '|';
				}
			}
		}
		exU = exU + end_str.substr(0, end_digit - 1) + makeBrackets(0, end_str.charAt(end_digit - 1));
		upper_thre = String(parseInt(String(parseInt(end_str.charAt(0)) - 1) + '9'.repeat(end_digit - 1)));
	}
//	window.console.log('upper_thre:' + upper_thre);

	var exM = ""; //中位領域

	if(lower_thre < upper_thre){
		var lower_digit = lower_thre.length;
		var upper_digit = upper_thre.length;
		
		for(var i = 0; i <= upper_digit - lower_digit; i++){
			if(lower_digit + i < upper_digit){
				exM = exM + makeBrackets(lower_thre.charAt(0), 9) + '[0-9]' + makeBraces(parseInt(lower_digit) + i - 1) + '|';
				lower_thre = '1' + '0'.repeat(lower_digit + i + 1);
			}else{
				exM = exM + makeBrackets(lower_thre.charAt(0), upper_thre.charAt(0)) + '[0-9]' + makeBraces(lower_digit + i - 1) + '|';
			}
		}　
	}
//	window.console.log('下位:'+exL);
//	window.console.log('中位:'+exM);
//	window.console.log('上位:'+exU);

	var ex = exL+exM+exU;
	if(ex.charAt(ex.length - 1) == '|') ex = ex.substr(0, ex.length - 1);
	ex = '(' + ex + '(.[0-9]+)?)|' + String(end_value);
	if(isMinus) ex = '-(' + ex + ')';
	return ex;
	//window.console.log(ex);
}

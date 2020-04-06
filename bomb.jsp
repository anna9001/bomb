<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>지뢰찾기</title>
<style>
	table{
		border-collapse:collapse;
	}
	td{
		border:1px solid black;
		width: 20px;
		height: 20px;
		background : #444;
	}
	td.opened{
		background: white;
	}
</style>

</head>
<body>
<input id="hor" type="number" placeholder="가로" value="10"/>
<input id="ver" type="number" placeholder="세로" value="10"/>
<input id="mine" type="number" placeholder="지뢰" value="20"/>
<button id="exec">실행</button>
<table id="table">
	<thead>	
		<tr>
			<td><span id="timer">0</span></td>
		</tr>
	</thead>
	<tbody></tbody>
	<div id="result"></div>
</table>

<script type="text/javascript">
var tbody = document.querySelector('#table tbody');
var dataset= [];
var gameFlag = false;
var openedCol =0;

document.querySelector('#exec').addEventListener('click',function(){
	
	document.querySelector('#result').textContent = "";
	tbody.innerHTML ='';
	dataset=[];
	gameFlag = false;
	openedCol =0;
	
	var hor = parseInt(document.querySelector('#hor').value);
	var ver = parseInt(document.querySelector('#ver').value);
	var mine = parseInt(document.querySelector('#mine').value);

	var sub = Array(hor*ver)
	.fill()
	.map(function(ele,idx){
		return idx; //0~99 .. 1~100으로 하면 아래 지뢰심기에서 -1 나옴
	});

	var shuffle =[];
	
	//지뢰 번호 선택
	while(sub.length>80){ //20개만 뽑으려고 
		var move = sub.splice(Math.floor(Math.random()*sub.length),1)[0];//[0]하면 배열이 아닌 값만 반환
		shuffle.push(move);
	}
	//console.log(shuffle);
	
	//지뢰테이블만들기	
	for(var i=0;i<ver;i+=1){
		var arr=[];
		var tr = document.createElement('tr');
		dataset.push(arr);
		for(var j=0;j<hor;j+=1){
			arr.push(0);
			var td=document.createElement('td');
			
			td.addEventListener('contextmenu',function(e){
				e.preventDefault();
				
				if(gameFlag){
					return;
				}
				
				var parentTr = e.currentTarget.parentNode; //e.target or currentTarget
				var parentTbody = e.currentTarget.parentNode.parentNode;
				var col =  Array.prototype.indexOf.call(parentTr.children,e.currentTarget);//parentTr.children.indexOf(td) 안돼서 .
																								//.td 로 쓰면 클로저문제로 td 잘 못찾아 e.currentTarget으로 바꿈
				var row = Array.prototype.indexOf.call(parentTbody.children,parentTr);
				//console.log(parentTr,parentTbody,e.currentTarget,square,line)
				if(e.currentTarget.textContent===''||e.currentTarget.textContent==='x'){
					e.currentTarget.textContent='!';	
				}
				else if(e.currentTarget.textContent==='!'){
					e.currentTarget.textContent='?';			
				}
				else if(e.currentTarget.textContent==='?'){
					if(dataset[row][col]===0){
						e.currentTarget.textContent='';
					}else if(dataset[row][col]==='x'){
						e.currentTarget.textContent='x';
					}				
				}
			}); 
			td.addEventListener('click',function(e){
				
				if(gameFlag){
					return;
				}
				//클릭 시 주변 지뢰 갯수
				var parentTr = e.currentTarget.parentNode; //e.target or currentTarget
				var parentTbody = e.currentTarget.parentNode.parentNode;
				var col=  Array.prototype.indexOf.call(parentTr.children,e.currentTarget); //칸 
				var row = Array.prototype.indexOf.call(parentTbody.children,parentTr); //줄
				
				if(dataset[row][col]===1){//열린 칸은 또 눌리지 않게..승리 열린 칸 카운트 시 필요 
					return;
				} 
				
				
				//classList 로 태그의 클래스에 접근  add,remove
				e.currentTarget.classList.add('opened'); //$(this).addClass('opened');		
				openedCol += 1;
				if(dataset[row][col]==='x'){					
					e.currentTarget.textContent = '펑';		
					document.querySelector('#result').textContent = "실패! ";
					gameFlag=true;
				}else{ //주변 개수 세기
					
					var around=[		
						dataset[row][col-1],dataset[row][col+1],			
					];
				if(dataset[row-1]){
					around=around.concat(dataset[row-1][col-1],dataset[row-1][col],dataset[row-1][col+1])
				}
				if(dataset[row+1]){
					around=around.concat(dataset[row+1][col-1],dataset[row+1][col],dataset[row+1][col+1]	)
				}
				//console.log(around);
				var noOfbomb = 	around.filter(function(v){ //배열 요소가 x인 것 찾기
					return v==='x';
				}).length;
					
				//거짓 값 : false,'',0,null,NaN,undefined 가 noOfbomb 에 오면  ''를 넣음 
				e.currentTarget.textContent = noOfbomb || ''; 
				dataset[row][col] =1; //열렸던 곳이 다시 열리는 작업 안하도록 (성능개선)
	
				if(noOfbomb===0){ //0 인 함수 주변 열어주기 재귀로
					var cols=[]; //주변칸 
					if(tbody.children[row-1]){
						cols=cols.concat([
						tbody.children[row-1].children[col-1],
						tbody.children[row-1].children[col],
						tbody.children[row-1].children[col+1],
						]);
					}
						
					cols=cols.concat([
						tbody.children[row].children[col-1],
						tbody.children[row].children[col+1],
					]);	
						
					if(tbody.children[row+1]){
						cols=cols.concat([
						tbody.children[row+1].children[col-1],
						tbody.children[row+1].children[col],
						tbody.children[row+1].children[col+1],
						]);
					}
											
					//cols.filter((v) =>!!v).forEach(function(col){
					cols.filter(function(v){ // undefined, null, 0   제거
						return !!v;
						}).forEach(function(col){								
							var parentTr = col.parentNode; //e.target or currentTarget
							var parentTbody =col.parentNode.parentNode;
							var 옆옆칸=  Array.prototype.indexOf.call(parentTr.children,col); //칸 
							var 옆칸줄 = Array.prototype.indexOf.call(parentTbody.children,parentTr); //줄
							
							if(dataset[옆칸줄][옆옆칸]!=1){	
								col.click();
							}						
						});
								
					}//if(noOfbomb===0){
				}//else 주변 개수 세기
			
				if(openedCol===(hor*ver-mine)){
					gameFlag=true;
					document.querySelector('#result').textContent ="승리!!";
				}
			}); //eventListener
			tr.appendChild(td);			
		} 
		tbody.appendChild(tr);
	}//for 문
	
	
	//지뢰심기
	for(var k=0;k<shuffle.length;k++){  //지뢰 번호 59 6번째 줄 8번째 칸
		var height = Math.floor(shuffle[k]/10); 
		var width = shuffle[k] % 10; 
		//console.log(height,width);
		tbody.children[height].children[width].textContent='x';		
		dataset[height][width]='x';
	}
});
/*   여기 만들면 td 만들어지기 전에 실행돼서 이벤트 안걸림. 위에서 td 생성 즉시 이벤트 걸어야
 tbody.querySelectorAll('td').forEach(function(td){
	 td.addEventListener('contextmenu',function(){
 		console.log();
	 
	 });
	 
 }); */

</script>
</body>
</html>
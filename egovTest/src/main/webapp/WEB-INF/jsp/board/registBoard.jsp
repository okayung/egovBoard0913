<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<script src="https://code.jquery.com/jquery-3.7.1.js"
	integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4="
	crossorigin="anonymous"></script>
<title>게시물 등록</title>
<style>
	table{
		margin:auto;
		width:100%;
		height:auto;
	}
	tr {
		height:30px;
	}
	.text {
	 width:100%;
	}
</style>
<script type="text/javascript">
/* 파일 업로드 관련 변수 */
var fileCnt = 0;  //파일 개수
var totalCnt = 20;  //파일을 업로드할 수있는 최대개수
var fileNum = 0;
var content_files = new Array();  //업로드할(선택한) 파일들
var deleteFiles = new Array();
/* 파일 업로드 관련 변수 */

	$(document).ready(function(){
		var flag = "${flag}";
		if(flag === "U"){  //flag 값이 U 일때 실행
			fn_detail("${boardIdx}");  //model 넣었던 값을 가지고 올수있음
		}
		
		
		$("#btn_save").on('click', function(){
			fn_save();
		});
		
		$("#btn_list").on('click', function(){
			location.href="/board/boardList.do";
		});
		
		$("#uploadFile").on("change", function(e){ // e안에 업로드 파일이 들어가있다고생각
			var files = e.target.files;
			// 파일 배열 담기
			var filesArr = Array.prototype.slice.call(files);
			//파일 개수 확인 및 제한
			if(fileCnt + filesArr.length > totalCnt){
				alert("파일은 최대 "+totCnt+"개까지 업로드 할 수 있습니다.");
				return;
			}else{
				fileCnt = fileCnt+ filesArr.length;
			}
			
			// 각각의 파일 배열 담기 및 기타
			filesArr.forEach(function (f){  // FileReader -> 파일을 읽어서 데이터화시키는 
				var reader = new FileReader();
				reader.onload = function (e){
					content_files.push(f); //실제 파일  정보 넣어주기
					$("#boardFileList").append( //boardFileList -> 선택된 파일보여주기// append-> 기존내용에 새로운 내용 붙여쓰기
								'<div id="file'+fileNum+'" style="float:left;">'
								+'<font style="font-size:12px">' + f.name + '</font>'
								+'<a href="javascript:fileDelete(\'file'+fileNum+'\',\'\')">X</a>'  //파일을 지울때 파일+파일넘으로 확인하고 삭제
								+'</div>'
					);
					fileNum++;
				};
				reader.readAsDataURL(f);
			});
			//초기화한다.
			$("#uploadFile").val("");
		});
	});
	
	function fileDelete(fileNum, fileIdx){  // 파일삭제
		var no = fileNum.replace(/[^0-9]/g, ""); //공백제거 숫자로 바꿔주는 정규식, 숫자만

		if(fileIdx != ""){
			deleteFiles.push(fileIdx);
		}else{
			content_files[no].is_delete = true;	 // 파일삭제여부확인
		}
		$("#"+fileNum).remove(); // j쿼리로 선택한 파일을 삭제
		fileCnt--; // 파일개수 줄여주는 (삭제된만큼)
	}
	
	function fn_detail(boardIdx){
		$.ajax({
		    url: '/board/getBoardDetail.do',
		    method: 'post',
		    data : { "boardIdx" : boardIdx}, // {'파라미터명칭' : 실제데이터}
		    dataType : 'json',
		    success: function (data, status, xhr) {
				$("#boardTitle").val(data.boardInfo.boardTitle);
				$("#boardContent").val(data.boardInfo.boardContent);
				fn_filelist(data.boardInfo.fileGroupIdx);
		    },
		    error: function (data, status, err) {
		    	console.log(err);
		    }
		});
	}
	
	function fn_filelist(fileGroupIdx){
		$.ajax({
		    url: '/board/getFileList.do',
		    method: 'post',
		    data : { "fileGroupIdx" : fileGroupIdx},
		    dataType : 'json',
		    success: function (data, status, xhr) {
				if(data.fileList.length > 0){
					for(var i=0; i<data.fileList.length; i++){
						$("#boardFileList").append(
								'<div id="file'+i+'" style="float:left;">'
								+'<font style="font-size:12px">' + data.fileList[i].fileOriginalName + '</font>'
								+'<a href="javascript:fileDelete(\'file'+i+'\',\''+data.fileList[i].fileIdx+'\');">X</a>'
								+'</div>'
						);
					}
					fileNum = data.fileList.length;
				}
		    },
		    error: function (data, status, err) {
		    	console.log(err);
		    }
		});
	}
	
	function fn_save(){
		// var frm = $("#saveFrm").serialize();
		var formData = new FormData($("#saveFrm")[0]); // formData -> 파일업로드에서는 사용, ($("#saveFrm")[0]-> 정보까지 
		
		for(var x=0; x<content_files.length; x++){
			//삭제 안한 것만 담아준다.
			if(!content_files[x].is_delete){
				formData.append("fileList", content_files[x]); 
			}
		}
		if(deleteFiles.length >0){
			formData.append("deleteFiles", deleteFiles);	
		}
		
		$.ajax({
		    url: '/board/saveBoard.do',
		    method: 'post',
		    data : formData,
		    enctype : "multipart/form-data", // 파일업로드 할때는 필수값
		    processData : false,  // 파일업로드 할때는 필수값
		    contentType : false, // 파일업로드 할때는 필수값, 동기식(true, 하던것이 끝이 나야 실행) or 비동기식(false 하던것이 끝이 나지 않아도 실행)
		    dataType : 'json',
		    success: function (data, status, xhr) {
		    	if(data.resultChk > 0){
		    		alert("저장되었습니다.");
		    		location.href="/board/boardList.do";
		    	}else{
		    		alert("저장에 실패하였습니다.");
		    	}
		    },
		    error: function (data, status, err) {
		    	console.log(err);
		    }
		});
	}
</script>
</head>
<body>
	<div>
		<form id="saveFrm" name="saveFrm">
			<input type="hidden" id="statusFlag" name="statusFlag" value="${flag}"/>
			<input type="hidden" id="boardIdx" name="boardIdx" value="${boardIdx}"/>
			<table>
				<tr>
					<th>제목</th>
					<td>
						<input type="text" class="text" id="boardTitle" name="boardTitle"/>
					</td>
				</tr>
				<tr>
					<th>내용</th>
					<td>
						<textarea rows="20" cols="60" id="boardContent" name="boardContent" class="text"></textarea>
					</td>
				</tr>
				<tr>
					<th>첨부파일</th>
					<td>
						<input type="file" class="text" id="uploadFile" name="uploadFile" multiple/>
						<div id="boardFileList"></div>
					</td>
				</tr>
			</table>
		</form>
	</div>
	<div style="float:right;">
		<input type="button" id="btn_save" name="btn_save" value="저장"/>
		<input type="button" id="btn_list" name="btn_list" value="목록"/>
	</div>
</body>
</html>
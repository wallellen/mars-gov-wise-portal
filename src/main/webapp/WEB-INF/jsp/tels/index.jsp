<%@ include file="include.jsp"%>

<!-- $Id$ -->

<!DOCTYPE html>
<html>
<head>

<META http-equiv="Content-Type" content="text/html; charset=UTF-8">

<!-- Always force latest IE rendering engine (even in intranet) & Chrome Frame
	Remove this if you use the .htaccess -->
<meta http-equiv="X-UA-Compatible" content="chrome=1"/>

<link href="<spring:theme code="globalstyles"/>" rel="stylesheet" type="text/css" />
<link href="<spring:theme code="homepagestylesheet"/>" rel="stylesheet" type="text/css" />
<link href="<spring:theme code="jqueryjscrollpane.css"/>" rel="stylesheet" type="text/css" />
<link href="<spring:theme code="jquerystylesheet"/>" rel="stylesheet" type="text/css" />
<link href="<spring:theme code="nivoslider.css"/>" rel="stylesheet" type="text/css" />
<link href="<spring:theme code="nivoslider-wise.css"/>" rel="stylesheet" type="text/css" />
<link href="<spring:theme code="tinycarousel.css"/>" rel="stylesheet" type="text/css" />

<link rel="shortcut icon" href="<spring:theme code="favicon"/>" />

<title><spring:message code="wiseTitle" /></title>

<!--NOTE: the following scripts has CONDITIONAL items that only apply to IE (MattFish)-->
<!--[if lt IE 7]>
<script defer type="text/javascript" src="./javascript/tels/iefixes.js"></script>
<![endif]-->

<!--[if lt IE 8]>
<link href="<spring:theme code="ie7homestyles"/>" rel="stylesheet" type="text/css" />
<![endif]-->

</head>

<body>

<div id="pageWrapper">
	<%@ include file="headermain.jsp"%>
	<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
	<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c-rt" %>
	
	<div id="page">
		
		<div id="pageContent">
		

		</div>
	</div>
	<%@ include file="footer.jsp"%>
</div>
<div id="projectDetailDialog" style="overflow:hidden;" class="dialog"></div>

<script src="<spring:theme code="jquerysource"/>" type="text/javascript"></script>
<script src="<spring:theme code="jqueryuisource"/>" type="text/javascript"></script>
<script src="<spring:theme code="jquerymousewheel.js"/>" type="text/javascript"></script>
<!-- <script src="<spring:theme code="mwheelintent.js"/>" type="text/javascript"></script>  -->
<script src="<spring:theme code="jqueryjscrollpane.js"/>" type="text/javascript"></script>
<script src="<spring:theme code="nivoslider.js"/>" type="text/javascript"></script>
<script src="<spring:theme code="easyaccordion.js"/>" type="text/javascript"></script>
<script src="<spring:theme code="tinycarousel.js"/>" type="text/javascript"></script>
<script src="<spring:theme code="generalsource"/>" type="text/javascript"></script>

<script type="text/javascript">
	$(document).ready(function(){
		
		//focus cursor into the First Name field on page ready 
		if($('#j_username').length){
			$('#j_username').focus();
		}
		
		$('#newsContent').jScrollPane();
		
		$('.tinycarousel').tinycarousel({ axis: 'y', pager: true, duration:500 });
		
		loadProjectThumbnails();
		
		// Set up view project details click action for each project id link
		$('a.projectDetail').on('click',function(){
			var title = $(this).attr('title');
			var projectId = $(this).attr('id').replace('projectDetail_','');
			var path = "/webapp/teacher/projects/projectinfo.html?projectId=" + projectId;
			var div = $('#projectDetailDialog').html('<iframe id="projectIfrm" width="100%" height="100%"></iframe>');
			div.dialog({
				width: '800',
				height: '400',
				title: title,
				position: 'center',
				modal:true,
				close: function(){ $(this).html(''); },
				buttons: {
					Close: function(){
						$(this).dialog('close');
					}
				}
			});
			$("#projectDetailDialog > #projectIfrm").attr('src',path);
		});
	});
	
	$(window).load(function() {
		
		// initiate showcase slider
		$('#showcaseSlider').nivoSlider({
			effect:'sliceDownRight',
			animSpeed:500,
			pauseTime:10000,
			prevText: '>',
	        nextText: '<',
	        directionNav: false,
	        beforeChange: function(){
	        	$('#about .panelHead span').fadeOut('slow');
	        },
	        afterChange: function(){
	        	var active = $('#showcaseSlider').data('nivo:vars').currentSlide;
	        	$('#about .panelHead span').text($('#showcaseSlider > img').eq(active).attr('alt'));
	        	$('#about .panelHead span').fadeIn('fast');
	        }
		});
		
		// set random opening slide for project showcase
		var numSlides = $('#projectShowcase dt').length;
		var start = Math.floor(Math.random()*numSlides);
		$('#projectShowcase dt').eq(start).addClass('activea');
		
		// initiate project showcase accordion
		$('#project-showcase').easyAccordion({ 
		   autoStart: false,
		   slideNum: false	
		});
	});
	
	// load thumbnails for each project by looking for curriculum_folder/assets/project_thumb.png (makes a ajax GET request)
	// If found (returns 200 status), it will replace the default image with the fetched image.
	// If not found (returns 400 status), it will do nothing, and the default image will be used.
	function loadProjectThumbnails() {		
		$(".projectThumb").each(
			function() {
				var thumbUrl = $(this).attr("thumbUrl");
				// check if thumbUrl exists
				$.ajax({
					url:thumbUrl,
					context:this,
					statusCode: {
						200:function() {
				  		    // found, use it
							$(this).html("<img src='"+$(this).attr("thumbUrl")+"' alt='thumb'></img>");
						},
						404:function() {
						    // not found, leave alone
							//$(this).html("<img src='/webapp/themes/tels/default/images/projectThumb.png' alt='thumb'></img>");
						}
					}
				});
			});
	};
</script>

</body>

</html>


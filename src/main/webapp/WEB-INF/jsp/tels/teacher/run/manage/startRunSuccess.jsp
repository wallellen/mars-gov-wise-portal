<%@ include file="../include.jsp"%>

<!-- $Id$ -->

<!DOCTYPE html>
<html xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />

<link href="<spring:theme code="globalstyles"/>" media="screen" rel="stylesheet"  type="text/css" />
<link href="<spring:theme code="stylesheet"/>" media="screen" rel="stylesheet"  type="text/css" />

<title><spring:message code="teacher.run.manage.startRunSuccess.successReactivatingArchivedRun"/></title>

<script type='text/javascript'>
var refreshRequired = true;
</script>

</head>

<body style="background:#FFF;">

	<div class="dialogContent">
		<div class="dialogSection">
			<div class="errorMsgNoBg">
				<p><spring:message code="teacher.run.manage.startRunSuccess.runSuccessfullyRestored"/></p>
				<p><spring:message code="teacher.run.manage.startRunSuccess.gradingAndSavingStudentWorkEnabled"/></p>
			</div>
		</div>
	</div>

</body>
</html>

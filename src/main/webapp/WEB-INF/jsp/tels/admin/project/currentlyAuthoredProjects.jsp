<%@ include file="../../include.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "XHTML1-s.dtd" />
<html xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />

<link href="<spring:theme code="globalstyles"/>" media="screen" rel="stylesheet"  type="text/css" />
<link href="<spring:theme code="stylesheet"/>" media="screen" rel="stylesheet" type="text/css" />
<link href="<spring:theme code="teacherprojectstylesheet" />" media="screen" rel="stylesheet" type="text/css" />
<link href="<spring:theme code="teacherhomepagestylesheet" />" media="screen" rel="stylesheet" type="text/css" />
    
<title><spring:message code="application.title" /></title>

<meta http-equiv="content-type" content="text/html; charset=utf-8"/>

</head>
<body>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div id="page">
<div id="pageContent" class="contentPanel">

<%@ include file="../adminheader.jsp"%>

<h5 style="color:#0000CC;"><a href="../index.html">Return to Main Menu</a></h5>

	<c:choose>
		<c:when test="${fn:length(openedProjectIds) > 0}">
			<table>
				<tr>
					<th>Project Id</th>
					<th>Project Name</th>
					<th>Authors</th>
				</tr>
				<c:forEach var="openedProjectId" items="${openedProjectIds}">
					<tr>
						<td><c:out value="${openedProjectId}" /></td>
						<td><c:out value="${openedProjects[openedProjectId].name}" /></td>
						<td><c:forEach var="sessionOpeningThisProject"
								items="${openedProjectsToSessions[openedProjectId]}">
								<c:set var="username"
									value="${loggedInTeachers[sessionOpeningThisProject].userDetails.username}"></c:set>
								<c:out value="${username}" /> | 
							<a href="../../j_acegi_switch_user?j_username=${username}">Log
									in as this user</a> |
							<a href="#"
									onclick="javascript:popup640('../../teacherinfo.html?userName=${username}');">info</a>
								<br />
							</c:forEach></td>
					</tr>
				</c:forEach>
			</table>

		</c:when>
		<c:otherwise>
			<c:out value="Nobody is authoring at this time." />
		</c:otherwise>
	</c:choose>
</div></div>

</body>
</html>
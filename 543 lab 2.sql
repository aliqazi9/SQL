/*
1) Write the SQL query to determine the departments that held fewer than 230 classes in buildings on Stevens Way
between 2011 and 2016 that also generated more than $16.5 million from registration fees in the 1990's that also
had more than 400 distinct (!!) students complete a 400-level course in the 1980's
*/
 
SELECT tblDEPARTMENT.DeptName
FROM tblDEPARTMENT
JOIN tblCOURSE ON tblCOURSE.DeptID = tblDEPARTMENT.DeptID
JOIN tblCLASS ON tblCLASS.CourseID = tblCOURSE.CourseID
JOIN tblCLASSROOM ON tblCLASS.ClassroomID = tblCLASSROOM.ClassroomID
JOIN tblBUILDING ON tblBUILDING.BuildingID = tblCLASSROOM.BuildingID
JOIN tblLOCATION ON tblBUILDING.LocationID = tblLOCATION.LocationID
WHERE LocationName = 'Stevens Way' AND tblCLASS.YEAR BETWEEN 2011 AND 2016
 
AND tblDEPARTMENT.DeptID IN (
   SELECT tblDEPARTMENT.DeptID
   FROM tblDEPARTMENT
   JOIN tblCOURSE ON tblCOURSE.DeptID = tblDEPARTMENT.DeptID
   JOIN tblCLASS ON tblCLASS.CourseID = tblCOURSE.CourseID
   JOIN tblCLASS_LIST ON tblCLASS_LIST.ClassID = tblCLASS.ClassID
   WHERE tblCLASS.YEAR LIKE '199%'
   GROUP BY tblDEPARTMENT.DeptID
   HAVING SUM(RegistrationFee) > 16500000
)
 
AND tblDEPARTMENT.DeptID IN (
   SELECT tblDEPARTMENT.DeptID
   FROM tblDEPARTMENT
   JOIN tblCOURSE ON tblDEPARTMENT.DeptID = tblCOURSE.DeptID
   JOIN tblCLASS ON tblCLASS.CourseID = tblCOURSE.CourseID
   JOIN tblCLASS_LIST ON tblCLASS.ClassID = tblCLASS_LIST.ClassID
   WHERE tblCOURSE.CourseNumber BETWEEN 400 AND 499 AND tblCLASS.YEAR LIKE '198%'
   GROUP BY tblDEPARTMENT.DeptID
   HAVING COUNT(DISTINCT tblCLASS_LIST.StudentID) > 400
)
 
GROUP BY tblDEPARTMENT.DeptName
HAVING COUNT(ClassID) < 230
 
 
/*
2) Which students with the special need of 'Anxiety' have completed more than 13 credits of 300-level
Information School classes with a grade less than 3.1 in the last 3 years?
*/
SELECT tblSTUDENT.StudentID,tblSTUDENT.StudentFname, tblSTUDENT.StudentLname
FROM tblSTUDENT JOIN tblSTUDENT_SPECIAL_NEED ON tblSTUDENT.StudentID = tblSTUDENT_SPECIAL_NEED.StudentID
JOIN tblSPECIAL_NEED ON tblSTUDENT_SPECIAL_NEED.SpecialNeedID = tblSPECIAL_NEED.SpecialNeedID
JOIN tblCLASS_LIST ON tblSTUDENT.StudentID = tblCLASS_LIST.StudentID
JOIN tblCLASS ON tblCLASS_LIST.ClassID = tblCLASS.ClassID
JOIN tblCOURSE ON tblCLASS.CourseID = tblCOURSE.CourseID
JOIN tblDEPARTMENT ON tblCOURSE.DeptID = tblDEPARTMENT.DeptID
JOIN tblCOLLEGE ON tblDEPARTMENT.CollegeID = tblCOLLEGE.CollegeID
WHERE SpecialNeedName = 'Anxiety' AND Grade < 3.1 AND CAST(tblCLASS.YEAR AS int) > (YEAR(GETDATE()) - 3) AND CourseNumber BETWEEN 300 AND 399 AND CollegeName = 'Information School'
GROUP BY tblSTUDENT.StudentID, tblSTUDENT.StudentFname, tblSTUDENT.StudentLname
HAVING SUM(CREDITS) > 13
 
 
 
 
/*
3) Write the SQL to determine the top 10 states by number of students who have completed both 15 credits of Arts and Science courses
as well as between 5 and 18 credits of Medicine since 2003.
*/
 
SELECT TOP 10 tblSTUDENT.StudentPermState, COUNT(tblSTUDENT.StudentID) AS NumberOfStudents
FROM tblSTUDENT
WHERE tblSTUDENT.StudentID IN (
   SELECT tblSTUDENT.StudentID
   FROM tblSTUDENT  JOIN tblCLASS_LIST ON tblCLASS_LIST.StudentID = tblSTUDENT.StudentID
   JOIN TBLCLASS ON tblCLASS.ClassID = tblCLASS_LIST.ClassID
   JOIN tblCOURSE ON tblCLASS.CourseID = tblCOURSE.CourseID
   JOIN tblDEPARTMENT ON tblDEPARTMENT.DeptID = tblCOURSE.DeptID
   WHERE DeptName = 'Art' AND tblCLASS.YEAR >= 2003
   GROUP BY tblSTUDENT.StudentID
   HAVING SUM(CREDITS) = 15
)
AND tblSTUDENT.StudentID IN (
   SELECT tblSTUDENT.StudentID
   FROM tblSTUDENT JOIN tblCLASS_LIST ON tblCLASS_LIST.StudentID = tblSTUDENT.StudentID
   JOIN TBLCLASS ON tblCLASS.ClassID = tblCLASS_LIST.ClassID
   JOIN tblCOURSE ON tblCLASS.CourseID = tblCOURSE.CourseID
   JOIN tblDEPARTMENT ON tblDEPARTMENT.DeptID = tblCOURSE.DeptID
   WHERE DeptName = 'Medicine' AND tblCLASS.YEAR >= 2003
   GROUP BY tblSTUDENT.StudentID
   HAVING SUM(CREDITS) BETWEEN 5 and 18
)
GROUP BY tblSTUDENT.StudentPermState
ORDER BY COUNT(tblSTUDENT.StudentID) DESC
 
/*
4) Write the SQL to determine the students who are currently assigned a dormroom type 'Triple' on West Campus
who have paid more than $2,000 in registration fees in the past four years?
*/
 
SELECT tblSTUDENT.StudentID, StudentFname, StudentLname, SUM(RegistrationFee) AS Registration_Fee_IN_Last4years
FROM tblSTUDENT
JOIN tblCLASS_LIST ON tblCLASS_LIST.StudentID = tblSTUDENT.StudentID
JOIN tblCLASS ON tblCLASS.ClassID = tblCLASS_LIST.ClassID
JOIN tblCLASSROOM ON tblCLASSROOM.ClassroomID = tblCLASS.ClassroomID
JOIN tblBUILDING ON tblCLASSROOM.BuildingID = tblBUILDING.BuildingID
JOIN tblLOCATION ON tblLOCATION.LocationID = tblBUILDING.LocationID
WHERE tblSTUDENT.StudentID IN (SELECT tblSTUDENT.StudentID
   FROM tblSTUDENT
   JOIN tblSTUDENT_DORMROOM ON tblSTUDENT.StudentID = tblSTUDENT_DORMROOM.StudentID
   JOIN tblDORMROOM ON tblDORMROOM.DormRoomID = tblSTUDENT_DORMROOM.DormRoomID
   JOIN tblDORMROOM_TYPE ON tblDORMROOM_TYPE.DormRoomTypeID = tblDORMROOM.DormRoomID
   WHERE DormRoomTypeName = 'Triple'
)
AND LocationName = 'West Campus' AND tblCLASS.YEAR > YEAR(GETDATE()) - 4
GROUP BY tblSTUDENT.StudentID, StudentFname, StudentLname
HAVING SUM(RegistrationFee)>2000

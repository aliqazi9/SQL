/*
1) Write the SQL to determine the top three StudentPermStates with the highest average grade earned for 300-level course from
the college of 'Arts and Sciences' over the last 15 years?
*/
SELECT TOP 3 tblSTUDENT.StudentPermState, AVG(GRADE) AS AVG_GRADE
FROM tblSTUDENT  JOIN tblCLASS_LIST ON tblCLASS_LIST.StudentID = tblSTUDENT.StudentID
   JOIN tblCLASS ON tblCLASS.ClassID = tblCLASS_LIST.ClassID
   JOIN tblCOURSE ON tblCLASS.CourseID = tblCOURSE.CourseID
   JOIN tblDEPARTMENT ON tblDEPARTMENT.DeptID = tblCOURSE.DeptID
   JOIN tblCOLLEGE ON tblDEPARTMENT.CollegeID = tblCOLLEGE.CollegeID
WHERE CollegeName = 'Arts and Sciences' AND CAST(YEAR AS INT) > (YEAR(GETDATE()) - 15) AND CourseNumber BETWEEN 300 and 399
GROUP BY tblSTUDENT.StudentPermState
ORDER BY AVG(GRADE) DESC
 
/*
2) Write the SQL to determine which students have completed at least 15 credits of classes each from the colleges of Medicine,
Information School, and Arts and Sciences since 2009 that also completed more than 3 classes held in buildings on Stevens Way
in classrooms of type 'large lecture hall'.
*/
SELECT StudentFname, StudentLname
FROM tblSTUDENT WHERE StudentID IN (
   SELECT tblSTUDENT.StudentID
   FROM tblSTUDENT  JOIN tblCLASS_LIST ON tblCLASS_LIST.StudentID = tblSTUDENT.StudentID
       JOIN tblCLASS ON tblCLASS.ClassID = tblCLASS_LIST.ClassID
       JOIN tblCOURSE ON tblCLASS.CourseID = tblCOURSE.CourseID
       JOIN tblDEPARTMENT ON tblDEPARTMENT.DeptID = tblCOURSE.DeptID
       JOIN tblCOLLEGE ON tblDEPARTMENT.CollegeID = tblCOLLEGE.CollegeID
   WHERE CollegeName IN ('Medicine', 'Information School', 'Arts and Sciencesl') AND CAST(YEAR AS INT) >= 2009
   GROUP BY tblSTUDENT.StudentID, CollegeName
   HAVING SUM(CREDITS) >= 15
)
AND StudentID IN (
   SELECT tblSTUDENT.StudentID
   FROM tblSTUDENT  JOIN tblCLASS_LIST ON tblCLASS_LIST.StudentID = tblSTUDENT.StudentID
       JOIN tblCLASS ON tblCLASS.ClassID = tblCLASS_LIST.ClassID
       JOIN tblCLASSROOM ON tblCLASSROOM.ClassroomID = tblCLASS.ClassroomID
       JOIN tblCLASSROOM_TYPE ON tblCLASSROOM_TYPE.ClassroomTypeID = tblCLASSROOM.ClassroomTypeID
       JOIN tblBUILDING ON tblBUILDING.BuildingID = tblCLASSROOM.BuildingID
       JOIN tblLOCATION on tblLOCATION.LocationID = tblBUILDING.LocationID
   WHERE tblLOCATION.LocationName = 'Stevens Way' AND tblCLASSROOM_TYPE.ClassroomTypeName = 'Large Lecture Hall'
   GROUP BY tblSTUDENT.StudentID
   HAVING COUNT(tblCLASS.ClassID) > 3
)
 
/*
3) Write the SQL to determine the buildings that have held more than 100 classes from the Mathematics department since 1997
that have also held fewer than 80 classes from the Anthropology department since 2016.
*/
SELECT BuildingName
FROM tblBUILDING
WHERE BuildingID IN (
   SELECT tblBUILDING.BuildingID
   FROM tblBUILDING JOIN tblCLASSROOM ON tblCLASSROOM.BuildingID = tblBUILDING.BuildingID
       JOIN tblCLASS ON TBLCLASS.ClassroomID = tblCLASSROOM.ClassroomID
       JOIN tblCLASS_LIST ON tblCLASS_LIST.ClassID = tblCLASS.ClassID
       JOIN tblCOURSE ON tblCOURSE.CourseID = tblCLASS.CourseID
       JOIN tblDEPARTMENT ON tblDEPARTMENT.DeptID = tblCOURSE.DeptID
   WHERE tblDEPARTMENT.DeptName = 'Mathematics' AND  CAST(YEAR AS INT) >= 1997
   GROUP BY tblBUILDING.BuildingID
   HAVING COUNT(tblCLASS.ClassID) > 100
)
AND BuildingID IN (
   SELECT tblBUILDING.BuildingID
   FROM tblBUILDING JOIN tblCLASSROOM ON tblCLASSROOM.BuildingID = tblBUILDING.BuildingID
       JOIN tblCLASS ON TBLCLASS.ClassroomID = tblCLASSROOM.ClassroomID
       JOIN tblCLASS_LIST ON tblCLASS_LIST.ClassID = tblCLASS.ClassID
       JOIN tblCOURSE ON tblCOURSE.CourseID = tblCLASS.CourseID
       JOIN tblDEPARTMENT ON tblDEPARTMENT.DeptID = tblCOURSE.DeptID
   WHERE tblDEPARTMENT.DeptName = 'Anthropology' AND  CAST(YEAR AS INT) >= 2016
   GROUP BY tblBUILDING.BuildingID
   HAVING COUNT(tblCLASS.ClassID) < 80
)
 
/*
4) Write the SQL to determine which location on campus has held the classes that generated the most combined money in registration fees for
the colleges of 'Engineering', 'Nursing', 'Pharmacy', and 'Public Affairs (Evans School)'.
*/
SELECT TOP 1 tblLOCATION.LocationName, SUM(RegistrationFee) AS Total_RegistrationFee
FROM tblLOCATION JOIN tblBUILDING ON tblBUILDING.LocationID = tblLOCATION.LocationID
   JOIN tblCLASSROOM ON tblCLASSROOM.BuildingID = tblBUILDING.BuildingID
   JOIN tblCLASS ON TBLCLASS.ClassroomID = tblCLASSROOM.ClassroomID
   JOIN tblCLASS_LIST ON tblCLASS_LIST.ClassID = tblCLASS.ClassID
   JOIN tblCOURSE ON tblCOURSE.CourseID = tblCLASS.CourseID
   JOIN tblDEPARTMENT ON tblDEPARTMENT.DeptID = tblCOURSE.DeptID
   JOIN tblCOLLEGE ON tblCOLLEGE.CollegeID = tblDEPARTMENT.CollegeID
WHERE CollegeName IN ('Engineering', 'Nursing', 'Pharmacy', 'Public Affairs (Evans School)')
GROUP BY LocationName
ORDER BY SUM(RegistrationFee) DESC

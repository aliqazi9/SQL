CREATE Type StateType As TABLE
(
StateID int NOT NULL,
StateName VARCHAR(20) NOT NULL,
PRIMARY KEY (StateID)
);
GO
 
Create PROCEDURE SPState 
@StateName StateType READONLY
As 
BEGIN 
    Insert into State
    Select * FROM @StateName
END
 
DECLARE @StateName StateType
Insert into @StateName VALUES (1, 'New York')
INSERT into @StateName VALUES (2, 'California')
INSERT into @StateName VALUES (3, 'Texas')
 
EXECUTE SPState @StateName 
Select * From State 
 
CREATE Type TeamColorType As Table
(
Team_ColorID int NOT NULL,
Color VARCHAR(10) NOT NULL,
PRIMARY KEY (Team_ColorID)
);
GO 
 
CREATE PROCEDURE SPTeamColor
@TeamColor TeamColorType READONLY
As 
BEGIN 
    Insert into Team_Color
    Select * FROM @TeamColor
END
 
DECLARE @TeamColor TeamColorType
Insert into @TeamColor VALUES (1, 'White')
INSERT into @TeamColor VALUES (2, 'Red')
INSERT into @TeamColor VALUES (3,'Blue')
 
EXECUTE SPTeamColor @TeamColor 
Select * From Team_Color
 
ALTER function fnStateName 
 
(
    @StateName as VARCHAR(Max)
)
RETURNS VARCHAR (Max)
As 
Begin
 
DECLARE @SpacePosition As Int 
DECLARE @Answer As VARCHAR (Max)
 
Set @SpacePosition = CHARINDEX(' ', @StateName)
 
If @SpacePosition = 0 
    SET @Answer = @StateName
Else 
    Set @Answer = LEFT(@StateName, @SpacePosition - 1)
Return @Answer
END 
 
This function tries to find the first name and puts that as its own column. 
 
Select *, Dbo.fnStateName(StateName)
From State 
 
ALTER Function fnOld_or_new 
(
    @age DATETIME
)
Returns Varchar (Max) AS 
 
Begin 
 
Declare @return_value VARCHAR (Max); 
    Set @return_value = 'Same'; 
    IF (DATENAME(yy,@age)< 1970) SET @return_value = 'Old'
    IF (DATENAME(yy,@age)> 2000) SET @return_value = 'Young'
RETURN @return_value
End 
 
Select *, Dbo.fnOld_or_new (TeamBirthDate)
FROM Team
 
This function determines which teams is older and which teams are younger. 
 
GO
Create VIEW [State First Name] As 
Select Dbo.fnStateName(StateName) As State
From State 
 
Select * 
From [State First Name]
 
Go 
Create VIEW [Old or Young] AS 
Select Dbo.fnOld_or_new (TeamBirthDate) AS AGE, TeamName 
From Team
 
Select * 
From [Old or Young]
 
Select *
From Team 
 
Select [Old or Young]
From Team 
Where 
 
Select a.Name, c.CityName
From Arena as a
join  City as c on c.CityID = a.CityID
WHERE a.Name like 'C%%%'
And c.CityName like 'L%%'
 
Select CityName, StateName 
From State as s
Join city as c on c.StateID = s.StateID 
Where StateName like '%e%'
And CityName like '%e%%'
 

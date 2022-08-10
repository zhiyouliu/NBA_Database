----Q1----
DROP PROCEDURE IF EXISTS list_avg_salary;
CREATE PROCEDURE list_avg_salary(IN year VARCHAR(4))

BEGIN
-- select the corresponding team, average salaries and sort by descending order
  SELECT team_abb,AVG(salary) avg_salary

  FROM R_IN_ABB
  WHERE season= year

  GROUP BY team_abb
  ORDER BY avg_salary DESC;
END;



----Q2----
-- create view to let PROCEDURE use less time
DROP VIEW IF EXISTS FORQ11;
CREATE VIEW FORQ11 AS
SELECT PLAYER_NAME, PTS, PLAYER_ID, GAME_ID
FROM PLAY_IN ;

-- create view to let PROCEDURE use less time
DROP VIEW IF EXISTS FORQ12;
CREATE VIEW FORQ12 AS
SELECT GAME_ID, DATE_FORMAT(GAME_DATE_EST,'%Y') season
FROM GAME;

-- create view to let PROCEDURE use less time
DROP VIEW IF EXISTS FORQ1;
CREATE VIEW FORQ1 AS
SELECT f11.PLAYER_NAME,f11.PTS, f11.PLAYER_ID, f11.GAME_ID, f12.season
FROM FORQ11 AS f11, FORQ12 AS f12
WHERE f11.GAME_ID = f12.GAME_ID;

 DELIMITER //
 DROP PROCEDURE playeraveragescore;
 CREATE PROCEDURE playeraveragescore(IN SEASON INTEGER(4))
 BEGIN

SELECT formax.PLAYER_NAME, formax.AVERAGE_SCORE
FROM
(SELECT forcount.PLAYER_NAME, (forcount.total/forcount.amount) AVERAGE_SCORE
From
(SELECT PLAYER_NAME, SUM(PTS) as total, COUNT(GAME_ID) as amount
FROM FORQ1 AS F
WHERE 
F.season >= SEASON AND
F.season < (SEASON+1)
GROUP BY F.PLAYER_ID) forcount) formax
WHERE formax.AVERAGE_SCORE = (
-- calculate the max average score each player get in the season
SELECT MAX(formax.AVERAGE_SCORE)
FROM
-- calculate the average score each player get in the season
(SELECT forcount.PLAYER_NAME, (forcount.total/forcount.amount) AVERAGE_SCORE
From
-- calculate the total score each player get in the season
(SELECT PLAYER_NAME, SUM(PTS) as total, COUNT(GAME_ID) as amount
FROM FORQ1 AS F
WHERE 
F.season >= SEASON AND
F.season < (SEASON+1)
GROUP BY F.PLAYER_ID) forcount) formax
);


END //

call playeraveragescore('2016');




----Q3----
DROP PROCEDURE IF EXISTS MOST_WIN_BEST_PLAYER;
CREATE PROCEDURE MOST_WIN_BEST_PLAYER(IN year VARCHAR(4))
BEGIN
-- win rate used for the max winning rate
  SELECT NICKNAME TEAM_NAME,RANKING.TEAM_ID, MAX(W/G) WIN_RATE
  FROM RANKING, (SELECT TEAM_ID,NICKNAME FROM TEAMS) TEAMSNAME
  where SEASON_ID = CONCAT('2',year) AND 
  G = 82 AND RANKING.TEAM_ID = TEAMSNAME.TEAM_ID;

  SELECT *
  FROM
  (
  SELECT PLAYER_NAME, GAME_ID,2*FGM+3*FG3M TOTAL_POINTS
  FROM PLAY_IN
  WHERE GAME_ID IN (select GAME_ID from GAME_DETAILS where SEASON=year)
  GROUP BY PLAYER_NAME,GAME_ID) RESULT
  WHERE TOTAL_POINTS = (
    SELECT MAX(TOTAL_POINTS) 
    FROM (
      SELECT PLAYER_NAME, GAME_ID,2*FGM+3*FG3M TOTAL_POINTS
      FROM PLAY_IN
      WHERE GAME_ID IN (select GAME_ID from GAME_DETAILS where SEASON=year)
      GROUP BY PLAYER_NAME,GAME_ID
      ) RESULT
      -- result is for finding the max total points
  );

END;




----Q4----
DELIMITER //
DROP PROCEDURE IF EXISTS highest_salary_position;
CREATE PROCEDURE highest_salary_position(IN SEASON1 VARCHAR(4), IN SEASON2 VARCHAR(4))
 BEGIN
SELECT formax2.position, formax2.average_salary
FROM
(SELECT forcount.position, (forcount.total/counts) average_salary
FROM
(SELECT PC.position, SUM(I.salary) total, COUNT(I.salary) counts
FROM PLAYER_CAREER as PC, IN_IN as I
WHERE I.season <= SEASON2 AND
I.season >= SEASON1 AND
I.player_name = PC.player_name
GROUP BY PC.position) forcount) formax2
WHERE formax2.average_salary = (
-- find the position having max average salary.
SELECT MAX(formax.average_salary)
FROM
-- calculate the average of salary of each position
(SELECT forcount.position, (forcount.total/counts) average_salary
FROM
-- calculate the sum of salary of each position
(SELECT PC.position, SUM(I.salary) total, COUNT(I.salary) counts
FROM PLAYER_CAREER as PC, IN_IN as I
WHERE I.season <= SEASON2 AND
I.season >= SEASON1 AND
I.player_name = PC.player_name
GROUP BY PC.position) forcount) formax);

END//




----Q5----
drop procedure IF EXISTS LOWEST_SALARY;
CREATE PROCEDURE LOWEST_SALARY(IN year VARCHAR(4))
BEGIN
-- select the lowest salary player
select player_name, salary
from R_IN_ABB 
where season = year and salary = (
  select MIN(salary)
  from R_IN_ABB 
  where season = year
);
END;

SELECT * FROM R_IN_ABB;

-- call LOWEST_SALARY('2012');




----Q6----
DELIMITER //
 DROP PROCEDURE IF EXISTS heightweightstats;
 CREATE PROCEDURE heightweightstats()
 BEGIN
-- calculate average of rebound separately of each interval of height
(SELECT '<200' HEIGHTS, AVG(foravg200.reboundavg) AVGREBOUND
FROM
(SELECT totalavg.PLAYER_NAME, totalavg.reboundavg
FROM
(SELECT foravg.PLAYER_NAME, AVG(DREB) reboundavg
FROM
(SELECT PLAYER_NAME, DREB
FROM PLAY_IN) foravg
WHERE foravg.PLAYER_NAME in 
(SELECT player_name
FROM PLAYER_CAREER PC
WHERE PC.POSITION in ('F-C','C-F','C'))
GROUP BY foravg.PLAYER_NAME) totalavg
WHERE totalavg.PLAYER_NAME in 
(SELECT DISTINCT PLAYER_NAME
FROM PLAYER_INFO_1 PI1
WHERE PI1.HEIGHTS < 200)) foravg200)

UNION

(SELECT '200-210' HEIGHTS, AVG(foravg210.reboundavg) AVGREBOUND
FROM
(SELECT totalavg.PLAYER_NAME, totalavg.reboundavg
FROM
(SELECT foravg.PLAYER_NAME, AVG(DREB) reboundavg
FROM
(SELECT PLAYER_NAME, DREB
FROM PLAY_IN) foravg
WHERE foravg.PLAYER_NAME in 
(SELECT player_name
FROM PLAYER_CAREER PC
WHERE PC.POSITION in ('F-C','C-F','C'))
GROUP BY foravg.PLAYER_NAME) totalavg
WHERE totalavg.PLAYER_NAME in 
(SELECT DISTINCT PLAYER_NAME
FROM PLAYER_INFO_1 PI1
WHERE PI1.HEIGHTS >= 200 AND
PI1.HEIGHTS <210)) foravg210)

UNION 

(SELECT '210-220' HEIGHTS, AVG(foravg220.reboundavg) AVGREBOUND
FROM
(SELECT totalavg.PLAYER_NAME, totalavg.reboundavg
FROM
(SELECT foravg.PLAYER_NAME, AVG(DREB) reboundavg
FROM
(SELECT PLAYER_NAME, DREB
FROM PLAY_IN) foravg
WHERE foravg.PLAYER_NAME in 
(SELECT player_name
FROM PLAYER_CAREER PC
WHERE PC.POSITION in ('F-C','C-F','C'))
GROUP BY foravg.PLAYER_NAME) totalavg
WHERE totalavg.PLAYER_NAME in 
(SELECT DISTINCT PLAYER_NAME
FROM PLAYER_INFO_1 PI1
WHERE PI1.HEIGHTS >= 210 AND
PI1.HEIGHTS <220)) foravg220)

UNION

(SELECT '220-230' HEIGHTS, AVG(foravg230.reboundavg) AVGREBOUND
FROM
(SELECT totalavg.PLAYER_NAME, totalavg.reboundavg
FROM
(SELECT foravg.PLAYER_NAME, AVG(DREB) reboundavg
FROM
(SELECT PLAYER_NAME, DREB
FROM PLAY_IN) foravg
WHERE foravg.PLAYER_NAME in 
(SELECT player_name
FROM PLAYER_CAREER PC
WHERE PC.POSITION in ('F-C','C-F','C'))
GROUP BY foravg.PLAYER_NAME) totalavg
WHERE totalavg.PLAYER_NAME in 
(SELECT DISTINCT PLAYER_NAME
FROM PLAYER_INFO_1 PI1
WHERE PI1.HEIGHTS >= 220 AND
PI1.HEIGHTS <230)) foravg230);

-- calculate average of rebound separately of each interval of weight
(SELECT '80-100' WEIGHTS, AVG(foravg200.reboundavg) AVGREBOUND
FROM
(SELECT totalavg.PLAYER_NAME, totalavg.reboundavg
FROM
(SELECT foravg.PLAYER_NAME, AVG(DREB) reboundavg
FROM
(SELECT PLAYER_NAME, DREB
FROM PLAY_IN) foravg
WHERE foravg.PLAYER_NAME in 
(SELECT player_name
FROM PLAYER_CAREER PC
WHERE PC.POSITION in ('F-C','C-F','C'))
GROUP BY foravg.PLAYER_NAME) totalavg
WHERE totalavg.PLAYER_NAME in 
(SELECT DISTINCT PLAYER_NAME
FROM PLAYER_INFO_1 PI1
WHERE PI1.WEIGHTS >= 80 AND
PI1.WEIGHTS < 100)) foravg200)

UNION

(SELECT '100-120' WEIGHTS, AVG(foravg200.reboundavg) AVGREBOUND
FROM
(SELECT totalavg.PLAYER_NAME, totalavg.reboundavg
FROM
(SELECT foravg.PLAYER_NAME, AVG(DREB) reboundavg
FROM
(SELECT PLAYER_NAME, DREB
FROM PLAY_IN) foravg
WHERE foravg.PLAYER_NAME in 
(SELECT player_name
FROM PLAYER_CAREER PC
WHERE PC.POSITION in ('F-C','C-F','C'))
GROUP BY foravg.PLAYER_NAME) totalavg
WHERE totalavg.PLAYER_NAME in 
(SELECT DISTINCT PLAYER_NAME
FROM PLAYER_INFO_1 PI1
WHERE PI1.WEIGHTS >= 100 AND
PI1.WEIGHTS < 120)) foravg200)

UNION

(SELECT '120-140' WEIGHTS, AVG(foravg200.reboundavg) AVGREBOUND
FROM
(SELECT totalavg.PLAYER_NAME, totalavg.reboundavg
FROM
(SELECT foravg.PLAYER_NAME, AVG(DREB) reboundavg
FROM
(SELECT PLAYER_NAME, DREB
FROM PLAY_IN) foravg
WHERE foravg.PLAYER_NAME in 
(SELECT player_name
FROM PLAYER_CAREER PC
WHERE PC.POSITION in ('F-C','C-F','C'))
GROUP BY foravg.PLAYER_NAME) totalavg
WHERE totalavg.PLAYER_NAME in 
(SELECT DISTINCT PLAYER_NAME
FROM PLAYER_INFO_1 PI1
WHERE PI1.WEIGHTS >= 120 AND
PI1.WEIGHTS < 140)) foravg200)

UNION

(SELECT '>140' WEIGHTS, AVG(foravg200.reboundavg) AVGREBOUND
FROM
(SELECT totalavg.PLAYER_NAME, totalavg.reboundavg
FROM
(SELECT foravg.PLAYER_NAME, AVG(DREB) reboundavg
FROM
(SELECT PLAYER_NAME, DREB
FROM PLAY_IN) foravg
WHERE foravg.PLAYER_NAME in 
(SELECT player_name
FROM PLAYER_CAREER PC
WHERE PC.POSITION in ('F-C','C-F','C'))
GROUP BY foravg.PLAYER_NAME) totalavg
WHERE totalavg.PLAYER_NAME in 
(SELECT DISTINCT PLAYER_NAME
FROM PLAYER_INFO_1 PI1
WHERE PI1.WEIGHTS > 140)) foravg200);


END //



----Q7----
DROP PROCEDURE IF EXISTS TEAM_PERFORMACE;
CREATE PROCEDURE TEAM_PERFORMACE(IN team_abb VARCHAR(3))
BEGIN

select HOME_SCORE.HOME_TEAM_ID,ABBREVIATION,HOME_AVG_POINTS,AWAY_AVG_POINTS
  from (select HOME_TEAM_ID,AVG(FT_PCT_home) HOME_AVG_POINTS
        from GAME_DETAILS 
        where HOME_TEAM_ID = (SELECT TEAM_ID FROM TEAMS WHERE ABBREVIATION = team_abb)
        GROUP BY HOME_TEAM_ID) HOME_SCORE,
        -- select table for HOME_SCORE
        (select AWAY_SCORE.VISITOR_TEAM_ID,AWAY_AVG_POINTS
        FROM 
        (select VISITOR_TEAM_ID,AVG(FT_PCT_away) AWAY_AVG_POINTS
        from GAME_DETAILS 
        where VISITOR_TEAM_ID = (SELECT TEAM_ID FROM TEAMS WHERE ABBREVIATION = team_abb)
        GROUP BY VISITOR_TEAM_ID) AWAY_SCORE) AWAY_score,
        --SELECT TABLE FOR AWAY_SCORE
        -- CREATE THESE TWO SUB-TABLES TO OPTIMIZE THE QUERY
        TEAMS WHERE team_abb = TEAMS.ABBREVIATION;
  
END;

-- CALL TEAM_PERFORMACE('MIA');



----Q8----
 DELIMITER //
 DROP PROCEDURE IF EXISTS hightestfreethrowpoint;
 CREATE PROCEDURE hightestfreethrowpoint(IN PLAYNUMBER INTEGER(4))
 BEGIN

SELECT foravg.PLAYER_NAME, foravg.countavg, forcount.countplayer play_amount
FROM
(SELECT PIN.PLAYER_ID, PIN.PLAYER_NAME, AVG(FT_PCT) countavg
FROM PLAY_IN PIN
GROUP BY PIN.PLAYER_ID) foravg,
(SELECT PIN.PLAYER_ID, PIN.PLAYER_NAME, COUNT(PIN.PLAYER_ID) countplayer
FROM PLAY_IN PIN
GROUP BY PIN.PLAYER_ID) forcount
WHERE foravg.PLAYER_ID = forcount.PLAYER_ID AND forcount.countplayer >= PLAYNUMBER AND 
foravg.countavg in (
-- find the max free throw success percentag
SELECT MAX(formax.countavg)
FROM
-- calculate the average free throw success percentage and how many competition the player have participated in
(SELECT foravg.PLAYER_NAME, foravg.countavg, forcount.countplayer
FROM
(SELECT PIN.PLAYER_ID, PIN.PLAYER_NAME, AVG(FT_PCT) countavg
FROM PLAY_IN PIN
GROUP BY PIN.PLAYER_ID) foravg,
(SELECT PIN.PLAYER_ID, PIN.PLAYER_NAME, COUNT(PIN.PLAYER_ID) countplayer
FROM PLAY_IN PIN
GROUP BY PIN.PLAYER_ID) forcount
WHERE foravg.PLAYER_ID = forcount.PLAYER_ID AND forcount.countplayer >= PLAYNUMBER) formax);

END //



----Q9----
DROP TABLE IF EXISTS TMP;
-- TMP saves part of the R_IN_ABB and player INFO DATA AND CREATED AS A TABLE
-- CREATED THIS TABLE IN ORDER TO OPTIMIZE THE QUERY RUNNING TIME
create table TMP AS
SELECT R_IN_ABB.team_abb,R_IN_ABB.state,BIRTH_STATE,R_IN_ABB.player_name
FROM R_IN_ABB,team_abb,PLAYER_INFO_1
WHERE team_abb.team_name = R_IN_ABB.team_name AND PLAYER_INFO_1.PLAYER_NAME = R_IN_ABB.player_name;

SELECT DISTINCT BIRTH_STATE FROM TMP;

select * FROM TMP WHERE BIRTH_STATE='Texas';

update  TMP  set  BIRTH_STATE = replace(replace(replace(BIRTH_STATE,char(9),''),char(10),''),char(13),''); 
-- PROCEDURE FOR CHECK THE PERCENTAGE OF HIRE PLAYER FROM SAME STATE FOR TEAMS
DROP PROCEDURE IF EXISTS HIRE_SAME_STATE;
CREATE PROCEDURE HIRE_SAME_STATE()
BEGIN
SELECT S.team_abb, C/A percentage_of_same_state
FROM 
(select team_abb,COUNT(state) C from TMP where state=BIRTH_STATE GROUP BY team_abb) S,
(select team_abb,COUNT(state) A from TMP GROUP BY team_abb) A
WHERE S.team_abb=A.team_abb
ORDER BY percentage_of_same_state DESC;
END;





----Q10----
-- create view to let PROCEDURE use less time
DROP VIEW IF EXISTS FORELO;
CREATE VIEW FORELO AS
SELECT dates, TEAM_abb_home, TEAM_abb_away, elo_home_post,elo_away_post
FROM ELO;

-- SELECT * FROM FORELO WHERE dates = '2020-12-20';
 
 
 
 DELIMITER //
DROP PROCEDURE IF EXISTS makeprediction;

CREATE PROCEDURE makeprediction(IN D VARCHAR(15), IN HOMEABB VARCHAR(3), IN AWAYABB VARCHAR(3))
BEGIN
  -- calculate the probability of win of this two home team and away team at a certain date to make prediction.
  SELECT home_team.team_name hometeam, home_team.team_elo homeelo, away_team.team_name awayteam, away_team.team_elo awayelo,
  ((1/(1/1+POW(10,((away_team.team_elo-home_team.team_elo)/400))))*0.64)/(((1/(1/1+POW(10,((away_team.team_elo-home_team.team_elo)/400))))*0.64)+(1-((1/(1/1+POW(10,((away_team.team_elo-home_team.team_elo)/400))))))*0.36) home_team_win_rate,
  (1-((1/(1/1+POW(10,((away_team.team_elo-home_team.team_elo)/400))))*0.64)/(((1/(1/1+POW(10,((away_team.team_elo-home_team.team_elo)/400))))*0.64)+(1-((1/(1/1+POW(10,((away_team.team_elo-home_team.team_elo)/400))))))*0.36)) away_team_win_rate
  FROM
  (SELECT forfinal.team_name, forfinal.team_elo
  FROM
  ((SELECT F.dates, F.TEAM_abb_home team_name, F.elo_home_post team_elo
  FROM FORELO F
  WHERE F.dates < D AND
  F.TEAM_abb_home = HOMEABB)

  UNION
  -- find the latest elo score of home team at a certain date
  (SELECT F.dates, F.TEAM_abb_away team_name, F.elo_away_post team_elo
  FROM FORELO F
  WHERE F.dates < D AND
  F.TEAM_abb_away = HOMEABB) ) forfinal
  WHERE forfinal.dates IN (
  SELECT MAX(dates)
  FROM
  (
  (SELECT F.dates, F.TEAM_abb_home team_name, F.elo_home_post team_elo
  FROM FORELO F
  WHERE F.dates < D AND
  F.TEAM_abb_home = HOMEABB)

  UNION
  -- find the latest elo socre of away team at a certain date
  (SELECT F.dates, F.TEAM_abb_away team_name, F.elo_away_post team_elo
  FROM FORELO F
  WHERE F.dates < D AND
  F.TEAM_abb_away = HOMEABB) ) formax)) home_team,
  (SELECT forfinal.team_name, forfinal.team_elo
  FROM
  ((SELECT F.dates, F.TEAM_abb_home team_name, F.elo_home_post team_elo
  FROM FORELO F
  WHERE F.dates < D AND
  F.TEAM_abb_home = AWAYABB)
  UNION
  (SELECT F.dates, F.TEAM_abb_away team_name, F.elo_away_post team_elo
  FROM FORELO F
  WHERE F.dates < D AND
  F.TEAM_abb_away = AWAYABB) ) forfinal
  WHERE forfinal.dates IN (
  SELECT MAX(dates)
  FROM
  (
  (SELECT F.dates, F.TEAM_abb_home team_name, F.elo_home_post team_elo
  FROM FORELO F
  WHERE F.dates < D AND
  F.TEAM_abb_home = AWAYABB)
  UNION

  (SELECT F.dates, F.TEAM_abb_away team_name, F.elo_away_post team_elo
  FROM FORELO F
  WHERE F.dates < D AND
  F.TEAM_abb_away = AWAYABB) ) formax)) away_team;

END;




----Q11----
DROP PROCEDURE IF EXISTS CHAMPION;
-- PROCEDURE FOR FIND THE CHAMPION TEAM DATA
CREATE PROCEDURE CHAMPION(IN season VARCHAR(4))
BEGIN
  SELECT Year,Status,Team,Team,PTS,FG,FGA,FGP,TP,TPA,TPP,FT,FTA,FTP,ORB,DRB,TRB,AST,STL,BLK,TOV,PF
  FROM CHAMP
  WHERE Year = season;
END;

-- CALL CHAMPION('2017');




----Q12----
DELIMITER //

DROP PROCEDURE IF EXISTS attempt1;
CREATE PROCEDURE attempt1(IN D VARCHAR(15), IN HOMEABB VARCHAR(6), IN AWAYABB VARCHAR(6), IN HOMEABBWIN VARCHAR(6), IN AWAYABBWIN VARCHAR(6), IN IP_PASS VARCHAR(28), IN HOMESCORE VARCHAR(6), IN AWAYSCORE VARCHAR(6), IN SEASON VARCHAR(6))

BEGIN
SET @EXISTPASS = (SELECT EXISTS(SELECT 1 FROM Passwords P where P.CurPasswords = IP_PASS));
 IF (@EXISTPASS = 1) THEN

-- create a table to temporaily store all calculation result
DROP TABLE IF EXISTS temp5;
CREATE TABLE temp5 AS
SELECT D as dates, SEASON as season, hometeam, awayteam, homeelo homeelo_pre, awayelo awayelo_pre, home_team_win_rate, away_team_win_rate, 
(homeelo+20*(HOMEABBWIN-home_team_win_rate)) homeelo_post, (awayelo+20*(AWAYABBWIN-away_team_win_rate)) awayelo_post,HOMESCORE as homescore, AWAYSCORE as awayscore
FROM
(SELECT home_team.team_name hometeam, home_team.team_elo homeelo, away_team.team_name awayteam, away_team.team_elo awayelo,
((1/(1/1+POW(10,((away_team.team_elo-home_team.team_elo)/400))))*0.64)/(((1/(1/1+POW(10,((away_team.team_elo-home_team.team_elo)/400))))*0.64)+(1-((1/(1/1+POW(10,((away_team.team_elo-home_team.team_elo)/400))))))*0.36) home_team_win_rate,
(1-((1/(1/1+POW(10,((away_team.team_elo-home_team.team_elo)/400))))*0.64)/(((1/(1/1+POW(10,((away_team.team_elo-home_team.team_elo)/400))))*0.64)+(1-((1/(1/1+POW(10,((away_team.team_elo-home_team.team_elo)/400))))))*0.36)) away_team_win_rate
FROM
(SELECT forfinal.team_name, forfinal.team_elo
FROM
((SELECT F.dates, F.TEAM_abb_home team_name, F.elo_home_post team_elo
FROM FORELO F
WHERE F.dates <= D AND
F.TEAM_abb_home = HOMEABB)

UNION
-- find the latest elo score of home team at a certain date
(SELECT F.dates, F.TEAM_abb_away team_name, F.elo_away_post team_elo
FROM FORELO F
WHERE F.dates <= D AND
F.TEAM_abb_away = HOMEABB) ) forfinal
WHERE forfinal.dates IN (
SELECT MAX(dates)
FROM
(
(SELECT F.dates, F.TEAM_abb_home team_name, F.elo_home_post team_elo
FROM FORELO F
WHERE F.dates <= D AND
F.TEAM_abb_home = HOMEABB)

UNION
-- find the latest elo socre of away team at a certain date
(SELECT F.dates, F.TEAM_abb_away team_name, F.elo_away_post team_elo
FROM FORELO F
WHERE F.dates <= D AND
F.TEAM_abb_away = HOMEABB) ) formax)) home_team,

(SELECT forfinal.team_name, forfinal.team_elo
FROM
((SELECT F.dates, F.TEAM_abb_home team_name, F.elo_home_post team_elo
FROM FORELO F
WHERE F.dates <= D AND
F.TEAM_abb_home = AWAYABB)
UNION
(SELECT F.dates, F.TEAM_abb_away team_name, F.elo_away_post team_elo
FROM FORELO F
WHERE F.dates <= D AND
F.TEAM_abb_away = AWAYABB) ) forfinal
WHERE forfinal.dates IN (
SELECT MAX(dates)
FROM
(
(SELECT F.dates, F.TEAM_abb_home team_name, F.elo_home_post team_elo
FROM FORELO F
WHERE F.dates <= D AND
F.TEAM_abb_home = AWAYABB)
UNION

(SELECT F.dates, F.TEAM_abb_away team_name, F.elo_away_post team_elo
FROM FORELO F
WHERE F.dates <= D AND
F.TEAM_abb_away = AWAYABB) ) formax)) away_team) forfinal;

-- SELECT * FROM temp5;
-- insert all these result to the original table ELO
INSERT INTO ELO (dates, season, TEAM_abb_home, TEAM_abb_away, elo_home_pre, elo_away_pre, elo_home_prob, 
elo_away_prob, elo_home_post, elo_away_post, score_home, score_away)
SELECT dates, season, hometeam, awayteam, homeelo_pre, awayelo_pre, home_team_win_rate, 
away_team_win_rate, homeelo_post, awayelo_post, homescore, awayscore FROM temp5;

-- show the user that what have been inert to ELO
SELECT *
FROM ELO
WHERE dates = D;

ELSE SELECT "Error : Incorrect Password" as ' ';
END IF;

END;



-- CALL attempt1('2021-09-26','POR','SAC','1','0','databasesfinalproject21','2021','45','23');




----Q13----
DELIMITER //
-- PROCEDURE TO FIND THE LATEST ELO SCORE
DROP PROCEDURE IF EXISTS latestelo;
CREATE PROCEDURE latestelo(IN D VARCHAR(15), IN HOMEABB VARCHAR(6))

BEGIN
-- SELECT WHEN TEAM AS HOME
SELECT forfinal.team_name, forfinal.team_elo
  FROM
  ((SELECT F.dates, F.TEAM_abb_home team_name, F.elo_home_post team_elo
  FROM FORELO F
  WHERE F.dates < D AND
  F.TEAM_abb_home = HOMEABB)

  UNION
-- SELECT LATEST DATE ELO DATAS
  (SELECT F.dates, F.TEAM_abb_away team_name, F.elo_away_post team_elo
  FROM FORELO F
  WHERE F.dates < D AND
  F.TEAM_abb_away = HOMEABB) ) forfinal
  WHERE forfinal.dates IN (
  SELECT MAX(dates)
  FROM
  (
  (SELECT F.dates, F.TEAM_abb_home team_name, F.elo_home_post team_elo
  FROM FORELO F
  WHERE F.dates < D AND
  F.TEAM_abb_home = HOMEABB)

  UNION

  (SELECT F.dates, F.TEAM_abb_away team_name, F.elo_away_post team_elo
  FROM FORELO F
  WHERE F.dates < D AND
  F.TEAM_abb_away = HOMEABB) ) formax);
  END;




----Q14----
DROP VIEW IF EXISTS forq8;
CREATE VIEW forq8 AS
SELECT I.Name, DATE_FORMAT(I.dates,'%Y') injury_year, IT.threetype Position, I.Notes
FROM INJURY as I, INJURY_TYPE as IT
WHERE I.Position = IT.Origintype;

DELIMITER //
 DROP PROCEDURE IF EXISTS positioninjurymax;
 CREATE PROCEDURE positioninjurymax(IN P VARCHAR(15))
 BEGIN

SELECT forfinal.injury_year, forfinal.icount amount
FROM
(SELECT injury_year, COUNT(Position) icount
FROM forq8 foryear
WHERE foryear.Position = P
GROUP BY injury_year) forfinal
WHERE forfinal.icount in (
--  find the max injury year
SELECT max(icount)
FROM
-- calculate the number of injury for this position in every year
(SELECT injury_year, COUNT(Position) icount
FROM forq8 foryear
WHERE foryear.Position = P
GROUP BY injury_year) formax);

END;



----Q15----
-- PROCEDURE TO CHECK THE INJURY RECORDS OF PLAYER AT SPECIFIC YEAR
DROP PROCEDURE IF EXISTS CHECK_INJURY;
CREATE PROCEDURE CHECK_INJURY(IN year VARCHAR(4), IN player VARCHAR(20))
BEGIN
  SELECT * FROM INJURY
  WHERE dates like CONCAT('%',year) AND Name = player;
END;

-- call CHECK_INJURY('2017','lebron James');




----Q16----
-- PROCEDURE TO FIND THE PLAYER RATINGS SATISFY THE RANGE OF SALARY, SEASON, AND POSITION
DROP procedure IF EXISTS FIND_PLAYER_SALARY;
CREATE PROCEDURE FIND_PLAYER_SALARY(IN Positions VARCHAR(5), IN salariesmin INT(15), IN salariesmax INT(15),seasons VARCHAR(4))
-- ROUND THE RATINGS TO TWO DIGIT
SELECT distinct full_name,position,salary,ROUND((rating-min_2k)/(max_2k-min_2k),2) 2K_RATING, (ROUND(our_rating,2)) OUR_RATING, ROUND(((rating-min_2k)/(max_2k-min_2k) + our_rating) /2,2) AVG_RATING,season
FROM P1,(SELECT Player, Year, (((PTS + TRB + AST + STL + BLK - (FGA -FG) - (FTA - FT) - TOV) / G)-mi)/(ma-mi) our_rating
FROM Seasons_Stats,(SELECT MAX(rating) ma, MIN(rating) mi
FROM
(SELECT Player, Year, (PTS + TRB + AST + STL + BLK - (FGA -FG) - (FTA - FT) - TOV) / G rating
FROM Seasons_Stats
group by Player, Year) RATES) mami --COMPUTE THE MAX AND MIN FOR RATING
group by Player, Year) OWN_RATING, --TABLE INCLUDING INFORMATION OF OUR OWN RATING
(select MIN(rating) min_2k, MAX(rating) max_2k from P1) 2k_mami -- COMPUTE THE MAX, MIN FOR 2K RATING 
WHERE OWN_RATING.Player = P1.full_name and OWN_RATING.year = P1.season and position = Positions AND season = seasons and salary>=salariesmin and salary<=salariesmax
ORDER BY rating ASC;
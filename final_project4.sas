filename shortcut "/home/thephamnhat0/224/*.txt" ;
proc format;
invalue lettertnum
"A" = 4.0
"A-" = 3.7
"B+" = 3.4
"B" = 3.0
"B-" = 2.7
"C+" = 2.4
"C" = 2.0
"C-" = 1.7
"D+" = 1.4
"D" = 1.0
"D-" = 0.7
other = 0 
;
run;

proc format;
 invalue cd_earned
 "A" = 1
 "A-" = 1
 "B+" = 1
 "B" = 1
 "B-" = 1
 "C+" = 1
 "C" = 1
 "C-" = 1
 "D+" = 1
 "D" = 1
 "D-" = 1
 "P" = 1
 other = 0;
run;

proc format;
 invalue cd_graded
 "A" = 1
 "A-" = 1
 "B+" = 1
 "B" = 1
 "B-" = 1
 "C+" = 1
 "C" = 1
 "C-" = 1
 "D+" = 1
 "D" = 1
 "D-" = 1
 "E" = 1
 "WE" = 1
 "UW" = 1
 "IE" = 1
 other = 0;
run;

proc format;
invalue A_grade
"A" = 1
"A-" = 1
other = 0;
run;
proc format;
invalue B_grade
"B+" = 1
"B" = 1
"B-" = 1
other = 0;
run;
proc format;
invalue C_grade
"C+" = 1
"C" = 1
"C-" = 1
other = 0;
run;
proc format;
invalue D_grade
"D+" = 1
"D" = 1
"D-" = 1
other = 0;
run;
proc format;
invalue E_grade
"E" = 1
"UW" = 1
"WE" = 1
"IE" = 1
other = 0;
run;
proc format;
invalue W_grade
"W" = 1
other = 0;
run;

data final;
 infile shortcut dlm="@";
 length ID $ 5 Course $ 10;
 input ID $ Date Course $ Credit Grade $;
 GPAgrade=input(Grade, lettertnum.);
 Credit_earned=input(Grade,cd_earned.);
 Credit_graded=input(Grade,cd_graded.);
 A=input(Grade,A_grade.);
 B=input(Grade,B_grade.);
 C=input(Grade,C_grade.);
 D=input(Grade,D_grade.);
 E=input(Grade,E_grade.);
 W=input(Grade,W_grade.);
run;

%macro report2(course,table);

proc sql;
 create table &course._2 as
 select *, Credit*Credit_earned as Total_Credit, Credit*Credit_graded as Graded_Credit
 from &course;
quit;

proc sql;
 create table &course._4 as
 select ID, sum(Credit*Credit_earned) as Total_Credit, sum(Credit*Credit_graded) as Graded_Credit
 from &course
group by ID;
quit;

proc sql;
create table &course._3 as 
select *, substr(put(Date, 3.),1,1) as term, substr(put(Date,3.), 2,2) as year
from &course._2
order by year, term desc;
quit;

proc sql;
create table &course._rep_classes as
select *, monotonic() as ROW_ID
from &course._3 where substr(reverse(course),1,1)^="R"
;
quit;

proc sql;
create table &course._rep_classes as
select ID, Course, Total_Credit as Total_Credit1 
from &course._rep_classes
group by ID, Course
having ROW_ID=min(ROW_ID);
quit;

proc sql;
create table &course._sem_gpa_repeat as
select sum(GPAgrade*Graded_Credit) as numerator, sum(Graded_Credit) as earned, 
calculated numerator/calculated earned as CourseGPA, ID, Course
from &course._2
where substr(reverse(course),1,1)^="R"
group by ID, Course
;
quit;

proc sql;
create table &course._nonR as
select *, r.Total_Credit1, s.numerator, s.earned, s.CourseGPA
from &course._2 as f, &course._rep_classes as r, &course._sem_gpa_repeat as s 
where f.ID=r.ID=s.ID and f.Course= r.Course= s.Course
;
quit;

proc sql;
create table &course._table_R as
select *, Total_Credit as Total_Credit1, GPAgrade*Graded_Credit as numerator, Graded_Credit as Earned, calculated numerator/ earned as CourseGPA
from &course._2
where substr(reverse(course),1,1)="R"
;
quit;

proc sql;
create table &course._final_table as
select *
from &course._nonR
union 
select * from &course._table_R
;
quit;

proc sql;
	create table &course._over_gpa as
	select sum(GPAgrade*Graded_Credit) as numerator, sum(Graded_Credit) as earned, 
		calculated numerator/calculated earned as overGPA, ID, Date
	from &course._final_table
	group by ID;
quit;

proc sql;
create table &course._sem_gpa as
select sum(GPAgrade*Graded_Credit) as numerator, sum(Graded_Credit) as earned, 
calculated numerator/calculated earned as TermGPA, ID, Date
from &course._final_table
group by ID, Date
;
quit;

proc sort 
data=&course._3 out=&course._sorted; 
by id course year term;
run;

data &course._retakes;
set &course._sorted;
by id course;
if last.course then retakes=0;
else retakes=1;
run;

proc sql;
create table &course._retakes1 as
select ID, sum(retakes) as total_retakes
from &course._retakes
group by id;
quit;

proc sql;
create table &course._number_grades as
select ID, sum(A) as total_A, sum(B) as total_B, sum(C) as total_C, sum(D) as total_D, sum(E) as total_E, sum(W) as total_W
from &course
group by id;
quit;

proc sql;
create table &table as
select o.ID, o.overGPA, f.Total_Credit, f.Graded_Credit, n.total_A, n.total_B, n.total_C, n.total_D, n.total_E, n.total_W, r.total_retakes
from &course._number_grades as n, &course._retakes1 as r, &course._4 as f, &course._over_gpa as o
where n.ID=r.ID=f.ID=o.ID
order by ID;
quit;

proc sort data=&table nodupkey;
by ID;
run;

%mend report2;

*Report 1 section 2;
%report2(final,table2);

*Cumulative total proc summary;
* sem_gpa_new fixed the wrong order of term and year;
proc sql;
create table sem_gpa_new as
select numerator, earned, ID, substr(put(Date, 3.),1,1) as term, substr(put(Date,3.), 2,2) as year, TermGPA, Date
from final_sem_gpa
order by ID, year, term ;
quit;

data cuml;
set sem_gpa_new;
by ID;
if ID ne lag(ID) then cum_num=0;
if ID ne lag(ID)then cum_den=0;
cum_num+numerator;
cum_den+earned;
run;

proc sql;
create table cuml as
select *, cum_num /cum_den as cum 
from cuml
order by ID, Year, Term;
quit;

*Class Standing;
data cuml2;
set cuml;
if cum_den <=29.9 then Class_Standing ="Freshman";
if cum_den >29.9 and cum_den <=59.9 then Class_Standing ="Sophomore";
if cum_den >59.9 and cum_den <=89.9 then Class_Standing ="Junior";
if cum_den >89.9 then Class_Standing ="Senior";
run; 

proc sql;
create table final_final_sem_GPA as
select c.*, g.cum, g.class_standing
from final_sem_gpa as c, cuml2 as g
where c.ID=g.ID and c.Date=g.Date;
quit;



*Create the final reports for section 1 of report 1;
proc sql;
create table table1 as
select s.ID, s.Date, s.TermGPA, s.cum, s.Class_standing, f.Total_Credit, f.Graded_Credit
from final_final_sem_gpa as s, final_4 as f
where s.ID=f.ID;
quit;

proc sql;
create table table1_new as 
select ID, substr(put(Date, 3.),1,1) as term, substr(put(Date,3.), 2,2) as year, TermGPA, cum as cumulating, Class_standing, Total_Credit, Graded_Credit
from table1
order by ID, year, term ;
quit;


/* proc sql;
create table courses as
select course
from final
where course like '%STAT%' and '%MATH%'
order by course;
quit; */

*Report 2;
data course;
set final;
if course in: ('MATH','STAT');
run;
*Credit Earned and Graded by course, use this to calculate sem gpa; 

*Creating section 1 of report 2;
%report2(final,table2);
*Creating section 2 of report 2;
%report2(course,table3);

*Creating report 3;
proc sql;
create table table4 as
select *
from table2
where Total_Credit between 60 and 130
order by overGPA desc;
quit;

*Report 3;
data table4; set table4 (obs=12); run;

*Creating report 4;

proc sql;
create table table5 as
select *
from table3
where Total_Credit > 20
order by overGPA desc;
quit;

*Report 4;
data table5; set table5 (obs=16); run;

ods html file="/home/thephamnhat0/124/224/output_new.html";
proc report data=table1_new;
title "Report 1 section 1";
run;
proc report data=table2;
title "Report 1 section 2";
run;
proc report data=table2;
title "Report 2 section 1";
run;
proc report data=table3 ;
title "Report 2 section 2";
run;
proc report data=table4;
title "Report 3";
run;
proc report data=table5;
title "Report 4";
run;
ods html close;

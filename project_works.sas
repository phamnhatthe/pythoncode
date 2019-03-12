/* reading data */
%macro read(x,y);
Proc import datafile=&x out=&y dbms=csv replace;
getnames= no;
Guessingrows=32767;
run;
%mend read;

%macro read2(x,y);
Proc import datafile=&x out=&y dbms=csv replace;
getnames= yes; datarow=2; Guessingrows=32767;
run;
%mend read2;

%read('/home/thephamnhat0/124/project 2/FormA.csv',formA);
%read('/home/thephamnhat0/124/project 2/FormB.csv',formB);
%read('/home/thephamnhat0/124/project 2/FormC.csv',formC);
%read('/home/thephamnhat0/124/project 2/FormD.csv',formD);
%read('/home/thephamnhat0/124/project 2/answer_a.csv',answera);
%read('/home/thephamnhat0/124/project 2/answer_b.csv',answerb);
%read('/home/thephamnhat0/124/project 2/answer_c.csv',answerc);
%read('/home/thephamnhat0/124/project 2/answer_d.csv',answerd);
%read2('/home/thephamnhat0/124/project 2/Domains FormA.csv',domainsA);
%read2('/home/thephamnhat0/124/project 2/Domains FormB.csv',domainsB);
%read2('/home/thephamnhat0/124/project 2/Domains FormC.csv',domainsC);
%read2('/home/thephamnhat0/124/project 2/Domains FormD.csv',domainsD);

%macro drop(a);
data &a(drop = itemid--domain);set &a; run;
%mend;
%drop(domainsA);
%drop(domainsB);
%drop(domainsC);
%drop(domainsD);

%macro id(a);
data &a._id (keep=var1); set &a; run;
%mend id;

%id(formA);
%id(formB);
%id(formC);
%id(formD);

proc sql;
create table forma_id
   as select *, 'A' format=$8. as form from formA_id;
quit;
proc sql;
create table formb_id
   as select *, 'B' format=$8. as form from formb_id;
quit;
proc sql;
create table formc_id
   as select *, 'C' format=$8. as form from formc_id;
quit;
proc sql;
create table formd_id
   as select *, 'D' format=$8. as form from formd_id;
quit;

/*compile id*/
data id; set formA_id formB_id formC_id formD_id; run;
data id (rename=(var1=id)); set id; run;

/*a is formA, b is answera, c is n of obs, d is c - 1*/
%macro transform(a,b,c,d); data &a._new (drop=var1); set &a; run;
Proc transpose data=&a._new  out= &a._new ; Var var2-var151; Run;
data &a._new (drop=_name_); set &a._new; run;
proc transpose data=&b out=&b._new; var var1-var150; run;
data &b._new(drop= _name_);set &b._new; run;
data &a._new; merge &a._new &b._new(rename=(col1=COL&c)); run;
Data &a._ovr; Set &a._new;
Array e[&c] col1-col&c; Do i=1 to &c;
If e[i] = e[&c] then e[i] =1 ; else e[i]=0;
End; drop i; Run;
data &a._ovr(drop = col&c); set &a._ovr; run;
DATA &a._ovr; SET &a._ovr;
ARRAY X[*] col1-col&c ; array var[&c] var1-var&c;
DO I = 1 TO &c; var[i]=inPUT( X[I],1.) ;
END; drop i; RUN;
data &a._ovr(keep=var1-var&d);set &a._ovr; run;
%mend transform;

%transform(formA,answera,51,50);
%transform(formB,answerb,50,49);
%transform(formC,answerc,51,50);
%transform(formD,answerd,51,50);

/*a is formA_ovr; c is n of obs*/
%macro score(a,c);
data &a._new; set &a;
array m{&c} var1-var&c; array s{&c} (0);
do i=1 to &c; s{i}=sum(s{i},m{i}); 
end; drop i; run;
data &a._new(keep=s1-s&c); set &a._new; run;
proc transpose data=&a._new out=&a._new; var s1-s&c; run;
data &a._new(keep=col150); set &a._new; run;
%mend score;

/*print formA_ovr_new */
%score(formA_ovr,50);
%score(formB_ovr,49);
%score(formC_ovr,50);
%score(formD_ovr,50);
/*compile overall score*/
data score; set formA_ovr_new formB_ovr_new formC_ovr_new formD_ovr_new; run;
data score (rename=(col150=ovr_score)); set score; run;

%macro avg(a);
Data &a._avg; Set &a._ovr_new;
Array e[1] col150;
 Do i=1 to 1;
e[i] = 100*round(e[i]/150,0.01);
End; drop i; Run;
%mend avg;

/* prints formA_avg */
%avg(formA);
%avg(formB);
%avg(formC);
%avg(formD);
/* compile overall percentage */
data avg; set formA_avg formB_avg formC_avg formD_avg; run;
data avg(rename=(col150=ovr_percent));set avg; run;

%macro merge_dom(a,f);
data &a._new;
     merge &a(rename=(var4=n)) &f._ovr; run;
%mend merge_dom;


%merge_dom(domainsa,forma);
%merge_dom(domainsb,formb);
%merge_dom(domainsc,formc);
%merge_dom(domainsd,formd);

%macro dom_sort(a);
data &a.1 &a.2 &a.3 &a.4 &a.5;
set &a._new;
if dom=1 then output &a.1;
else if dom=2 then output &a.2;
else if dom=3 then output &a.3;
else if dom=4 then output &a.4;
else if dom=5 then output &a.5;
else output &a.5;
run;
%mend dom_sort;

%dom_sort(domainsA);
%dom_sort(domainsB);
%dom_sort(domainsC);
%dom_sort(domainsD);
/* a is domain, c is n obs */
%macro dom_trans(a,c);
DATA &a._new; SET &a.1 &a.2 &a.3 &a.4 &a.5;
ARRAY X[*] var1-var&c; 
array s[&c] (0);
DO I = 1 TO &c ; s{i}=sum(s{i},x{i});
END; drop i;
RUN;
%mend dom_trans;

%dom_trans(domainsa,50);
%dom_trans(domainsb,49);
%dom_trans(domainsc,50);
%dom_trans(domainsd,50);

/* a is domainsa, c is n of obs*/
%macro dom_ovr(a,c);
data &a._new (keep=s1-s&c); set &a._new; run;
proc transpose data=&a._new out=&a._new; var s1-s&c; run;
data &a._new(drop=_name_); set &a._new; run;
/* cols to keep: 30; 65; 95; 125; 150*/
data &a._new(keep=col30 col65 col95 col125 col150); set &a._new; run;
data &a._new(rename=(col30=col5 col65=col4 col95=col3 col125=col2 col150=col1)); set &a._new; run;

DATA &a._new; SET &a._new;
ARRAY X[5] col1-col5; 
DO I = 1 TO 5 ;
if i=5 then x[i]=x[i];
else x[i]=x[i]-x[i+1];
END; drop i;
RUN;
data &a._new(rename=(col5=dom1_ovr col4=dom2_ovr col3=dom3_ovr col2=dom4_ovr col1=dom5_ovr)); set &a._new; run;
%mend dom_ovr;

%dom_ovr(domainsa,50);
%dom_ovr(domainsb,49);
%dom_ovr(domainsc,50);
%dom_ovr(domainsd,50);
/* above print domainsa_new*/
/*compile domain overall*/
data dom_ovr; set domainsa_new domainsb_new domainsc_new domainsd_new; run;
/* cols to keep: 30; 65; 95; 125; 150*//*a is domainsA*/
%macro dom_per(a);
DATA &a._percent; SET &a._new;
ARRAY X[*] _numeric_; 
DO I = 1 TO dim(x) ;
if i=1 then x[i]=100*round(x[i]/30,0.01);
else if i=2 then x[i]=100*round(x[i]/35,0.01);
else if i=3 then x[i]=100*round(x[i]/30,0.01);
else if i=4 then x[i]=100*round(x[i]/30,0.01);
else x[i]=100*round(x[i]/25,0.01);
END; drop i;
RUN;
data &a._percent(rename=(dom1_ovr=dom1_percent dom2_ovr=dom2_percent dom3_ovr=dom3_percent dom4_ovr=dom4_percent dom5_ovr=dom5_percent)); set &a._percent; run;
%mend dom_per;
/*prints domainsA_percent*/
%dom_per(domainsA);
%dom_per(domainsB);
%dom_per(domainsC);
%dom_per(domainsD);
/*compile domain percent*/
data dom_per; set domainsA_percent domainsB_percent domainsC_percent domainsD_percent; run;

data student_report_sec_1;
title "Student Report Section 1";
merge id score avg dom_ovr dom_per; run;

Proc sort data=student_report_sec_1 out=student_report_sec_1;
By id;
Run;

data student_report_sec_2;
title "Student Report Section 2";
merge id avg score dom_per dom_ovr; run;

Proc sort data=student_report_sec_2 out=student_report_sec_2;
By descending ovr_percent;
Run;
/* boxplot student report sec 3*/
data boxplot(keep=dom1_percent dom2_percent dom3_percent dom4_percent dom5_percent); set student_report_sec_1; run;
proc sql;
create table boxplot_new
   as select *, 'dom 1' format=$8. as dom_1 from boxplot;
create table boxplot_new
	as select *, 'dom 2' format=$8. as dom_2 from boxplot_new;
create table boxplot_new
	as select *, 'dom 3' format=$8. as dom_3 from boxplot_new;
create table boxplot_new
	as select *, 'dom 4' format=$8. as dom_4 from boxplot_new;
create table boxplot_new
	as select *, 'dom 5' format=$8. as dom_5 from boxplot_new;
quit;
data boxplot_new_2; set boxplot_new(keep=dom_1 rename=(dom_1=dom)) boxplot_new(keep=dom_2 rename=(dom_2=dom)) boxplot_new(keep=dom_3 rename=(dom_3=dom)) boxplot_new(keep=dom_4 rename=(dom_4=dom)) boxplot_new(keep=dom_5 rename=(dom_5=dom));
run;
data boxplot_new_3; set boxplot_new(keep=dom1_percent rename=(dom1_percent=dom_percent)) boxplot_new(keep=dom2_percent rename=(dom2_percent=dom_percent)) boxplot_new(keep=dom3_percent rename=(dom3_percent=dom_percent)) boxplot_new(keep=dom4_percent rename=(dom4_percent=dom_percent)) boxplot_new(keep=dom5_percent rename=(dom5_percent=dom_percent));
run;
data boxplot_comp;
	merge boxplot_new_2 boxplot_new_3;
run;

/* student report sec 4*/
%macro per_boxplot(a);
proc sql;
create table &a._percent_new
   as select *, 'dom 1' format=$8. as dom_1 from &a._percent;
create table &a._percent_new
	as select *, 'dom 2' format=$8. as dom_2 from &a._percent_new;
create table &a._percent_new
	as select *, 'dom 3' format=$8. as dom_3 from &a._percent_new;
create table &a._percent_new
	as select *, 'dom 4' format=$8. as dom_4 from &a._percent_new;
create table &a._percent_new
	as select *, 'dom 5' format=$8. as dom_5 from &a._percent_new;
quit;
data &a._percent_2; set &a._percent_new(keep=dom_1 rename=(dom_1=dom)) &a._percent_new(keep=dom_2 rename=(dom_2=dom)) &a._percent_new(keep=dom_3 rename=(dom_3=dom)) &a._percent_new(keep=dom_4 rename=(dom_4=dom)) &a._percent_new(keep=dom_5 rename=(dom_5=dom));
run;
data &a._percent_3; set &a._percent_new(keep=dom1_percent rename=(dom1_percent=dom_percent)) &a._percent_new(keep=dom2_percent rename=(dom2_percent=dom_percent)) &a._percent_new(keep=dom3_percent rename=(dom3_percent=dom_percent)) &a._percent_new(keep=dom4_percent rename=(dom4_percent=dom_percent)) &a._percent_new(keep=dom5_percent rename=(dom5_percent=dom_percent));
run;
data &a._percent_new;
	merge &a._percent_2 &a._percent_3;
run;
%mend per_boxplot;

%per_boxplot(domainsA);
%per_boxplot(domainsB);
%per_boxplot(domainsC);
%per_boxplot(domainsD);
proc sql;
create table domainsA_percent_new
   as select *, 'A' format=$8. as form from domainsA_percent_new;
quit;
proc sql;
create table domainsB_percent_new
   as select *, 'B' format=$8. as form from domainsB_percent_new;
quit;
proc sql;
create table domainsC_percent_new
   as select *, 'C' format=$8. as form from domainsC_percent_new;
quit;
proc sql;
create table domainsD_percent_new
   as select *, 'D' format=$8. as form from domainsD_percent_new;
quit;

data boxplot2; 
	set domainsA_percent_new domainsB_percent_new domainsC_percent_new domainsD_percent_new;
run;

/*exam report*/
/* a is formA c is # obs*/
%macro question(a,c);
proc transpose data=&a._ovr out=&a._question; var var1-var&c; run;
data &a._question(drop=_name_); set &a._question; run;

data &a._question; set &a._question;
array m{150} col1-col150; 
array s{150} (0);
do i=1 to 150; 
s{i}=sum(s{i},m{i}); 
end; drop i; run;

data &a._question(keep=s1-s150); set &a._question; run;
proc transpose data=&a._question out=&a._question; var s1-s150; run;
data &a._question(keep=col&c); set &a._question; run;

data &a._question; set &a._question;
array x[1] col&c;
do i= 1 to 1;
if i=1 then x[i]=100*round(x[i]/50,0.01);
end; drop i; run;

data &a._question; set &a._question;
array x[1] col&c;
array n[1] q_number;
do i=1 to 1;
if i=1 then n[i]=_n_;
end; drop i; run;
%mend question;

%question(formA,50);
%question(formB,49);
%question(formC,50);
%question(formD,50);

proc sql;
create table forma_question
   as select *, 'A' format=$8. as form from forma_question;
quit;
proc sql;
create table formb_question
   as select *, 'B' format=$8. as form from formb_question;
quit;
proc sql;
create table formc_question
   as select *, 'C' format=$8. as form from formc_question;
quit;
proc sql;
create table formd_question
   as select *, 'D' format=$8. as form from formd_question;
quit;

/*a is formA, c is # obs*/
%macro organize(a,c);
data &a._question;
merge &a._question(keep=form) &a._question(keep=q_number) &a._question(keep=col&c);
run;
data &a._question(rename=(col&c=percent)); set &a._question; run;
%mend organize;

%organize(formA,50);
%organize(formB,49);
%organize(formC,50);
%organize(formD,50);


data exam_report_sec_1; set formA_question formB_question formC_question formD_question;
title "Exam Report Section 1";
run;
Proc sort data=exam_report_sec_1 out=exam_report_sec_1;
By form q_number;
Run;

data exam_report_sec_2;
merge exam_report_sec_1(keep=percent) exam_report_sec_1(drop=percent);
title "Exam Report Section 2";
run;
proc sort data=exam_report_sec_2 out=exam_report_sec_2;
by descending percent;
run;

ods pdf file="/home/thephamnhat0/124/project 2/finaloutput.pdf";
proc print data=student_report_sec_1 noobs label split=" ";
label ovr_score='ovr score' ovr_percent="ovr perc" dom1_ovr="dom1 ovr" dom2_ovr="dom2 ovr" dom3_ovr="dom3 ovr" dom4_ovr="dom4 ovr" dom5_ovr="dom5 ovr" dom1_percent="dom1 perc" dom2_percent="dom2 perc" dom3_percent="dom3 perc" dom4_percent="dom4 perc" dom5_percent="dom5 perc";
title "Student Report Section 1";
run;
proc print data=student_report_sec_2 noobs label split=" ";
label ovr_score='ovr score' ovr_percent="ovr perc" dom1_ovr="dom1 ovr" dom2_ovr="dom2 ovr" dom3_ovr="dom3 ovr" dom4_ovr="dom4 ovr" dom5_ovr="dom5 ovr" dom1_percent="dom1 perc" dom2_percent="dom2 perc" dom3_percent="dom3 perc" dom4_percent="dom4 perc" dom5_percent="dom5 perc";
title "Student Report Section 2";
run;
title "Student Report Section 3";
proc boxplot data=boxplot_comp;
	plot dom_percent*dom;
run;
title "Student Report Section 4";
proc boxplot data=boxplot2;
	plot dom_percent*dom (form);
run;
proc print data=exam_report_sec_1;
title "Exam Report Section 1";
run;
proc print data=exam_report_sec_2;
title "Exam Report Section 2";
run;
title "Exam Report Section 3";
proc boxplot data=exam_report_sec_1;
plot percent*form;
run;
ods pdf close;


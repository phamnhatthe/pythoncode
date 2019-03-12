proc format library=work;
value $job 'Man'='Manager'
'SR1'='Sales Rep 1'
'SR2'='Sales Rep 2'
'Sec'='Secretary'
'Jan'= 'Janitor'
'Mec'='Mechanic';
run;

data employees;
infile "/home/thephamnhat0/124/homework2/hw2.txt";
input lname $ fname $ age job $ gender $;
run;

proc sort data=employees;
by job;
run;

options fmtsearch=(work);
proc print data=employees;
format job $job.;
run;

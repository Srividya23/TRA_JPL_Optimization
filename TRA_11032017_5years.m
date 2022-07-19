%% Proposal Title: Assessing cost-effectiveness of Joe Pool Reservoir conversion through an optimization framework
% Modified on: 11/02/2017 
% Include 5 year coding
% Includes changes in proposal - 10/31/207
% Includes Rjpl(x,t) from Water Impounded table

clear all;
close all;
clc;

%% ----Input to store number of Equations and Variables----
eq = 8;
vars_A = 7;
vars_xkwk = 21+21;

%% ----Prompt to get the years----
prompt = {'Enter the years in analysis (seperated by a space)'};
dlg_title = 'Input Years';
num_lines = [1 50];
defaultans = {'1949 1950 1951 1952 1953'};
out = inputdlg(prompt,dlg_title,num_lines,defaultans);
year_val = str2num(out{:});  %#ok<ST2NM>
years = size(year_val,2);
    
%% ---- Read Inputs from excel File ----
[fileName,PathName] = uigetfile({'*.*',  'All Files (*.*)'});
FullName = strcat(PathName,fileName);
[num,txt] = xlsread(FullName);
txt = txt(2:end,1);

%% ----Assigning values to variable names----
for j=1:length(num)
    assignin('base',char(txt(j)),num(j,:));
end

%----Creating Progress Bar----
h = waitbar(0,'Computation in Progress...');
steps = 10;
for step = 1:years

%% ---- Calling and initializing Matrix functions----
[A,Aeq,A_dim] = A_matrix();
f = f_matrix();
[b,beq] = b_matrix;
intcon = (size(A,2)-(vars_xkwk/2)+1:size(A,2));
lb = zeros(size(f));
ub = ub_matrix();

%% ----intlinprog function----
[x,fval,exitflag,output] = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub);

%% ----Writing to output file----
Dec_var = ["Output/Years";"x";"xd";"yjpl";"yn";"ys";"sn";"ss";"Rjpl"];
out = [];
vars = vars_A - 1;
for i = 1:years
   out(1,i) = x(1);
   out(2:vars_A,i)= x(2+vars*(i-1):vars*i+1);
end

for i = 1:years
    Rjpl(:,i) = x(A_dim+i);
end

out = cat(1,year_val,out);
out = cat(1,out,Rjpl);
dec_var1 = cat(2,Dec_var,out);

% Calculating objective value,costs
calc = ["Objective";"Profit/Loss";"Cost";"Total Revenue";"JPL Revenue";"Revenue_North";"Revenue_South"];
for i = 1:years
    calc1(1,i) = fval;
    calc1(2,i) = (-Cjpl(i)*out(2,i))+(rjpl(i)*out(4,i))+(rn(i)*out(5,i))+(rs(i)*out(6,i));
    calc1(3,i) = (Cjpl(i)*out(2,i));
    calc1(4,i) = (365*rjpl(i)*out(4,i))+(rn(i)*out(5,i))+(rs(i)*out(6,i));
    calc1(5,i) = (365*(rjpl(i)*out(4,i)));
    calc1(6,i) = (rn(i)*out(5,i));
    calc1(7,i) = (rs(i)*out(6,i));
end
calc2 = cat(2,calc,calc1);
excel_out = cat(1,dec_var1,calc2);

empty_out = strings([20,20]);
xlswrite('Output_TRA.xlsx',empty_out);
xlswrite('Output_TRA.xlsx',excel_out);

waitbar(step/steps);
end
close(h) 
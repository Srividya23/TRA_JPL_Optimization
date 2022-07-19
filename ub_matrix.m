function ub = ub_matrix()

% storing workspace variables inside function
intcon = evalin('base','intcon');
years = evalin('base','years');
vars_A = evalin('base','vars_A');

ub_A = Inf((vars_A*years)-4,1);
ub_Rjpl = Inf(years,1);

num1 = xlsread('JPL_Impoundment.xlsx');% Reading JPL Impoundment data
%ub_xk = num1(1,3:end)';
ub_xk = Inf(size(intcon,2),1);

ub_wk = ones(size(intcon,2),1);

ub = cat(1,ub_A,ub_Rjpl,ub_xk,ub_wk);

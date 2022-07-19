function f = f_matrix()

% storing workspace variables inside function
Cjpl = evalin('base','Cjpl');
rjpl = evalin('base','rjpl');
rn = evalin('base','rn');
rs = evalin('base','rs');
Cd = evalin('base','Cd');
years = evalin('base','years');
vars_xkwk = evalin('base','vars_xkwk');

%% ----Creating Basic f matrix for x,xd,yjpl,yn,ys,sn,ss----
for i = 1:years 
    f1 = [Cjpl(i) 0 -365*(rjpl(i)) -rn(i) -rs(i) Cd(i) Cd(i)];
    if i == 1
        f = f1;
    else
        f1(1,1) = 0;
        f = cat(2,f,f1(:,2:end));
    end
end

f_Rjpl_zero = zeros(1,years); % Adding zeros for Rjpl
f_xkwk_zero = zeros(1,vars_xkwk);% Adding zeros for xk and wk
f = cat(2,f,f_Rjpl_zero,f_xkwk_zero);
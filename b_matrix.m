function [b,beq] = b_matrix()

% storing workspace variables inside function
W = evalin('base','W');
V1 = evalin('base','V1');
Rllp = evalin('base','Rllp');
Dn = evalin('base','Dn');
Ds = evalin('base','Ds');
years = evalin('base','years');

%% ----Creating Basic b matrix (RHS) for inequality equations----
for i = 1:years
   if i == 1
       b1 = [W(i),V1(i),0,(0.70*V1(i)),(V1(i)+Rllp(i)),0,-Dn(i),-Ds(i)];
       b = b1;
   else
      b= cat(2,b,b1);
    end
end

% Adding zeros for xk and wk equations
for i = 1:years*2
    b_zero(1,i) = 0;
end

b = cat(2,b,b_zero);
    
%% ----Creating Basic b matrix (RHS) for equality equations----
beq_Rjpl = ones(1,years);
beq_piece = [0,1];
beq = cat(2,beq_Rjpl,beq_piece);

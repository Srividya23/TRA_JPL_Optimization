function [A,Aeq,A_dim] = A_matrix()

% storing workspace variables inside function
gamma = evalin('base','gamma');
beta = evalin('base','beta');
years = evalin('base','years');
year_val = evalin('base','year_val');

%% ---- Reading JPL Impoundment data---
num1 = xlsread('JPL_Impoundment.xlsx');

%% ----Creating Basic A matrix for x,xd,yjpl,yn,ys,sn,ss,Rjpl (inequality constraints)----
for i = 1:years
    A1 = [1 0 0 0 0 0 0        %2
          0 365 0 0 0 0 0       %3
         -1 gamma(i) 0 0 0 0 0 %4
          0 365 0 1 0 0 0       %5
          0 365 -(365*beta(i)) (1-beta(i)) 1 0 0 %6
          0 -365*(gamma(i)) 365 0 0 0 0 %7
          0 0 -365 -1 0 -1 0    %8
          0 0 0 0 -1 0 -1       %9
          ]; 
      if i ==1
          A = A1;
      else
          A = blkdiag(A,A1(:,2:end));
      end
end

for i = 1:years-1
    col1 = A1(:,1);
    A(size(A1,1)*i+1:size(A1,1)*i+size(col1,1),1) = col1;
end

A2 = A; % storing original A matrix for use
A_dim = size(A2,2);

%% ---- Adding Rjpl decision vars for eq 4 & 7 based on years----
for i = 1:years
    Rjpl_coeff = [0;0;1;0;0;-1;0;0];
    if i == 1
        Rjpl_matrix = Rjpl_coeff;
    else
        Rjpl_matrix = blkdiag(Rjpl_matrix,Rjpl_coeff);
    end
end

A = cat(2,A,Rjpl_matrix); % Adding Rjpl dec vars to A matrix

%% ---- calculating the xk and wk coefficient for all years and x---- 
 for k = 2:size(num1,1)
     for j = 3:size(num1,2)
         xk_coeff(k-1,j-1) = (num1(k,j)-num1(k,j-1))/(num1(1,j)-num1(1,j-1));
         xk_coeff(k-1,1) = num1(k,1);
         wk_coeff(k-1,j-1)  = (-1)* num1(1,j-1)* xk_coeff(k-1,j-1) + num1(k,j-1);
         wk_coeff(k-1,1) = num1(k,1);
     end
 end
 
%% ---- Combing xk, wk piece to add the piece wise linear constraint to A matrix----
xk_piece1 = -1*ones(years,size(xk_coeff,2)-1); % Adding piece wise linear constraint: -xk + w(k)u(k-1)<=0
xk_piece2 = 1*ones(years,size(xk_coeff,2)-1); % Adding piece wise linear constraint: xk - w(k)u(k-1)<=0
xk_piece3 = -1*ones(1,size(xk_coeff,2)-1); % Adding piece wise linear constraint: x - sum(xk) = 0

for i = 1:years
wk_piece1(i,:) = num1(1,2:size(num1,2)-1);% Adding piece wise linear constraint: -xk + w(k)u(k-1)<=0
wk_piece2(i,:) = -1*num1(1,3:size(num1,2));% Adding piece wise linear constraint: xk - w(k)u(k-1)<=0
end
wk_piece3 = ones(1,size(wk_coeff,2)-1); % Adding piece wise linear constraint: sum(wk) = 1

xkwk_piece1 = cat(2,xk_piece1,wk_piece1);
xkwk_piece2 = cat(2,xk_piece2,wk_piece2);
xkwk_piece = cat(1,xkwk_piece1,xkwk_piece2);

A = blkdiag(A,xkwk_piece); % Adding Piece wise linear inequality constraints to A matrix

 %% ---- Creating xk and wk coeff matrix----
for i = 1:years
    f_xk = find(xk_coeff(:,1) == year_val(i));
    xk_matrix(i,:) = xk_coeff(f_xk,2:end); 
    f_wk = find(wk_coeff(:,1) == year_val(i));
    wk_matrix(i,:) = wk_coeff(f_wk,2:end);
end

%% ----creating diagonal Rjpl matrix for equality constraint----
for i = i:years
    Rjpl_coeff = -1*ones(1,years);
    Rjpl_matrix = diag(Rjpl_coeff);
end

%% ---- Adding Rjpl, xk, wk matrices together----
xkwk_matrix = cat(2,Rjpl_matrix,xk_matrix,wk_matrix);

%% ---- Creating A matrix for equality constraints---- 
xkwk_piece3 = blkdiag(xk_piece3,wk_piece3);
xkwk_piece3_zero = zeros(size(xkwk_piece3,1),years);
xkwk_piece3 = cat(2,xkwk_piece3_zero,xkwk_piece3);

xkwk_final = cat(1,xkwk_matrix,xkwk_piece3); % Adding Rjpl equality and piece 3 equality together

Aeq_zero = zeros(size((xkwk_final),1),size(A2,2));
Aeq = cat(2,Aeq_zero,xkwk_final);
Aeq(end-1,1) = 1; % Adding x coefficient from piece wise linear constraint: x - sum(xk) = 0 
    
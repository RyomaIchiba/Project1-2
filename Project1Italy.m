
clc
clear all
close all

% load the data
startdate = '01/01/1995';
enddate = '01/01/2022';
f = fred
ITY = fetch(f,'CLVMNACSCAB1GQIT',startdate,enddate)
JPY = fetch(f,'JPNRGDPEXP',startdate,enddate)
ity = log(ITY.Data(:,2));
jpy = log(JPY.Data(:,2));
q = ITY.Data(:,1);



T = size(ity,1);

% Hodrick-Prescott filter
lam = 1600;
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

tauITGDP = A\ity;
tauJPGDP = A\jpy;

% detrended GDP
itytilde = ity-tauITGDP;
jpytilde = jpy-tauJPGDP;

% plot detrended GDP
dates = 1995:1/1:2019.1/1; zerovec = zeros(size(ity));
figure
title('Detrended log(real GDP for Italy) 1995-2019'); hold on
plot(q, itytilde,'b', q, jpytilde,'r',q, zerovec,'g')
datetick('x', 'yyyy')
legend({'Italy','Japan'},'Location','southwest')

% compute sd(y), sd(c), rho(y), rho(c), corr(y,c) (from detrended series)
itysd = std(itytilde)*100;
jpysd = std(jpytilde)*100;
corryc = corrcoef(itytilde(1:T),jpytilde(1:T)); corryc = corryc(1,2);

disp(['Percent standard deviation of detrended log real GDP for Italy: ', num2str(itysd),'.']); disp(' ')
disp(['Percent standard deviation of detrended log real GDP for Japan: ', num2str(jpysd),'.']); disp(' ')
disp(['Contemporaneous correlation between detrended log real GDP for Italy and Japan: ', num2str(corryc),'.']);




% This is the main file use to run each of the component of the design.
% Each Component's output is a structure array with the values required to
% fill the Excel sheet.

clc; clear; close all;

% The weight function takes in true/false argument for print figure and 
% printing the iterations.
Weight_est1 = weight_estimate(false,false);

% The cost function takes in arguments for Weight estimate and true/false 
% for printing the required values.
Cost_estimate = Cost_estimate(Weight_est1,false);

% The preliminary sizing function takes in the 1st weight estimate and
% outputs the Drag polars (true/false) and Constraints plots (true/false)
[prelim_size,constraints] = Prelim_sizing(Weight_est1,false,false);

% The second weight estimate function takes in 1st weight estimate and
% TW_WS structs and true/false argument for printing the iterations counts.
% It outputs the T-S plot for final prelim sizing.
[TS_size,estimate2] = prelim_TS(Weight_est1,prelim_size,constraints);
hold on
%%
E=struct('MTOW',get_weight(Weight_est1,prelim_size,1270,TS_size.S_design,38500,TS_size.T_design,true));

S = linspace(800,2500,1000);
T = linspace(0,750000,1000);
fuel = zeros(numel(S),numel(S));
for i=1:numel(S)
    for j=1:numel(S)
        fuel(i,j)=get_fuel_contours(prelim_size,S(i),T(j),TS_size.S_design,E.MTOW);
    end
end
%%
[X,Y]=meshgrid(S,T);
contour(X,Y,fuel,'--k','ShowText','on')

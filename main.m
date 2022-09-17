% This is the main file use to run each of the component of the design.
% Each Component's output is a structure array with the values required to
% fill the Excel sheet.

clc; clear; close all;
% The weight function takes in true/false argument for print figure and 
% printing the iterations.
Weight_est = weight_estimate(false,false);
% The cost function takes in arguments for Weight estimate and true/false 
% for printing the required values.
Cost_estimate = Cost_estimate(Weight_est,false);

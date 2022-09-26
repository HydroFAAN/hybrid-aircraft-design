clc; clear;

AR = 9; % Given Aspect ratio
CL = 1; % Assumed Cl

e = @(AR) 1/(1.05+0.007*pi*AR);     % Function for oswald's eficiency

CD = CL^2/(pi*AR*e(AR));            % Original induced drag

% Question C
CD2 = CL^2/(pi*AR*1.05*e(AR*1.05)); % CD with 5% increased AR

change = ((CD2-CD)/CD)*100;         % Percent change in the induced drag

% Question D
CL_new = CL/1.05;
CD3 = (CL_new)^2/(pi*AR*1.05*e(AR*1.05));  % CD with 5% increase in reference area and span

change2 = ((CD3-CD)/CD)*100;        % Percent Change in the induced drag

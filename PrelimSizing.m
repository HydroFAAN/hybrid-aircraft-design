clc;
clear;
close all;

CLc_max = linspace(-1.6,1.6,100); %CLmax clean config estimated from Roskam typical vals
CLt_max = linspace(-1.9,1.9,100);
CLl_max = linspace(-2.3,2.3,100);

MTOW = 146436; %make it able to get this val from other code
W_Load = 105; %lbs/ft^2

Swet = (10^0.0199)*(MTOW^0.7531); %in ft^2
Sref = (MTOW/W_Load); %in lbs/lbs/ft^2 = ft^2

CD0c = (0.0026)*(Swet/Sref); %cf is 0.0026 from fig 4.4 in metabook

e1 = 0.80; %oswald clean estimation at AR = 10.25
e2 = 0.75; %oswald with takeoff flap estimation from table 4.2
e3 = 0.70; %oswald with landing flaps // // // 

AR = 10.25; %assuming AR = 10.25

DelCD0_t = 0.015; %From table 4.2, for DeltaCD0 takeoff
DelCDO_l = 0.062; %for landing
DelCDO_g = 0.020; %For gear down

CDc = zeros(size(CLc_max));
CDt = zeros(size(CLc_max));
CDtg = zeros(size(CLc_max));
CDl = zeros(size(CLc_max));
CDlg = zeros(size(CLc_max));

CD0t = CD0c + DelCD0_t; %just with takeoff flaps, gear up
CD0tg = CD0c + DelCD0_t + DelCDO_g; %with takeoff flaps, gear down
CD0l = CD0c + DelCDO_l; %with landing flaps, gear up
CD0lg = CD0c + DelCDO_l + DelCDO_g; %with landing flaps and gear down


for i = 1:length(CLc_max)
    CDc(i) = CD0c + (1/(pi*e1*AR)).*((CLc_max(i).^2)); %For 
    CDt(i) = CD0t + (1/(pi*e2*AR)).*((CLt_max(i).^2));
    CDtg(i) = CD0tg + (1/(pi*e2*AR)).*((CLt_max(i).^2));
    CDl(i) = CD0l + (1/(pi*e3*AR)).*((CLl_max(i).^2));
    CDlg(i) = CD0lg + (1/(pi*e3*AR)).*((CLl_max(i).^2));
end


figure
hold on
title('Drag polars')
xlabel('C_D')
ylabel('C_L')
grid on
plot(CDc,CLc_max)
plot(CDt,CLt_max)
plot(CDtg,CLt_max)
plot(CDl,CLl_max)
plot(CDlg,CLl_max)
legend('Clean, cruise','Takoff flaps, gear up','Takeoff flaps, gear down','Landing flaps, gear up','Landing flaps, gear down')









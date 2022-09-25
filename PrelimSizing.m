clc;clear;close all;
%% Drag Polars
%CLmax configs estimated from Roskam typical vals
CLc = linspace(-1.6,1.6,1000);   % CLc_max = 1.6
CLt = linspace(-1.9,1.9,1000);   % CLt_max = 1.9
CLl = linspace(-2.3,2.3,1000);   % CLl_max = 2.3

MTOW = 146436;  %make it able to get this val from other code
W_Load = 105;   %lbs/ft^2

Swet = (10^0.0199)*(MTOW^0.7531);   %in ft^2
Sref = (MTOW/W_Load);               %in lbs/lbs/ft^2 = ft^2
Cf = 0.0026;                        %Friction coefficient from fig 4.4 in metabook
CD0c = (Cf)*(Swet/Sref);        

e1 = 0.80;  %oswald clean estimation at AR = 10.25
e2 = 0.75;  %oswald with takeoff flap estimation from table 4.2
e3 = 0.70;  %oswald with landing flaps  

AR = 10.25; %Aspect Ratio

% Function for calculating K value with 'e' as input for different phases of climb
K = @(e) 1/(pi*AR*e);   

% From table 4.2 in Metabook
DelCD0_t = 0.015; % for DeltaCD0 takeoff
DelCDO_l = 0.062; %for landing
DelCDO_g = 0.020; %For gear down

CD0t = CD0c + DelCD0_t;                 %just with takeoff flaps, gear up
CD0tg = CD0c + DelCD0_t + DelCDO_g;     %with takeoff flaps, gear down
CD0l = CD0c + DelCDO_l;                 %with landing flaps, gear up
CD0lg = CD0c + DelCDO_l + DelCDO_g;     %with landing flaps and gear down

% CD values for the drag polars 
CDc = CD0c + K(e1).*((CLc.^2));    % For Clean config
CDt = CD0t + K(e2).*((CLt.^2));    % For takeoff flaps, gear up       
CDtg = CD0tg + K(e2).*((CLt.^2));  % For takeoff flaps, gear down
CDl = CD0l + K(e3).*((CLl.^2));    % For landing flaps, gear up
CDlg = CD0lg + K(e3).*((CLl.^2));  % For landing flaps, gear down

% Tangent point
CL_tang = @(cd0,e) sqrt(cd0/K(e));
CDc_tang = 2*K(e1)*(CL_tang(CD0c,e1))^2;
CDt_tang = 2*K(e2)*(CL_tang(CD0t,e2))^2;
CDtg_tang = 2*K(e2)*(CL_tang(CD0tg,e2))^2;
CDl_tang = 2*K(e3)*(CL_tang(CD0l,e3))^2;
CDlg_tang = 2*K(e3)*(CL_tang(CD0lg,e3))^2;

% Max L/D ratios
LD_c = CL_tang(CD0c,e1)/CDc_tang;
LD_t = CL_tang(CD0t,e2)/CDt_tang;
LD_tg = CL_tang(CD0tg,e2)/CDtg_tang;
LD_l = CL_tang(CD0l,e3)/CDl_tang;
LD_lg = CL_tang(CD0lg,e3)/CDlg_tang;

% Plots figure
figure(1)
hold on
plot(CDc,CLc,'LineWidth',1.2)
plot(CDt,CLt,'LineWidth',1.2)
plot(CDtg,CLt,'LineWidth',1.2)
plot(CDl,CLl,'LineWidth',1.2)
plot(CDlg,CLl,'LineWidth',1.2)

% Tangent Lines
% plot([0,CDc_tang],[0,CL_tang(CD0c,e1)])
% plot([0,CDt_tang],[0,CL_tang(CD0t,e2)])
% plot([0,CDtg_tang],[0,CL_tang(CD0tg,e2)])
% plot([0,CDl_tang],[0,CL_tang(CD0l,e3)])
% plot([0,CDlg_tang],[0,CL_tang(CD0lg,e3)])

title('Drag polars')
xlabel('C_D')
ylabel('C_L')
grid on
legend('Clean, cruise','Takeoff flaps, gear up','Takeoff flaps, gear down',...
        'Landing flaps, gear up','Landing flaps, gear down',Location='eastoutside')

%% Sizing Equations

W_S = linspace(0,150,1000);
T_W = linspace(0,0.8,1000);

% Takeoff Chart
BFL = 6860;         % in ft. From reference [1]
rho_ratio = 0.95;   % Assuming hot day near sea level
TOP = BFL/37.5;     % From Roskam for FAR25 requirement for jet transport aircraft
T_W_takeoff = W_S/(rho_ratio*max(CLt)*TOP);

% Landing Chart
sland = BFL*0.6;
WL_Wto = 0.7;       % Average value taken from Roskam
sa = 1000;          % Number appropiate for airliners taken from Roskam
WL_S = (rho_ratio*max(CLl)/80)*(sland-sa);
Wto_S = WL_S/WL_Wto;

% Climb Chart
n_engines = 2;

% Function to calculate T/W for different climb phases
% Inputs: 
% ks - taken from metabook for FAR25 requirement compliance
% Cd0 - Calculated above for various climb phases
% G - taken from metabook for 2 engine config
% Clmax - max. value of CL for each climb phase
% e - oswald coefficient for various phases
TW_Climb = @(ks,Cd0,G,Clmax,e) (ks^2/Clmax)*Cd0 + (Clmax/ks^2)*K(e) + G;

% Final T/W ratios with thrust correction
TW_takeoff_climb = TW_Climb(1.2,CD0t,0.012,max(CLt),e2);
takeoff_correction = (1/0.8)*(n_engines/(n_engines-1));
TW_takeoff_climb = TW_takeoff_climb*takeoff_correction;

TW_transition_climb = TW_Climb(1.15,CD0tg,0,max(CLt),e2);
transition_correction = (1/0.8)*(n_engines/(n_engines-1));
TW_transition_climb = TW_transition_climb*transition_correction;

TW_2segment_climb = TW_Climb(1.2,CD0t,0.024,max(CLt),e2);
segment_correction = (1/0.8)*(n_engines/(n_engines-1));
TW_2segment_climb = TW_2segment_climb*segment_correction;

TW_enroute_climb = TW_Climb(1.25,CD0c,0.012,max(CLc),e1);
enroute_correction = (1/0.8)*(1/0.94)*(n_engines/(n_engines-1));
TW_enroute_climb = TW_enroute_climb*enroute_correction;

TW_AEObalked_climb = TW_Climb(1.3,CD0lg,0.032,max(CLl),e3);
AEObalked_correction = (1/0.8)*(WL_Wto);
TW_AEObalked_climb = TW_AEObalked_climb*AEObalked_correction;

TW_OEIbalked_climb = TW_Climb(1.5,(CD0lg+CD0tg)/2,0.021,0.85*max(CLl),e3);
OEIbalked_correction = (1/0.8)*(n_engines/(n_engines-1))*(WL_Wto);
TW_OEIbalked_climb = TW_OEIbalked_climb*OEIbalked_correction;

% Cruise Chart
Wcr_Wto = 0.990*0.990*0.995*0.980;      % Correction Ratio includes Start_warmup, Taxi, Takeoff and Climb
q = 232.43;                             % Calculated using online calculator, reference[2]
Tto = 32160;                            % lbs
rho_SL = 1.225; rho_cr = 0.364;         % kg/m^3 at Sea level and 36000ft cruise height
Tcr_Tto = ((rho_cr/rho_SL)^0.6);        % Taken from metabook eq 4.55
Tcr_Wcr = (q./W_S).*CD0c+(W_S./q).*K(e1);   
Tto_Wto = (Wcr_Wto/Tcr_Tto).*Tcr_Wcr;
Tto_Wto(1)=100;

% Ceiling Chart
G = 0.001;      % small climb gradient as a factor of safety
Tce_Wce = G + 2*sqrt(CD0c*K(e1));

% Creating a boundary for the Feasible region to shade
p=[];
p(1)=W_S(find(abs(Tto_Wto-TW_2segment_climb) < 0.001,1));
p(2)=W_S(find(abs(T_W_takeoff-TW_2segment_climb) < 0.001,1));
p(3)=Wto_S;

AA = zeros(1,length(W_S));
for i=1:length(W_S)
    if W_S(i)<=p(1)
        AA(i)=Tto_Wto(i);
    elseif W_S(i)>p(1)&&W_S(i)<=p(2)
        AA(i)=TW_2segment_climb;
    elseif W_S(i)>p(2)&&W_S(i)<=p(3)
        AA(i)=T_W_takeoff(i);
    else
        AA(i)=T_W(i);
    end
end

figure(2)
hold on
plot(W_S,T_W_takeoff,'r','LineWidth',1.2)           % Takeoff plot
text(30,0.09,'Takeoff Field Length','Color','r')
xline(Wto_S,'g','LineWidth',1.2)                    % Landing plot
text(Wto_S+2,0.35,'Landing Field Length','Color','g')
yline(TW_takeoff_climb,'c','LineWidth',1.1)         % takeoff_climb
text(Wto_S+1,TW_takeoff_climb-0.006,'Takeoff Climb','Color','c')
yline(TW_transition_climb,'m','LineWidth',1.1)      % transition_climb
text(Wto_S+1,TW_transition_climb-0.006,'Transition Climb','Color','m')
yline(TW_2segment_climb,'y','LineWidth',1.1)        % second segment_climb
text(Wto_S+1,TW_2segment_climb+0.008,'Second segment Climb','Color','y')
yline(TW_enroute_climb,'y','LineWidth',1.1)         % enroute_climb
text(Wto_S+1,TW_enroute_climb-0.006,'Enroute Climb','Color','y')
yline(TW_AEObalked_climb,'r','LineWidth',1.1)       % AEObalked_climb
text(Wto_S+1,TW_AEObalked_climb-0.006,'AEO balked Climb','Color','r')
yline(TW_OEIbalked_climb,'k','LineWidth',1.1)       % OEIbalked_climb
text(Wto_S+1,TW_OEIbalked_climb-0.006,'OEI balked Climb','Color','k')
plot(W_S,Tto_Wto,'b','LineWidth',1.2)               % Cruise plot
text(10,0.4,'Cruise','Color','b')
yline(Tce_Wce,'k','LineWidth',1.1)                  % Ceiling plot
text(Wto_S+1,Tce_Wce-0.006,'Ceiling','Color','k')
ylim([0,0.5])
patch([W_S fliplr(W_S)], [AA max(ylim)*ones(size(AA))], 'r','EdgeColor','none')    % Feasible region shade
alpha(0.5)  % Transperancy of the shaded region
text(60,0.4,'Feasible Region')
plot(84,0.27,'.k')
text(75,0.28,'Selected T/W and W/S')
xlabel('W/S (lb/ft^2)','FontSize',15)
ylabel('T/W','FontSize',15)
grid on


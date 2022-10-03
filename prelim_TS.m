function [values,estimate] = prelim_TS(Weight_est1,prelim_size,constraints)
    [T_takeoff,estimate.MTOW(1),estimate.Fuel_weight(1)] = thrust_estimate(Weight_est1,prelim_size,constraints.TW_takeoff,false,true);

    [T_cruise,estimate.MTOW(2),estimate.Fuel_weight(2)] = thrust_estimate(Weight_est1,prelim_size,constraints.Cruise,false,true);

    [T_takeoff_climb,estimate.MTOW(3),estimate.Fuel_weight(3)] = thrust_estimate(Weight_est1,prelim_size,constraints.takeoff_climb,false,false);

    [T_transition_segment,estimate.MTOW(4),estimate.Fuel_weight(4)] = thrust_estimate(Weight_est1,prelim_size,constraints.transition_segment,false,false);

    [T_second_segment,estimate.MTOW(5),estimate.Fuel_weight(5)] = thrust_estimate(Weight_est1,prelim_size,constraints.second_segment,false,false);

    [T_enroute_climb,estimate.MTOW(6),estimate.Fuel_weight(6)] = thrust_estimate(Weight_est1,prelim_size,constraints.enroute_climb,false,false);

    [T_AEO_balked,estimate.MTOW(7),estimate.Fuel_weight(7)] = thrust_estimate(Weight_est1,prelim_size,constraints.AEO_balked,false,false);

    [T_OEI_balked,estimate.MTOW(8),estimate.Fuel_weight(8)] = thrust_estimate(Weight_est1,prelim_size,constraints.OEI_balked,false,false);

    [T_Ceiling,estimate.MTOW(9),estimate.Fuel_weight(9)] = thrust_estimate(Weight_est1,prelim_size,constraints.Ceiling,false,false);

    [S_landing,estimate.MTOW(10),estimate.Fuel_weight(10)] = Sref_estimate(Weight_est1,prelim_size,constraints.landing,false);


    WS = linspace(800,2500,1000);
    TW = linspace(0,75000,1000);


    % Creating a boundary for the Feasible region to shade

    intersect = find_common(T_takeoff,T_second_segment);

    AA = zeros(1,length(WS));
    for i=1:length(WS)
        if WS(i)<=WS(intersect)
            AA(i)=T_takeoff(i);
        else
            AA(i)=T_second_segment(i);
        end
    end
    
    figure()
    S_new = 1270;   % New Sref Design Point
    T_new = 38500;  % New Thrust Design Point
    hold on
    plot(WS,T_takeoff,'r','LineWidth',1.2)              % Takeoff field
    text(950,45000,'Takeoff Field Length','Color','r')
    
    plot(WS,T_cruise,'b','LineWidth',1.2)               % Cruise
    text(950,T_cruise(90)-700,'Cruise','Color','b')
       
    plot(WS,T_takeoff_climb,'c','LineWidth',1.1)        % Takeoff climb
    text(950,T_takeoff_climb(90)-700,'Takeoff Climb','Color','c')
    
    plot(WS,T_transition_segment,'m','LineWidth',1.1)   % Transition Climb
    text(950,T_transition_segment(90)-700,'Transition Climb','Color','m')
    
    plot(WS,T_second_segment,'b','LineWidth',1.1)       % 2nd Segment Climb
    text(950,T_second_segment(90)+700,'Second segment Climb','Color','b')
    
    plot(WS,T_enroute_climb,'g','LineWidth',1.1)        % Enroute Climb
    text(950,T_enroute_climb(90)-700,'Enroute Climb','Color','g')
    
    plot(WS,T_AEO_balked,'r','LineWidth',1.1)           % AEO Balked Climb
    text(950,T_AEO_balked(90)-700,'AEO balked Climb','Color','r')
    
    plot(WS,T_OEI_balked,'k','LineWidth',1.1)           % OEI Balked Climb
    text(950,T_OEI_balked(90)-700,'OEI balked Climb','Color','k')
    
    plot(WS,T_Ceiling,'k','LineWidth',1.1)              % Ceiling
    text(950,T_Ceiling(90)-700,'Ceiling','Color','k')
    
    plot(S_landing,TW,'g','LineWidth',1.2)              % Landing field
    text(850,48000,'Landing Field Length','Color','g')
    
    ylim([0,58000])
    xlim([800,2000])
    
    patch([WS fliplr(WS)], [AA 750000*ones(size(AA))], 'r','EdgeColor','none')    % Feasible region shade
    alpha(0.5)          % Transperancy of the shaded region
    text(1600,45000,'Feasible Region','FontSize',15)
    
    plot(S_new,T_new,'.k')  % The selected values for T/W and W/S.
    text(S_new-40,T_new+1500,'Selected Thrust = 38500 lbs and Sref = 1270 ft^2')

    xlabel('S (ft^2)','FontSize',15)
    ylabel('T (lb)','FontSize',15)
    
    values = struct('Takeoff',T_takeoff,'Cruise',T_cruise,'Takeoff_climb',T_takeoff_climb,...
                    'Transition_segment',T_transition_segment,'Second_segment',T_second_segment,...
                    'Enroute_climb',T_enroute_climb,'AEO_balked',T_AEO_balked,'OEI_balked',...
                    T_OEI_balked,'Ceiling',T_Ceiling,'Landing',S_landing,'T_design',T_new,'S_design',S_new);
end

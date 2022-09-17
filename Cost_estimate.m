function C_estimate = Cost_estimate(estimate,print)
    b_year = 1989;
    t_year = 2022;
    b_CEF = 5.17053 + 0.104981 * (b_year-2006);
    t_CEF = 5.17053 + 0.104981 * (t_year-2006);
    CEF = t_CEF/b_CEF;

    % Using Equation for Commercial jet transport
    C_aircraft = 10^(3.3191+0.8043*log10(estimate.MTOW))*CEF;

    % Using Equation for jet engines
    C_engines = 10^(2.3044+0.8858*log10(estimate.MTOW))*CEF;

    C_airframe = C_aircraft-C_engines;

    % Using Equations for Domestic flights
    tb = 7;

    n_attd = 4;
    C_crew = (440 + 0.532*(estimate.MTOW/1000))*CEF*tb;
    C_attd = 60*n_attd*CEF*tb;

    Pf = 16;
    rho_f = 0.59;
    C_fuel = 1.02*estimate.Fuel_weight*(Pf/rho_f);

    Oil_weight = 0.0125*estimate.Fuel_weight*(tb/100);
    Po = 27;
    rho_o = 8.2;
    C_oil = 1.02*Oil_weight*(Po/rho_o);

    C_airport = 1.5*(estimate.MTOW/1000)*CEF;

    range = 3400;
    C_navigation = 0.5*CEF*(1.852*range/tb)*sqrt(0.00045359237*estimate.MTOW/50);

    Engine_weight = 6775;
    Airframe_weight = estimate.Empty_weight-Engine_weight;
    Rl = 7;
    C_ML = 1.03*(3+(0.067*Airframe_weight)/1000)*Rl;    % Labor Cost airframe
    C_MM = 1.03*(30*CEF)+0.79*1e-5*C_airframe;          % Material Cost airframe
    C_airframe_maintenance = (C_ML + C_MM)*tb;

    T0 = 32160;
    n_engine = 2;
    C_ML_engine = (0.645+(0.05*T0/1e4))*(0.566+0.434/tb)*Rl;  % Labor cost engine
    C_MM_engine = (25+(18*T0/1e4))*(0.62+0.38/tb)*Rl;         % Material cost engine
    C_engine_maintenance = n_engine*(C_ML_engine + C_MM_engine)*tb;

    C_estimate = struct('C_crew',C_crew,'C_attd',C_attd,'C_fuel',C_fuel,...
                        'C_oil',C_oil,'C_airport',C_airport,'C_navigation'...
                        ,C_navigation,'C_airframe_maintenance',C_airframe_maintenance...
                        ,'C_engine_maintenance',C_engine_maintenance);

    if print==true
        disp(['crew - ',num2str(C_crew),' | attendants - ',num2str(C_attd),' | Fuel - ',num2str(C_fuel)])
        disp(['Oil - ',num2str(C_oil),' | Airport - ',num2str(C_airport),' | Navigation - ',num2str(C_navigation)])
        disp(['Airframe_maintenance - ',num2str(C_airframe_maintenance),' | Engine_maintenance - ',num2str(C_engine_maintenance)])
    end
end
function fr = get_fr(CD0,thrust,mtow,prelim_size)
    
    % Important constants
    range = 3270;   %nmi
    c = 0.6;        % Specific Fuel Consumption
    velocity = 520; % knots
    
    % Historical Ratios taken from Roksham's table for jet transport
    
    start_warmup = 1-((c*(15/60))*(0.05.*thrust)/mtow);
    
    w1 = start_warmup*mtow;
    Taxi = 1-(c*(1/60))*(thrust/w1);
    
    Takeoff = 0.995;    % Historical
    
    e = prelim_size.e;
    K = prelim_size.K(e(1));
    Cl = sqrt(CD0/K);
    L_D = (0.94*Cl)/(CD0+(K)*Cl^2);
    Cruise = exp(-(range*c)/(velocity*L_D)); % From Berguet range formula
    
    Climb = 0.980;              % Historical
    Descent = 0.99;             % Historical
    Landing = 0.992;            % Historical

    % Reserve = exp(-(range2*c2)/(velocity2*L_D2));

    % Multiplied 1.06 to take into account the reserve mission and trapped
    % fuel
    fr = (1-(start_warmup.*Taxi.*Takeoff.*Climb.*Cruise.*Descent.*Landing)).*1.06; 
end
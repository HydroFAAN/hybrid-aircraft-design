function W_estimate = weight_estimate(fig,print)
    %% Data Processing
    % MTOW and Empty weight from the datasheet
    M1 = 170000;    E1 = 93500;
    M2 = 41000;     E2 = 30000;
    M3 = 141400;    E3 = 96000;
    M4 = 220000;    E4 = 111800;
    M5 = 174165;    E5 = 97700;

    MTOW = [M1,M2,M3,M4,M5];
    Empty = [E1,E2,E3,E4,E5];

    % Creating the linear regression using least squares method
    % log10(MTOW) = A + B*log10(Empty_ratio)
    M = zeros(length(MTOW),2);
    R = zeros(length(MTOW),1);

    M(1:end,1)=1;
    M(1:end,2)=log10(Empty);

    R(1:end,1)=log10(MTOW);

    A=((M'*M)\M')*R;

    x = linspace(10^4,3*10^5,100);
    % Regression equation to find the MTOW
    % reg_TO = @(val)10.^(A(1)+A(2)*log10(val)); % takes in empty weight gives MTOW
    reg_E = @(val)10.^((log10(val)-A(1))/A(2)); % takes in MTOW gives empty weight
    y = reg_E(x);
    if fig==true
        scatter(MTOW,Empty,30,'filled')
        set(gca,'xscale','log','yscale','log')
        hold on 
        loglog(x,y,linewidth=1.2)
        xlabel('MTOW',FontSize=13)
        ylabel('Empty Weight',FontSize=13)
        legend('Historical Data','Regression Line')
        grid on
    end

    %% Fixed point iteration method for finding the MTOW with Jet Fuel
    pax=150;
    crew=6;
    pax_w=180;
    cargo=60;
    W_pax=pax*(pax_w+cargo);
    W_crew=crew*(pax_w+cargo);
    % Function takes in range(nmi), c, Velocity(knots) and L/D in that order
    fuel_ratio = ratio(3270,0.6,520,17); 
    % W0 equation from the metabook, takes emppty weight ratio as an input
    MTOW = @(empty_ratio) (W_pax+W_crew)/(1-fuel_ratio-empty_ratio); 

    % Initial guess and convergence error bound
    W0 = 190000;
    eps = 1e-6;
    del = 2*eps;
    i=0;
    if print==true
        disp(['Iterations',' | ','    MTOW   ',' | ','Empty Weight',' | ',' We/W0 ',' | ',' Wf/W0'])
        disp('----------------------------------------------------------------')
    end
    while del>eps
        e_w = reg_E(W0);    % Empty weight from guess using regression
        er = e_w/W0;        % We/W0
        W0_new = MTOW(er);  
        del = abs(W0_new-W0)/abs(W0_new);
        W0 = W0_new;
        i=i+1;
        if print==true
            disp(['    ',num2str(i),'     ',' | ',num2str(W0),' | ',num2str(e_w),'  | ',num2str(er),' | ',num2str(fuel_ratio)])
        end
    end

    %% MTOW with Hydrogen Estimate
    %Changed eqution to incorporate the fuel weight ratio as well 
    MTOW2 = @(empty_ratio,fr) (W_pax+W_crew)/(1-fr-empty_ratio);    
    W02 = W0;                               % MTOW as derived by the iteration with Jet fuel
    fuel2 = jet_to_lh2(W0,fuel_ratio);      % Weight of LH2 with comparable energy as jet fuel
    eps = 1e-6;
    del = 2*eps;
    if print==true
        disp(['Iterations',' | ','    MTOW   ',' | ','Empty Weight',' | ',' We/W0 ',' | ',' Wf/W0'])
        disp('----------------------------------------------------------------')
    end
    while del>eps
        e_w = reg_E(W02)*1.04;    % Empty weight from guess using regression (+4% for cryogenic storage of LH2) )
        er = e_w/W02;             % We/W0
        fr = fuel2/W02;           % Wf/W0
        W0_new = MTOW2(er,fr);
        del = abs(W0_new-W02)/abs(W0_new);
        W02 = (0.7*W0_new+0.3*W02);
        i=i+1;
        if print==true
            disp(['    ',num2str(i),'     ',' | ',num2str(W02),' | ',num2str(e_w),'  | ',num2str(er),' | ',num2str(fr)])
        end
    end
    
    W_estimate = struct('MTOW',W02,'Fuel_weight',fuel2,'Empty_weight',e_w,...
                        'pax_weight',W_pax,'crew_weight',W_crew);
    if print==true
        disp(['MTOW - ',num2str(W02),' || Empty Weight - ',num2str(e_w),' || Fuel Weight - ',num2str(fuel2)])
    end
    function fr = ratio(range,c,velocity,L_D)
        % Ratios taken from Roksham's table for jet transport
        start_warmup = 0.990;
        Taxi = 0.990;
        Takeoff = 0.995;
        Climb = 0.980;
        Descent = 0.99;
        Landing = 0.992;

        Cruise = exp(-(range*c)/(velocity*L_D)); % From Berguet range formula
    %     Reserve = exp(-(range2*c2)/(velocity2*L_D2));

        % Multiplied 1.06 to take into account the reserve mission and trapped
        % fuel
        fr = (1-(start_warmup*Taxi*Takeoff*Climb*Cruise*Descent*Landing))*1.06; 
    end

    function lh2_fuel_lb = jet_to_lh2(W0,fuel_ratio)
        % Values taken from references [1][2][3]
        rho_jet = 805;      rho_lh2 = 71;      % units - kg/m3
        energy_jet = 36.9;    energy_lh2 = 9;    % units - MJ/l
        jet_fuel_lb = W0*fuel_ratio;
        jet_fuel_l = ((jet_fuel_lb/2.204)/rho_jet)*1e3;
        total_energy_jet = jet_fuel_l*energy_jet;
        lh2_fuel_l =  total_energy_jet/energy_lh2;
        lh2_fuel_lb = lh2_fuel_l*1e-3*rho_lh2*2.204;
    end
end


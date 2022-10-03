function [W,fuel_r] = get_weight(estimate1,prelim_size,S,S_design,T,T_design,print)

    % Regression equation to find the empty weight
    reg_E = estimate1.Regression;
    
    % W0 equation from the metabook, takes emppty weight ratio  and fuel
    % ratio as inputs
    MTOW_e = estimate1.MTOW_Eq;
    
    % Equation to calculate the CD0 as a function of Sref
    Swet_rest = prelim_size.Swet-S_design;
    CD0 = @(Sref) prelim_size.Cf*(Swet_rest+2*Sref)/Sref;
    
    % Important constants
    wing_den = 10;          % lb/ft^2
    W0 = estimate1.MTOW;
    eps = 1e-6;
    del = 2*eps;
    i=0;
    
    while del>eps
        e_w = reg_E(W0);                                % Empty weight from guess using regression        
        e_w = e_w + wing_den.*(S-S_design);             % Modify empty weight as a function of Sref
        e_w = e_w + (engine_W(T)-engine_W(T_design));   % Modify empty weight as a function of Thrust
        er = e_w/W0;                                    % We/W0
        fuel_ratio = get_fr(CD0(S),T,W0,prelim_size); % Get the fuel ratio as a function of Sref
        W0_new = MTOW_e(er,fuel_ratio);                 % New MTOW
        del = abs(W0_new-W0)/abs(W0_new);               
        W0 = (0.7*W0_new+0.3*W0);
        i=i+1;
    end
    
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
        er = e_w/W02;             % Update We/W0
        fr = fuel2/W02;           % Update Wf/W0
        W0_new = MTOW_e(er,fr);
        del = abs(W0_new-W02)/abs(W0_new);
        W02 = (0.7*W0_new+0.3*W02);
        i=i+1;
        if print==true
            disp(['    ',num2str(i),'     ',' | ',num2str(W02),' | ',num2str(e_w),'  | ',num2str(er),' | ',num2str(fr)])
        end
    end
    
    W = W02;
    fuel_r = fr;
    
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
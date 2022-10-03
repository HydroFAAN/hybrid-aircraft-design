function fuel = get_fuel_contours(prelim_size,S,T,S_design,mtow)

    % Equation to calculate the CD0 as a function of Sref
    Swet_rest = prelim_size.Swet-S_design;
    CD0 = @(Sref) prelim_size.Cf*(Swet_rest+2*Sref)/Sref;
    
    fr = get_fr(CD0(S),T,mtow,prelim_size);
    
    fuel = jet_to_lh2(mtow,fr);
    
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
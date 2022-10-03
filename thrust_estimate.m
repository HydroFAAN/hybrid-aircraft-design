function [T_estimate,W_new,fuel] = thrust_estimate(estimate1,prelim_size,constraint,print,eq)
    S = linspace(800,2500,1000);
    T = zeros(size(S));
    
    % Initial guesses
    W0 = estimate1.MTOW;
    TW_design = prelim_size.TW_design;
    WS_design = prelim_size.WS_design;
    T_design = TW_design*W0;
    S_design = W0/WS_design;
    
    for i=1:length(S)
        S0 = S(i);
        T(i) = T_design;        % Design point guess
        tol = 0.1;
        converged = false;
        j=0;
        while converged == false
             [W,fr] = get_weight(estimate1,prelim_size,S0,S_design,T(i),T_design,print);
             wing_loading = W/S0;
             if eq == true
                TW_new = constraint(wing_loading);
             else
                TW_new = constraint;
             end
             T_new = TW_new*W;
             if abs(T_new-T(i)) <= tol
                 converged = true;
             end
             T(i) = 0.5*T_new+T(i)*0.5;
             if print==true
                disp([num2str(j),' | ',num2str(W),' | ',num2str(wing_loading),' | ',num2str(T(i))])
             end    
        end
    end
    
    T_estimate = T;
    W_new = W;
    fuel = fr*W_new;
end


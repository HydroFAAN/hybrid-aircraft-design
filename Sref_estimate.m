function [S_estimate,W_new,fuel] = Sref_estimate(estimate1,prelim_size,constraint,print)
    T = linspace(0,75000,1000);
    S = zeros(size(T));
    
    % Initial guesses
    W0 = estimate1.MTOW;
    TW_design = prelim_size.TW_design;
    WS_design = prelim_size.WS_design;
    T_design = TW_design*W0;
    S_design = W0/WS_design;
    
    for i=1:length(T)
        T0 = T(i);
        S(i) = S_design;        % Design point guess
        tol = 0.1;
        converged = false;
        j=0;
        while converged == false
             [W,fr] = get_weight(estimate1,prelim_size,S(i),S_design,T0,T_design,print);
             TW = T0/W;
             WS_new = constraint;
             S_new = W/WS_new;
             if abs(S_new-S(i)) <= tol
                 converged = true;
             end
             S(i) = 0.5*S_new+S(i)*0.5;
             if print==true
                disp([num2str(j),' | ',num2str(W),' | ',num2str(TW),' | ',num2str(S(i))])
             end    
        end
    end
    
    S_estimate = S;
    W_new = W;
    fuel = fr*W_new;
end


function engine_weight = engine_W(thrust)
    W_dry = 0.521.*(thrust).^(0.9);
    W_oil = 0.082.*(thrust).^(0.65);
    W_rev = 0.034.*(thrust).^(1);
    W_con = 0.26.*(thrust).^(0.5);
    W_start = 9.33.*(W_dry./1000).^(1.078);

    engine_weight = W_dry+W_oil+W_rev+W_con+W_start;
end
    
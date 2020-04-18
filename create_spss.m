for rotation = 1:1:6
    for plunge_draw = 1:2
        if species == 1
            Gl_data
        end
        for pot = 1:1:6
            Emergence(rotation,plunge_draw,pot) = Gl_Emer(pot);
            heads = Gl_hds(pot);
            head_count(rotation,plunge_draw,pot) = heads;
            plants(rotation,plunge_draw,pot) = Gl_surv(pot);
            counts = Gl_count(pot,:);
            counts(isnan(counts)==1) = [];
            if heads == 0
                 seeds_med(rotation,plunge_draw,pot) = 0;   %#ok<*SAGROW>
            elseif isempty(counts) ~= 1
                seeds = zeros(1,10000);
                for run = 1:1:10000
                    numbers = randi(length(counts),1,heads);
                    if numbers > 0
                        for i = 1:1:length(numbers)
                            seed_tmp = counts(numbers(i));
                            if isnan(seed_tmp) ~= 1
                                seeds(run) = seeds(run) + seed_tmp;
                            end
                        end
                    end
                end
                seeds_med(rotation,plunge_draw,pot) = median(seeds); 
            else % there are heads but no counts
                seeds_med(rotation,plunge_draw,pot) = nan; 
            end
        end
    end
save('Gl_sps', 'seeds_med', 'Emergence','head_count','plants')
end
% code for calculating the growth rate of 4 arable under different
% rotations as well as their risk of dropping below a population size
% tresshold.

clear all
clc


% rotations:
% 1: Spring beans + before spring plough
% 2: Spring Barley + before spring plough
% 3: Winter wheat + before winter plough
% 4: Winter OSR + before winter plough
% 5: Fallow + no_plough
% 6: Ryegrass-clover ley + no plough
% max rotation sequence is 6 years


% Data
Anthemis_SB = 0.934; %% following exponential regression on Salzmann 1954: Untersuchungen ueber die Lebensdauer von Unkrautsamen im Boden
Centaurea_SB = 0.463; % following mixed exponential regression of Barralis, G.; Chadoeuf, R.; Lonchamp, J.P. (1988); Weed. Res. 28: 407-418 & Kjaer, A. (1940); Proc. Int. Seed test. Assoc. 12:167-190; Klaer, A. (1948); Proc. Int. Seed test. Assoc. 14: 19-26
Glebionis_SB = 0.647; %following exponential regression on Kjaer, A. (1940); Proc. Int. Seed test. Assoc. 12:167-190 & Klaer, A. (1948); Proc. Int. Seed test. Assoc. 14: 19-26 (see excel file)
Scandix_SB = 0.182; %% !following a 3 point exponential regression on Brenchley, W.E.; Warington, K. (1933); J. Ecol. 18: 103-127 (see excel file)

% !!!!! In need of data!!!
winter_plough = 0.085;% OSR following Gruber et al 2005 & Hooftman et al. 2015
spring_plough = 0.02;% OSR following Gruber et al 2005 & Hooftman et al. 2015
no_plough = 0.02; % need data

seeds_planted_a = 250/ ((100*100)/(pi*20^2));
seeds_planted_b = 100/ ((100*100)/(pi*20^2));
seeds_planted_a_m2 = 250;
seeds_planted_b_m2 = 100;
number_of_years = 250;
run_max = 50000;
max_emerg = 500;
max_number_of_years_show = 50;

type_min = 201;
type_max = 234;
sp_min = 1;
sp_max = 4;
species_to_do = (sp_max-sp_min)+1;
types = (type_max - type_min) +1;


save('start_up');

job = createJob('configuration', 'Three');
for species = sp_min:1:sp_max
    display(species)
    for rotation_type = type_min:1:type_max  
        display(rotation_type)
       % arable_weed_calc(rotation_type,species)
        createTask(job, @arable_weed_calc_randi_rot, 1, {rotation_type,species});  
    end % rotation type
end % species

display ('Running paralel jobs now')

submit(job);
waitForState(job, 'finished');
results = getAllOutputArguments(job);
destroy(job)
       
flowerheads_md =  zeros(max_number_of_years_show,(types*species_to_do));
flowerheads_avg = zeros(max_number_of_years_show,(types*species_to_do));
flowerheads_005 = zeros(max_number_of_years_show,(types*species_to_do));
flowerheads_095 = zeros(max_number_of_years_show,(types*species_to_do));
total_growth_avg_all = zeros(250,(types*species_to_do));
total_growth_md_all =  zeros(250,(types*species_to_do));
total_growth_005_all = zeros(250,(types*species_to_do));
total_growth_095_all =  zeros(250,(types*species_to_do));
total_growth_010_all = zeros(250,(types*species_to_do));
total_growth_090_all =  zeros(250,(types*species_to_do));
total_growth_025_all =  zeros(250,(types*species_to_do));
total_growth_075_all = zeros(250,(types*species_to_do));
total_growth_040_all = zeros(250,(types*species_to_do));
total_growth_060_all =  zeros(250,(types*species_to_do));

spec_rot = 0;
for species = sp_min:1:sp_max
    rotations = 0;
    for rotation_type = type_min:1:type_max
        spec_rot = spec_rot + 1;
        rotations= rotations + 1;
        name_file= ['overview','_',int2str(species),'_',int2str(rotation_type),'.mat'];
        load(name_file)
        array_all(spec_rot,:) = array;  %#ok<SAGROW>      
        flowerheads_md(:,spec_rot) =  flowerheads_all_md(1:50); 
        flowerheads_avg(:,spec_rot) = flowerheads_all_avg(1:50); 
        flowerheads_005(:,spec_rot) = flowerheads_all_005(1:50); 
        flowerheads_095(:,spec_rot) = flowerheads_all_095(1:50); 
        total_growth_avg_all(:,spec_rot) =  total_growth_avg(1:250);
        total_growth_md_all(:,spec_rot) =  total_growth_med(1:250);
        total_growth_005_all(:,spec_rot) =  total_growth_005(1:250);
        total_growth_095_all(:,spec_rot) =  total_growth_095(1:250);
        total_growth_010_all(:,spec_rot) =  total_growth_010(1:250);
        total_growth_090_all(:,spec_rot) =  total_growth_090(1:250);
        total_growth_025_all(:,spec_rot) =  total_growth_025(1:250);
        total_growth_075_all(:,spec_rot) =  total_growth_075(1:250);
        total_growth_040_all(:,spec_rot) =  total_growth_040(1:250);
        total_growth_060_all(:,spec_rot) =  total_growth_060(1:250);
       
        if species == sp_max
            time_test = 50;
            if rotation_type > 200
                time_test = fallow_return*5;
                if time_test < 50
                    time_test = 50;
                end
                if time_test > 250
                    time_test = 250;
                end
            end
            
            som = total_growth_md_all(time_test,rotations) + total_growth_md_all(time_test,(types + rotations)) +...
                total_growth_md_all(time_test,((2*types) + rotations)) + total_growth_md_all(time_test,spec_rot);
            
            prop_gleb = (total_growth_md_all(time_test,rotations))/som;
            prop_scan = (total_growth_md_all(time_test,(types + rotations)))/som;
            prop_cent = (total_growth_md_all(time_test,((2*types) + rotations)))/som;
            prop_anth = (total_growth_md_all(time_test,spec_rot))/som;
            
            shannon(rotations) = -1 * ((prop_gleb * log(prop_gleb)) + (prop_scan * log(prop_scan)) + ...
                (prop_cent * log(prop_cent)) +  (prop_anth * log(prop_anth)));             %#ok<SAGROW>
        end
    end
end
for i = 1:1:types
    composite = 0;
    for x = 0:types:(types*(species_to_do-1))
    composite = composite + ((1-(array_all((i+x),9)))*(array_all((i+x),12)));
    end
    array_all(i:types:(types*(species_to_do)),26) = composite;
end

for species = sp_min:1:sp_max
    for rotation_type = type_min:1:type_max
        name_file= ['overview','_',int2str(species),'_',int2str(rotation_type),'.mat'];
        delete(name_file);
    end
end

h = clock;
name_file= ['results','_',date,'_',int2str(h(4)),'_',int2str(h(5))];
save(name_file)
function [output] = arable_weed_calc_randi_rot(rotation_type,species)
load('start_up.mat');
tic
% design rotations
if species == 1
    load('Gl_sps.mat')
    seed_bank = Glebionis_SB;
    seeds_planted = seeds_planted_a;
    seeds_planted_m2 = seeds_planted_a_m2;
elseif species == 2
    load('Sc_sps.mat')
    seed_bank = Scandix_SB;
    seeds_planted = seeds_planted_a;
    seeds_planted_m2 = seeds_planted_a_m2;
elseif species == 3
    load('Ce_sps.mat')
    seed_bank = Centaurea_SB;
    seeds_planted = seeds_planted_b;
    seeds_planted_m2 = seeds_planted_b_m2;
elseif species == 4
    load('An_sps.mat')
    seed_bank = Anthemis_SB;
    seeds_planted = seeds_planted_a;
    seeds_planted_m2 = seeds_planted_a_m2;
end

Emergence
median_emergence_rate = median(median(Emergence))/seeds_planted;
extinction_tres =  (median_emergence_rate/seeds_planted_m2)/median_emergence_rate; % discuss which tresshold, this one is the amount of seeds to have on average 1 plant per pot.

% initiate runs
extinction_risk_25 = zeros(1,run_max);
extinction_risk_10 = zeros(1,run_max);
extinction_time =  zeros(1,run_max);
time_to_fulness = zeros(1,run_max);
rotation_lambda = zeros(1,run_max);
barley_perc_run = zeros(1,run_max);

for run = 1:1:run_max
    % rotation rules;
    [rotation_run,number_of_years,fallow_return,ley_return,end_fallows,end_leys,barley_perc,break_perc] = rotation_rules(rotation_type);
    barley_perc_run(run) = barley_perc;
   break_perc_run(run) = break_perc;
    if run == 1
        total_growth = zeros(run_max,number_of_years);
        flowerheads = zeros(run_max,number_of_years);
    end
    

    plough = zeros(1,number_of_years);
    % note that plough is of next year's crop
    for t = 1:1:number_of_years
        if t == number_of_years
            if rotation_run(1) == 1 || rotation_run(1) == 2
                plough(t) = spring_plough;
            elseif  rotation_run(1) == 3 || rotation_run(1) == 4
                plough(t) = winter_plough;
            elseif rotation_run(1) == 5 || rotation_run(1) == 6 || rotation_run(1) == 7
                plough(t) = no_plough;
            end
        else
            if rotation_run(t+1) == 1 || rotation_run(t+1) == 2
                plough(t) = spring_plough;
            elseif  rotation_run(t+1) == 3 || rotation_run(t+1) == 4
                plough(t) = winter_plough;
            elseif rotation_run(t+1) == 5 || rotation_run(t+1) == 6 || rotation_run(t+1) == 7
                plough(t) = no_plough;
            end
            
        end
    end
    

    % initate rotations
    clear growth
    growth = zeros(1,number_of_years);
    plunge_bed = randi(2);
    first_time = 0;
    first_rot = 0;
    %for rotation = 1:1:rotations_max
    % select plunge beds
    
    % initate t-runs
    for t = 1:1:number_of_years
        if t > 2 && rotation_run(t) == 6 && rotation_run(t-1) == 6  && rotation_type ~= 64 % correct for no emergence in second year Ley's
            emergence = 0;
        else
            emergence = Emergence(rotation_run(t),plunge_bed); 
        end
        
        spss = nan;
        while isnan(spss) == 1
            pot = randi(6);
            spss = (seeds_med(rotation_run(t),plunge_bed,pot));
        end
       

        if emergence > 0
            spss = spss/emergence; % number of seeds per emergence
        else
            spss = 0;
        end
        emergence_rate = emergence/seeds_planted;
        if emergence_rate > seed_bank
            emergence_rate = seed_bank;
        end
        % density dependence
        
        if t ~= 1
            growth(t) = (spss* plough(t)*emergence_rate) + ((seed_bank* (1- emergence_rate))); % part 1, what is new in the seed bank; part 2 what remains in the seed-bank
            total_growth(run,t) = growth(t) .* total_growth(run,t-1);
            if emergence > 0 && spss > 0 && total_growth(run,t) > median(growth) %&& total_growth(t-1) > 1
                replacement_factor = (1-((seed_bank* (1- emergence_rate)))) /(plough(t)*emergence_rate); % replacement factor per emergence
                spss_emergence = spss; % number of seed per emergence
                fullness = max_emerg/emergence;
                
                if spss_emergence < replacement_factor
                elseif (total_growth(run,t-1)) > fullness
                    factor = (fullness)/(total_growth(run,t-1));
                    spss = replacement_factor*factor;
                    if first_time == 0
                        time_to_fulness(run) = t;
                    end
                    first_time = 1;
                else
                    correction_number = ((spss_emergence-replacement_factor) * (total_growth(run,t-1)/fullness));
                    spss = (spss_emergence -  correction_number);
                end
                growth(t) = (spss* plough(t)*emergence_rate) + ((seed_bank* (1- emergence_rate)));
                
            end
            total_growth(run,t) = growth(t) .* total_growth(run,t-1);
            flowerheads(run,t) = head_count(rotation_run(t),plunge_bed).*total_growth(run,t-1);
        else
            growth(t) = (spss* plough(t)*emergence_rate) + ((seed_bank* (1- emergence_rate)));
            total_growth(run,t) = growth(t);
            flowerheads(run,t) = head_count(rotation_run(t),plunge_bed);
        end
        
        if total_growth(run,t) < extinction_tres;
            if extinction_risk_25(run) == 0 && extinction_risk_25(run) == 0
                extinction_time(run) = t;
            end
            if t <=25
                extinction_risk_25(run) = 1;
                if t <=10
                    extinction_risk_10(run) = 1;
                end
            end
        end
        if first_time == 1 && first_rot == 0
            rotation_lambda(run) = total_growth(run,t)^(1/t);
            first_rot = 1;
        end
    end
    if first_time ~= 1
        rotation_lambda(run) = total_growth(run,number_of_years)^(1/number_of_years);
    end
end
barley_perc_tot = median(barley_perc_run);
break_perc_tot = median(break_perc_run);

%collate data among runs
rotation_lambda_avg = mean(rotation_lambda); % one number
rotation_lambda_md = median(rotation_lambda); % one number
rotation_lambda_005 = prctile(rotation_lambda,5); %one number
rotation_lambda_095 = prctile(rotation_lambda,95);% one number

time_to_fulness(time_to_fulness == 0) = [];
if isempty(time_to_fulness) ~= 1
    Tf_freq = length(time_to_fulness)/run_max;
    Tf_avg = mean(time_to_fulness);
    Tf_md= median(time_to_fulness);
    Tf_005 = prctile(time_to_fulness,5);
    Tf_095 = prctile(time_to_fulness,95);
else
    Tf_freq = 0;
    Tf_avg = nan;
    Tf_md = nan;
    Tf_005 = nan;
    Tf_095 =nan;
end

extinction_time(extinction_time == 0) = [];
if isempty( extinction_time) ~= 1
    et_avg = mean(extinction_time);
    et_md = median(extinction_time);
    et_005 = prctile(extinction_time,5);
    et_095 = prctile(extinction_time,95);
else
    et_avg = nan;
    et_md = nan;
    et_005 = nan;
    et_095 =nan;
end

extinction_risk_tot_25 = sum(extinction_risk_25/run_max);  % one number
extinction_risk_tot_10 = sum(extinction_risk_10/run_max);% one number

name_file= ['overview','_',int2str(species),'_',int2str(rotation_type),'.mat'];

array = [species,rotation_type, number_of_years,fallow_return,ley_return,end_fallows,end_leys,...
    extinction_risk_tot_10,extinction_risk_tot_25,et_md, Tf_freq,...
    rotation_lambda_md, et_md, Tf_md,...
    rotation_lambda_avg, et_avg, Tf_avg,...
    rotation_lambda_005, et_005, Tf_005,...
    rotation_lambda_095, et_095, Tf_095,barley_perc_tot,break_perc_tot];

%1: species
%2: rotation_type
%3: number of years full
%4: fallow return years
%5: Ley return years
%6: Length of end fallows
%7: length of end leys
%8: extinction_risk_tot_10
%9: extinction_risk_tot_25
%10: et_median
%11: Tf_freq
%12: lambda_md
%13: et_median
%14: Tf_media
%15: lambda_avg
%16: et_avg
%17: Tf_avg
%18: lambda_005
%19: et_005
%20: Tf_005
%21: lambda_095
%22: et_095
%23: Tf_095
%24: Percentage Barley
%25: Percentage break crops

% arrays to store for depicting results
total_growth_avg = mean(total_growth,1); % array
total_growth_med = median(total_growth,1);% array
total_growth_005 = prctile(total_growth,5); %array
total_growth_095 = prctile(total_growth,95); %array
total_growth_010 = prctile(total_growth,10); %array
total_growth_090 = prctile(total_growth,90); %array
total_growth_025 = prctile(total_growth,25); %array
total_growth_075 = prctile(total_growth,75); %array
total_growth_040 = prctile(total_growth,40); %array
total_growth_060 = prctile(total_growth,60); %array
flowerheads_md = median(flowerheads,1); % array
flowerheads_avg = mean(flowerheads,1);
flowerheads_005 = prctile(flowerheads,5); %array
flowerheads_095 = prctile(flowerheads,95); %array


flowerheads_all_md = flowerheads_md' ; %#ok<*NASGU>
flowerheads_all_avg = flowerheads_avg';
flowerheads_all_005 = flowerheads_005' ;
flowerheads_all_095 = flowerheads_095' ;
total_growth_avg = total_growth_avg';
total_growth_med = total_growth_med';
total_growth_005 = total_growth_005';
total_growth_095 = total_growth_095';
total_growth_010 = total_growth_010';
total_growth_090 = total_growth_090';
total_growth_025 = total_growth_025';
total_growth_075 = total_growth_075';
total_growth_040 = total_growth_040';
total_growth_060 = total_growth_060';

save(name_file, 'array',...
    'flowerheads_all_md','flowerheads_all_avg', 'flowerheads_all_005',...
    'flowerheads_all_095','number_of_years','total_growth_avg','total_growth_med',...
    'total_growth_005','total_growth_095','total_growth_010','total_growth_090',...
    'total_growth_025','total_growth_075','total_growth_040','total_growth_060', 'fallow_return');

output = 1;
toc
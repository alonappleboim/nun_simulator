%%% This script runs a dynamic simulation for a given gene ID

load('C:\Users\Daniel\Documents\MATLAB\nuc_simulator\clustering\experiment_data\sth1_0m_centers.mat')
load('C:\Users\Daniel\Documents\MATLAB\Friedman Lab\Experiment Data\sequences_structure.mat')
load('C:\Users\Daniel\Documents\MATLAB\Friedman Lab\results\genome_results\gene_summary.mat')
create_params_genome;

iterations = 150;
first_n_steps = 10000;
second_n_steps = 20000;

Gene_id = 202; %%% INSERT GENE ID HERE
wt_param = optimal_param_indices(genes == Gene_id);

genlen = 3500;
TSS = round(genlen/2);
NFR_pos = [TSS-299 : TSS+150];

% Starting Variables:
seq = sequences_structure(Gene_id,:);
nuc_history = zeros(first_n_steps + second_n_steps + 2, genlen);
mat_time = zeros(first_n_steps + second_n_steps + 2, 1);

%%

% run the simulation:
for i = 1:iterations
    
    % first simulation with wt params:
    sim_params = params(: , wt_param);
    [~, time, nuc_s_hist, ~, ~, ~, ~] = ...
        run_simulation_from_genome(seq, 'poly_rate',0, ...
        'REB1_a_rate', 0.0001, 'REB1_e_rate', 0.0001, ...
        'ABF1_a_rate', 0.0001, 'ABF1_e_rate', 0.0001, ...
        'RAP1_a_rate', 0.0001, 'RAP1_e_rate', 0.0001, ...
        'TF_evic_intensity', sim_params(1), ...
        'RSC_evic_length', sim_params(2), 'RSC_slide_length', sim_params(2).*sim_params(3), ...
        'RSC_evic_intensity', sim_params(4), ...
        'RSC_slide_intensity', sim_params(4)*sim_params(5), 'slide_len', 3, 'gen_len', genlen, 'n_steps', first_n_steps);
    
    mat_time_1 = repmat(time, 1, genlen);
    wt_nuc_hist = nuc_s_hist .* mat_time_1;
    
    % second simulation with null model params and s0 as the last state from the
    % wt simulation:
    [~, time_2, nuc_s_hist_2, ~, ~, ~, ~] = ...
        run_null_model_simulation_from_genome(seq, 's0', nuc_s_hist(end,:), ...
        'slide_len', 3, 'gen_len', genlen, 'n_steps', second_n_steps);

    mat_time_2 = repmat(time_2, 1, genlen);
    sth1_nuc_hist = nuc_s_hist_2 .* mat_time_2;

    % combine the two state histories into one big state history:
    temp = [mat_time_1 ; mat_time_2];
    mat_time = mat_time + cumsum(temp(:, 1));
    nuc_history = nuc_history + (temp .* [wt_nuc_hist ; sth1_nuc_hist]);
end
mat_time = mat_time ./ iterations;

%%

% create a data matrix for the gene:
data_matrix = zeros(7,genlen);
load('C:\Users\Daniel\Documents\MATLAB\nuc_simulator\clustering\experiment_data\sth1_0m_centers.mat')
temp = create_gene_buffer(data(Gene_id,:),genlen);
data_matrix(1, :) = temp;
load('C:\Users\Daniel\Documents\MATLAB\nuc_simulator\clustering\experiment_data\sth1_10m_centers.mat')
temp = create_gene_buffer(data(Gene_id,:),genlen);
data_matrix(2, :) = temp;
load('C:\Users\Daniel\Documents\MATLAB\nuc_simulator\clustering\experiment_data\sth1_20m_centers.mat')
temp = create_gene_buffer(data(Gene_id,:),genlen);
data_matrix(3, :) = temp;
load('C:\Users\Daniel\Documents\MATLAB\nuc_simulator\clustering\experiment_data\sth1_30m_centers.mat')
temp = create_gene_buffer(data(Gene_id,:),genlen);
data_matrix(4, :) = temp;
load('C:\Users\Daniel\Documents\MATLAB\nuc_simulator\clustering\experiment_data\sth1_45m_centers.mat')
temp = create_gene_buffer(data(Gene_id,:),genlen);
data_matrix(5, :) = temp;
load('C:\Users\Daniel\Documents\MATLAB\nuc_simulator\clustering\experiment_data\sth1_60m_centers.mat')
temp = create_gene_buffer(data(Gene_id,:),genlen);
data_matrix(6, :) = temp;
load('C:\Users\Daniel\Documents\MATLAB\nuc_simulator\clustering\experiment_data\sth1_2h_centers.mat')
temp = create_gene_buffer(data(Gene_id,:),genlen);
data_matrix(7, :) = temp;

%%

jump_len = 50;
window_size = 1000;
until_when = first_n_steps + second_n_steps - 5*window_size;

% create the Simulation Matrix:
sim_matrix = zeros(floor((until_when + window_size - first_n_steps) / jump_len), genlen);
for i = first_n_steps-window_size : jump_len : until_when
    sim_matrix(((i - first_n_steps+window_size) / jump_len) + 1,:) = sum(nuc_history(i:i+window_size , :));
end

%%

[timeExpansion, timeExpansions, costs] = getTimeExpansion(data_matrix, sim_matrix);

exp_time = [0, 10, 20, 30, 45, 60, 120];

% plot the time expansion convergence:
figure;
plot(timeExpansions.*jump_len, costs, 'x')
title(['Convergence of Time Expansion Constant - Gene ' num2str(Gene_id)])
xlabel('Time Expansion Constant')
ylabel('Cost')

% plot the genes with the time expansion:

data = conv(data_matrix(1, NFR_pos), gausswin(10)./sum(gausswin(10)), 'same');
sim = conv(sim_matrix(round(exp_time(1) * timeExpansion)+1, NFR_pos), gausswin(10)./sum(gausswin(10)), 'same');
figure('units','normalized','position',[0 0 1 1]);
plot(data, 'b')
hold on
plot(sim .* sum(data) ./ sum(sim), 'r')
legend('experiment data','simulation')
xlabel('Position (TSS at 300)')
ylabel('Nucleosome Intensity')
title(['Gene ' num2str(Gene_id) ' - 0 minutes' char(10) 'time expansion = ' num2str(timeExpansion.*jump_len)])

data = conv(data_matrix(2, NFR_pos), gausswin(10)./sum(gausswin(10)), 'same');
sim = conv(sim_matrix(round(exp_time(2) * timeExpansion + 1), NFR_pos), gausswin(10)./sum(gausswin(10)), 'same');
figure('units','normalized','position',[0 0 1 1]);
plot(data, 'b')
hold on
plot(sim .* sum(data) ./ sum(sim), 'r')
legend('experiment data','simulation')
xlabel('Position (TSS at 300)')
ylabel('Nucleosome Intensity')
title(['Gene ' num2str(Gene_id) ' - 10 minutes' char(10) 'time expansion = ' num2str(timeExpansion.*jump_len)])

data = conv(data_matrix(3, NFR_pos), gausswin(10)./sum(gausswin(10)), 'same');
sim = conv(sim_matrix(round(exp_time(3) * timeExpansion + 1), NFR_pos), gausswin(10)./sum(gausswin(10)), 'same');
figure('units','normalized','position',[0 0 1 1]);
plot(data, 'b')
hold on
plot(sim .* sum(data) ./ sum(sim), 'r')
legend('experiment data','simulation')
xlabel('Position (TSS at 300)')
ylabel('Nucleosome Intensity')
title(['Gene ' num2str(Gene_id) ' - 20 minutes' char(10) 'time expansion = ' num2str(timeExpansion.*jump_len)])

data = conv(data_matrix(4, NFR_pos), gausswin(10)./sum(gausswin(10)), 'same');
sim = conv(sim_matrix(round(exp_time(4) * timeExpansion + 1), NFR_pos), gausswin(10)./sum(gausswin(10)), 'same');
figure('units','normalized','position',[0 0 1 1]);
plot(data, 'b')
hold on
plot(sim .* sum(data) ./ sum(sim), 'r')
legend('experiment data','simulation')
xlabel('Position (TSS at 300)')
ylabel('Nucleosome Intensity')
title(['Gene ' num2str(Gene_id) ' - 30 minutes' char(10) 'time expansion = ' num2str(timeExpansion.*jump_len)])

data = conv(data_matrix(5, NFR_pos), gausswin(10)./sum(gausswin(10)), 'same');
sim = conv(sim_matrix(round(exp_time(5) * timeExpansion + 1), NFR_pos), gausswin(10)./sum(gausswin(10)), 'same');
figure('units','normalized','position',[0 0 1 1]);
plot(data, 'b')
hold on
plot(sim .* sum(data) ./ sum(sim), 'r')
legend('experiment data','simulation')
xlabel('Position (TSS at 300)')
ylabel('Nucleosome Intensity')
title(['Gene ' num2str(Gene_id) ' - 45 minutes' char(10) 'time expansion = ' num2str(timeExpansion.*jump_len)])

data = conv(data_matrix(6, NFR_pos), gausswin(10)./sum(gausswin(10)), 'same');
sim = conv(sim_matrix(round(exp_time(6) * timeExpansion + 1), NFR_pos), gausswin(10)./sum(gausswin(10)), 'same');
figure('units','normalized','position',[0 0 1 1]);
plot(data, 'b')
hold on
plot(sim .* sum(data) ./ sum(sim), 'r')
legend('experiment data','simulation')
xlabel('Position (TSS at 300)')
ylabel('Nucleosome Intensity')
title(['Gene ' num2str(Gene_id) ' - 60 minutes' char(10) 'time expansion = ' num2str(timeExpansion.*jump_len)])

data = conv(data_matrix(7, NFR_pos), gausswin(10)./sum(gausswin(10)), 'same');
sim = conv(sim_matrix(round(exp_time(7) * timeExpansion + 1), NFR_pos), gausswin(10)./sum(gausswin(10)), 'same');
figure('units','normalized','position',[0 0 1 1]);
plot(data, 'b')
hold on
plot(sim .* sum(data) ./ sum(sim), 'r')
legend('experiment data','simulation')
xlabel('Position (TSS at 300)')
ylabel('Nucleosome Intensity')
title(['Gene ' num2str(Gene_id) ' - 120 minutes' char(10) 'time expansion = ' num2str(timeExpansion.*jump_len)])

%%

%%% Make a movie of the dynamic simulation:
nuc_dynamics_movie(nuc_history(),mat_time,['C:\Users\Daniel\Documents\MATLAB\nuc_simulator\visualization\movies\dynamics_test_gene_' num2str(Gene_id) '.mp4'],Gene_id, first_n_steps, window_size, timeExpansion, jump_len);

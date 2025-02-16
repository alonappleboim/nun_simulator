function sanity_check(gene_index, sequences_structure, wt_3h, a, b)

poly_rates = [0];
tf_rates = [0.0001]; % this is the TF assembly rate, and the eviction will be half of this
tf_evic_eff = [0.0001];
rsc_length = [20, 40, 60, 80, 100, 120, 140, 160, 180, 200]; % this is the eviction length of RSC - the sliding length will be twice this
rsc_evic_eff = [0.05];
rsc_slide_eff = [0.2, 0.4, 0.6, 0.8, 1, 1.2, 1.4, 1.6, 1.8, 2];

genlen = 3500;
TSS = fix(genlen/2);
NFR_pos = [TSS-299 : TSS+150];

% load all the necessary data:
addpath(genpath('/cs/bd/Daniel/nflab_scripts'));
addpath(genpath('/cs/bd/Daniel/nuc_simulator'));
seq = sequences_structure(gene_index,:);
wt_data = wt_3h(gene_index,:);

if (isnan(wt_data(1)))
    nuc_sum = 0;
    likelihood = 0;
    plus1_dist = 0;
    minus1_dist = 0;

else
    
    % make the wt data the right length:
    buffer = genlen - 2501;
    right_buffer = fix((buffer-500)/2);
    left_buffer = right_buffer + 500;
    if (right_buffer + left_buffer < buffer)
        left_buffer = left_buffer + 1;
    end
    wt_data = [zeros(1,left_buffer), wt_data, zeros(1,right_buffer)];

    % create the simulation:
	nuc_sum = zeros(1,genlen);
	for i = 1:20
    nuc_sum1 = run_simulation_from_genome(seq,'report',0, ...
        'poly_rate',poly_rates(1), ...
        'REB1_a_rate', tf_rates(1), 'REB1_e_rate', tf_rates(1), ...
        'ABF1_a_rate', tf_rates(1), 'ABF1_e_rate', tf_rates(1), ...
        'RAP1_a_rate', tf_rates(1), 'RAP1_e_rate', tf_rates(1), ...
        'TF_evic_intensity', tf_evic_eff(1), ...
        'RSC_evic_length', rsc_length(a), 'RSC_slide_length', rsc_length(a).*2, ...
        'RSC_evic_intensity', rsc_evic_eff(1), ...
        'RSC_slide_intensity', rsc_slide_eff(b), 'slide_len', 3, 'gen_len', genlen, 'n_steps', 10000);
	nuc_sum = nuc_sum + nuc_sum1;
	end
	
    % get the feature of the simulation:
    [likelihood, plus1_dist, minus1_dist, peak_num_delta, plus1width, minus1width, ratio] ...
        = Compare_Sum_To_Data(nuc_sum, wt_data, NFR_pos, true);

end

% save the data to a .mat file:
save(['/cs/bd/Daniel/simulations/sanity_checks/sim_' num2str(a) '_' num2str(b) 'gene_' num2str(gene_index) '.mat'] , ...
	'nuc_sum', 'likelihood', 'plus1_dist', 'minus1_dist');
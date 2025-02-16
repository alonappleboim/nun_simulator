function cluster_reduce(gene_index, all_data, results_path, data_type)

% create the full parameter matrix
create_params_genome;
gene_index = genes(gene_index);

genlen = 3500;
TSS = fix(genlen/2);
NFR_pos = [TSS-299 : TSS+150];

num_of_runs = length(params(1,:));

% ignore NaN genes:
exp_data = all_data(gene_index,:);
if (isnan(exp_data(1)))
    return
end
exp_data = create_gene_buffer(exp_data,genlen);

% create a matrix for all the results:
features = zeros(num_of_runs, 1);
likelihoods = zeros(num_of_runs, 1);
ratios = zeros(num_of_runs, 1);
nuc_sums = zeros(num_of_runs, 3500);

% load all of the results:
for i = 1:num_of_runs
	try
        load([results_path 'sim_' num2str(i) '_gene_' num2str(gene_index) '.mat']);
    catch a
        features(i,1) = nan;
        likelihoods(i,1) = nan;
        ratios(i,1) = nan;
        nuc_sums(i,:) = zeros(1,3500);
        continue
    end
            
    % get the feature of the simulation:
    [likelihood, plus1_dist, minus1_dist, peak_num_delta, plus1width, minus1width, height_ratio] = ...
        Compare_Sum_To_Data(nuc_sum, exp_data, NFR_pos, true);
    [optimum_likelihood, ~,~,~,~,~,~] = ...
        Compare_Sum_To_Data(exp_data, exp_data, NFR_pos, true);
    [bad_likelihood,~,~,~,~,~,~] = ...
        Compare_Sum_To_Data(ones(size(exp_data)), exp_data, NFR_pos, true);
    ratio = (likelihood - bad_likelihood) / (optimum_likelihood - bad_likelihood);
    
    % deal with NaNs:
    if (isnan(plus1_dist))
        plus1_dist = 50;
    end
    if (isnan(minus1_dist))
        minus1_dist = 50;
    end

    likelihoods(i,1) = likelihood;
    features(i,1) = likelihood - plus1_dist - minus1_dist;
    ratios(i,1) = ratio;
	nuc_sums(i, :) = nuc_sum;
    
end

% find the best result:
[best_sim_feature, best_sim_index] = max(features);
[best_likelihood, best_likelihood_index] = max(likelihoods);
[best_ratio, best_ratio_index] = max(ratios);
nuc_sum_feature = nuc_sums(best_sim_index, :);
nuc_sum_likelihood = nuc_sums(best_likelihood_index, :);

% save to a new .mat file:
save([results_path 'results_' data_type '_' num2str(gene_index)] , ...
	'best_sim_feature', 'best_sim_index', 'best_likelihood', 'best_likelihood_index', 'best_ratio', 'features', 'nuc_sum_feature', 'nuc_sum_likelihood');
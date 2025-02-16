load('C:\Users\Daniel\Documents\MATLAB\Friedman Lab\Experiment Data\wt_centers.mat')
load('C:\Users\Daniel\Documents\MATLAB\Friedman Lab\Experiment Data\sequences_structure.mat')

NFR_pos = [601:1200];
gene_id = 23;

create_full_params;

seq = sequences_structure(gene_id,:);
wt =  wt_3h(gene_id,:);
[ PolyA_Sites, PolyT_Sites, REB1_Sites, ABF1_Sites, RAP1_Sites ] = ...
    Extract_Sites_From_Gene(seq, 3500);

nuc_sum = nuc_sums(best_sim_index, 1:2500);
coverage = ksdensity(1:length(nuc_sum),1:length(nuc_sum),'weights',double(nuc_sum(1:end)),'width',5);
smoothed_wt = ksdensity([1:length(wt)],[1:length(wt)],'weights',double(wt),'width',5);

% full gene plot:
figure;
plot(smoothed_wt(1:end-1),'b')
%plot(wt(1:end-1),'b')
hold on
plot(coverage,'r')
%plot((nuc_sum .* sum(wt)) ./ sum(nuc_sum),'r')
plot(PolyA_Sites(1:2500) .* mean(smoothed_wt),'k')
plot(PolyT_Sites(1:2500) .* mean(smoothed_wt),'m')
plot(REB1_Sites(1:2500) .* 4 .* mean(smoothed_wt), 'g')
plot(ABF1_Sites(1:2500) .* 4 .* mean(smoothed_wt), 'c')
plot(RAP1_Sites(1:2500) .* 4 .* mean(smoothed_wt), 'y')
legend('wild-type','simulation','PolyA (right)','PolyT (left)', 'REB1', 'ABF1', 'RAP1')
xlabel('Position (TSS at 1000)')
ylabel('Intensity')
title(['Likelihood = ' num2str(features(best_sim_index)) char(10) 'Gene Index = ' num2str(gene_id)])

% make the textbox string:
%{
textbox_string = [...
    'Poly Rate = ' num2str(params(1, best_sim_index)) char(10) ...
    'TF Eviction Effect = ' num2str(params(3, best_sim_index)) char(10) ...
    'RSC Eviction Effect = ' num2str(params(5, best_sim_index)) char(10) ...
    'RSC Eviction Length = ' num2str(params(4, best_sim_index)) char(10) ...
    'RSC Slide Effect = ' num2str(params(6, best_sim_index)) char(10) ...
    'RSC Slide Length = ' num2str(params(4, best_sim_index) * 2) ...
    ];
%}

data = conv(wt(NFR_pos), gausswin(5)./sum(gausswin(5)), 'same');

% feature plot (only NFR):
nuc_sum = conv(nuc_sum, gausswin(5)./sum(gausswin(5)), 'same');
nuc_sum = nuc_sum(NFR_pos) .* sum(data) ./ sum(nuc_sum(NFR_pos));
figure;
plot(data, 'b')
hold on
plot(nuc_sum, 'r')
legend('wild-type','simulation')
xlabel('Position (TSS at 400)')
ylabel('Intensity')
title(['Likelihood = ' num2str(features(best_sim_index)) char(10) 'Gene Index = ' num2str(gene_id)])
annotation('textbox','String',textbox_string,'FitBoxToText','on')
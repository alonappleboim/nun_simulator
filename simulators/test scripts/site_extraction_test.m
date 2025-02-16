
%% plot the new binding sites and the old ones for a specific gene

gene_id = 7;

genlen = 3500;
TSS = 1750;
NFR_pos = [TSS-299 : TSS+150];
seq = sequences_structure(gene_id,:);
wt = wt_3h(gene_id,:);

NFR_pos = [TSS-299 : TSS+150];

[ polyA_old, polyT_old, REB1_old, ABF1_old, RAP1_old ] = Extract_Sites_From_Gene(seq, genlen);
[ polyA_new, polyT_new, REB1_new, ABF1_new, RAP1_new ] = Extract_Sites_From_Gene_new(seq, genlen, NFR_pos);

[ a_rate, e_rate, r_rate, l_rate, ... 
            REB1_a, REB1_e, ABF1_a, ABF1_e, RAP1_a, RAP1_e] = ...
    generate_rates_from_sites( polyA_new, polyT_new, REB1_new, ...
    ABF1_new, RAP1_new); %, 'TF_evic_intensity', 0.1);

figure
plot(polyA_new(750:end-751)*20, 'b')
hold on
plot(polyT_new(750:end-751)*20, 'm')
plot(r_rate(750:end-751), 'r')
plot(l_rate(750:end-751), 'k')
xlabel('Position')
ylabel('Rate Intensity')
legend('Poly A','Poly T','Right Sliding Rate','Left Sliding Rate')

figure
plot(r_rate(NFR_pos))
hold on
plot(REB1_new(NFR_pos))
plot(ABF1_new(NFR_pos))
plot(RAP1_new(NFR_pos))

figure
subplot(2,1,1)
plot(REB1_old(NFR_pos),'b')
hold on
plot(ABF1_old(NFR_pos),'r')
plot(RAP1_old(NFR_pos),'k')
plot(wt(NFR_pos)./max(wt(NFR_pos)),'g')
legend('REB1','ABF1','RAP1','wt')
ylabel('OLD')
subplot(2,1,2)
plot(REB1_new(NFR_pos),'b')
hold on
plot(ABF1_new(NFR_pos),'r')
plot(RAP1_new(NFR_pos),'k')
plot(wt(NFR_pos)./max(wt(NFR_pos)),'g')
legend('REB1','ABF1','RAP1','wt')
ylabel('NEW')

%% find the histograms of the results of the PWD test:

REB1s = [];
ABF1s = [];
RAP1s = [];

for gene_id = 1:6000
    
    genlen = 3500;
    TSS = 1750;
    seq = sequences_structure(gene_id,:);

    if (seq(1,1) == ' ')
        continue
    end
    
    [ polyA_new, polyT_new, REB1_new, ABF1_new, RAP1_new ] = Extract_Sites_From_Gene_new(seq, genlen, NFR_pos);
    
    REB1s = [REB1s REB1_new(REB1_new > 0)];
    ABF1s = [ABF1s ABF1_new(ABF1_new > 0)];
    RAP1s = [RAP1s RAP1_new(RAP1_new > 0)];
end

figure
subplot(3,1,1)
hist(REB1s)
subplot(3,1,2)
hist(ABF1s)
subplot(3,1,3)
hist(RAP1s)
function [ PolyA_Sites, PolyT_Sites, REB1_Sites, ABF1_Sites, RAP1_Sites ] =... 
    Extract_Sites_From_Gene( genome, gen_len) %, NFR_pos )
%Extract_Sites_From_Gene The function that extracts Poly(dA:dT) and binding
%sites from the genome.
%   Given a 2501-bp-long genome, where the TSS is at position 1000, and at 
%   least a 3000 gen_len, and the NFR positions, the
%   function goes over the known trans-factors binding sites and finds
%   their positions in the genome, along with the Poly(dA:dT) positions.
%   For the binding sites I used the data from
%   http://yetfasco.ccbr.utoronto.ca/ and used the PWD result of each bp as 
%   the strength of the site, and took into account the 
%   concentration ratio of each TF.
%   For the PolyA and PolyT, I just return 1 for positions that are the 
%   center of a 5-bp-long PolyA or PolyT.

vec_len = 2501;

% define the vectors that will be returned:
PolyA_Sites = zeros(1,vec_len);
PolyT_Sites = zeros(1,vec_len);
REB1_Sites = zeros(1,vec_len);
ABF1_Sites = zeros(1,vec_len);
RAP1_Sites = zeros(1,vec_len);

% define the position weight matrix (in log-likelihood), taken from
% YeTFaSCo:
%{
REB1_pwm = ...
[-0.217050390610674,0.477092343904717,0.337480912789146,-1.25043113159347,-1.45212035434108,-2.19291103702526,-5.87013204559840,-5.87013204559840,-5.87013204559840,-5.87013204559840,1.67268082511183,1.67268082511183,-3.79069757810400;
    -0.127393626101048,-0.602285349283799,-1.07253169106653,0.514387006619952,-1.52659013760498,-5.87013204559840,-5.87013204559840,-5.87013204559840,-5.87013204559840,1.67268082511183,-5.87013204559840,-5.87013204559840,0.294869723468991;
    -0.633217669328377,-0.850124551581096,0.903444262810368,0.948994220376744,0.0477955110963828,-5.89178370321831,2.37573453858316,2.37573453858316,2.37573453858316,-5.89178370321831,-5.89178370321831,-5.89178370321831,-1.01373279048977;
    0.783291217167135,0.446395546681801,-0.850124551581096,-1.66296501272243,1.61675389212901,2.28126875455581,-5.89178370321831,-5.89178370321831,-5.89178370321831,-5.89178370321831,-5.89178370321831,-5.89178370321831,1.40513250366098];
ABF1_pwm = ...
[0.0201717974349259,-0.439217512957354,0.533781146683706,-8.37304874723488,-1.45112110840607,0.713711330246337,-9.04202062875251,-1.04314084564999,-0.528305657677376,-1.03861585195318,-0.359054017238382,-0.930211651872192,1.68533827343776,-8.28044601122433,-8.29009826211281,0.369279760835682,-0.264551671009874,-0.171696850500320;
    -0.210259554917608,-0.166180923717330,-7.01192502199901,1.59273553742720,-4.82151143974567,-2.79881878492180,0.405942827568129,0.349469654325613,0.0971411289824223,-0.0250483331584163,-0.752052236234924,0.164896595945434,-8.28044601122433,-8.28044601122433,-5.33907004906506,-0.875877194066342,-0.404986710983654,-0.401713587895773;
    -0.0268400095582240,0.660038723666524,1.11693970808458,-1.59015672540464,-3.58277968955035,0.763462996105119,-8.33575183180922,0.177406399766386,0.0845894543131994,0.0518708109930934,0.546122002142265,0.344700882272401,-7.57417721428104,-7.57417721428104,2.38195481949257,0.886694020387970,0.318604246980430,0.361657651802889;
    0.283010287166459,0.0365047094258774,-0.474763296058164,-7.66677995029159,2.17800315177311,-0.609743411932636,1.63003245285286,0.335449829426735,0.407369246553070,0.870905696610713,0.643520464112006,0.387261247846922,-7.57417721428104,2.39160707038105,-7.58382946516952,-1.25975016614771,0.511544489300466,0.372624950046923];
RAP1_pwm = ...
[-0.381306641966294,0.531230516783367,-6.27612440527424,-5.27612440527424,-2.12637728576956,0.730943562150607,-2.88380698249548,-2.39203794048542,-6.27612440527424,-0.462343214057200,-4.57712665986436,-5.27612440527424,-1.84985965057214;
    -0.0569558848120760,-2.75256244921722,1.37133402118068,-4.57568468713315,1.37133402118068,-1.70482538151632,1.12688761830076,-4.36779039423875,-1.32192809488736,-4.95419631038688,1.51522391466750,-0.369233809665719,0.945462715990567;
    1.22456025801916,1.40168794561982,0.0151068923902083,2.35198532874354,-5.56985560833095,0.797910021341842,-5.56985560833095,2.27864515475224,2.18336114084801,1.95762139772945,-1.81641007889869,1.83102382795124,-0.736965594166206;
    -3.24792751344359,-5.56985560833095,-6.56985560833095,-4.39993060688864,-0.627341102991708,-1.66152159729546,0.543886557718241,-5.56841219290397,-4.39993060688864,-2.81496810616748,-2.01670872938452,-1.32192809488736,0.0954803088542283];

% define the factors (these are the consentration ratios of ABF1 and RAP1 
% in relation to the REB1 concentration, calculated from SGD). The idea is 
% that the concentration of TFs in the cell effects the chance of binding, 
% which in turn effects the nucleosome eviction rates:
ABF1_factor = 0.64;
RAP1_factor = 0.54;

% make the sequence into indexes for the PWMs:
genome_indices = zeros(1,length(genome));
genome_indices(genome == 'A') = 1;
genome_indices(genome == 'T') = 2;
genome_indices(genome == 'G') = 3;
genome_indices(genome == 'C') = 4;
inverted_genome_indices = zeros(1,length(genome));
inverted_genome_indices(genome == 'T') = 1;
inverted_genome_indices(genome == 'A') = 2;
inverted_genome_indices(genome == 'C') = 3;
inverted_genome_indices(genome == 'G') = 4;

% check for every bp if it is a binding site, using the PWMs:
for i = 200 : length(genome)-200
    gen = genome_indices(i-6 : i+6);
    REB1_check = sum(REB1_pwm((gen) + [0:12].*4)) / 13; % indexing the right parts of the matrix)
    RAP1_check = sum(RAP1_pwm((gen) + [0:12].*4)) / 13;

    gen = genome_indices(i-9 : i+8);
    ABF1_check = sum(ABF1_pwm((gen) + [0:17].*4)) / 18;
    
    % decide using the threshold for each TF:
    if (REB1_check > 0)
        REB1_Sites(i) = REB1_check;
    end
    if (ABF1_check > 0)
        ABF1_Sites(i) = ABF1_check .* ABF1_factor;
    end
    if (RAP1_check > 0)
        RAP1_Sites(i) = RAP1_check .* RAP1_factor;
    end
    
    % now for inverted nucleotides:
    
    gen = inverted_genome_indices(i-6 : i+6);
    REB1_check = sum(REB1_pwm((gen) + [0:12].*4)) / 13;
    RAP1_check = sum(RAP1_pwm((gen) + [0:12].*4)) / 13;

    gen = inverted_genome_indices(i-9 : i+8);
    ABF1_check = sum(ABF1_pwm((gen) + [0:17].*4)) / 18;
    
    % decide using the threshold for each TF:
    if (REB1_check > 0)
        REB1_Sites(i) = REB1_check; 
    end
    if (ABF1_check > 0)
        ABF1_Sites(i) = ABF1_check .* ABF1_factor;
    end
    if (RAP1_check > 0)
        RAP1_Sites(i) = RAP1_check .* RAP1_factor;
    end
end

% increase the effect of binding sites in the NFR:
%REB1_Sites(NFR_pos) = REB1_Sites(NFR_pos) .* 4;
%ABF1_Sites(NFR_pos) = ABF1_Sites(NFR_pos) .* 4;
%RAP1_Sites(NFR_pos) = RAP1_Sites(NFR_pos) .* 4;
%}

% make vectors of PolyA and PolyT centers of 5 or longer lengths:
PolyA_Sites(genome == 'A') = 1;
PolyA_Sites = conv(PolyA_Sites, ones(1,7), 'same');
PolyA_Sites(PolyA_Sites < 5) = 0;
PolyA_Sites(PolyA_Sites > 4) = 1;
PolyA_Sites = conv(PolyA_Sites,ones(1,5),'same');
PolyA_Sites(PolyA_Sites > 0 & genome=='A') = 1;
PolyA_Sites(PolyA_Sites > 0 & genome~='A') = 0;

PolyT_Sites(genome == 'T') = 1;
PolyT_Sites = conv(PolyT_Sites, ones(1,7), 'same');
PolyT_Sites(PolyT_Sites < 5) = 0;
PolyT_Sites(PolyT_Sites > 4) = 1;
PolyT_Sites = conv(PolyT_Sites,ones(1,5),'same');
PolyT_Sites(PolyT_Sites > 0 & genome=='T') = 1;
PolyT_Sites(PolyT_Sites > 0 & genome~='T') = 0;

%{
% make the vectors be the length of the genome with the TSS in the middle:
PolyA_Sites = create_gene_buffer(PolyA_Sites, gen_len);
PolyT_Sites = create_gene_buffer(PolyT_Sites, gen_len);
REB1_Sites = create_gene_buffer(REB1_Sites, gen_len);
ABF1_Sites = create_gene_buffer(ABF1_Sites, gen_len);
RAP1_Sites = create_gene_buffer(RAP1_Sites, gen_len);
%}
end


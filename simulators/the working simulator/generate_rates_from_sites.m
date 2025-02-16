function [ a_rate, e_rate, r_rate, l_rate, ... 
            REB1_a, REB1_e, ABF1_a, ABF1_e, RAP1_a, RAP1_e] = ...
    generate_rates_from_sites( PolyA_sites, PolyT_sites, REB1_sites, ...
    ABF1_sites, RAP1_sites, varargin )
%generate_rates_from_sites generates the nucleosome and TF assembly,
%eviction, left and right rate vectors, from the given binding sites.
%   given the PolyA, PolyT and binding sites, along with optional extra parameters,
%   the function returns the relevant rates for the nucleosomes.
%
% the functions optional parameters are:
%	nuc_width - the width of the nucleosome (before adding the sigmoids)
%   REB1_width - the width of the REB1 trans factor
%   ABF1_width - the width of the ABF1 trans factor
%   RAP1_width - the width of the RAP1 trans factor
% 	poly_rate - the rate of the left sliding that is due to the polymerase
%	poly_pos - a vector indicating the positions of the polymerase (for example: 1200:2800)
%   REB1_a_rate - the REB1 assembly rate
%   REB1_e_rate - the REB1 eviction rate
%   ABF1_a_rate - the ABF1 assembly rate
%   ABF1_e_rate - the ABF1 eviction rate
%   RAP1_a_rate - the RAP1 assembly rate
%   RAP1_e_rate - the RAP1 eviction rate
%   nuc_base_a_rate - the global starting assembly rate of the nucs, before changes
%                     from the binding sites
%   nuc_base_e_rate - the global starting eviction rate of the nucs, before changes
%                     from the binding sites
%   nuc_base_r_rate - the global starting right rate of the nucs, before changes
%                     from the binding sites
%   nuc_base_l_rate - the global starting left rate of the nucs, before changes
%                     from the binding sites
%   TF_evic_intensity - the factor that multiplies the convolution of the
%                       TF sites on the nuc eviction rate
%   RSC_evic_intensity - the factor that multiplies the convolution of the
%                       PolyAT sites on the nuc eviction rate
%   RSC_evic_length - the length of the convolution of the
%                       PolyAT sites on the nuc eviction rate
%   RSC_slide_intensity - the factor that multiplies the convolution of the
%                       PolyAT sites on the nuc sliding rates
%   RSC_slide_length - the length of the convolution of the
%                       PolyAT sites on the nuc sliding rates

defaults = struct('nuc_width', 147, ...
                  'REB1_width', 13, ...
                  'ABF1_width', 18, ...
                  'RAP1_width', 13, ...
                  'poly_rate', 0, ...
				  'poly_pos', 1000:2500, ...
                  'REB1_a_rate', 0.*ones(1,3500), ...
                  'REB1_e_rate', 0.*ones(1,3500), ...
                  'ABF1_a_rate', 0.*ones(1,3500), ...
                  'ABF1_e_rate', 0.*ones(1,3500), ...
                  'RAP1_a_rate', 0.*ones(1,3500), ...
                  'RAP1_e_rate', 0.*ones(1,3500), ...
                  'nuc_base_a_rate', 0.01.*ones(1,3500), ...
                  'nuc_base_e_rate', 0.01.*ones(1,3500), ...
                  'nuc_base_r_rate', 0.1.*ones(1,3500), ...
                  'nuc_base_l_rate', 0.1.*ones(1,3500), ...
                  'TF_evic_intensity', 0, ...
                  'RSC_evic_intensity', 0.1, ...
                  'RSC_evic_length', 20, ...
                  'RSC_slide_intensity', 4, ...
                  'RSC_slide_length', 40);
p = parse_namevalue_pairs(defaults, varargin);

PolyAT_sites = PolyA_sites + PolyT_sites;

% make the assembly rates and TF eviction rates:
a_rate = p.nuc_base_a_rate;
REB1_a = p.REB1_a_rate;
ABF1_a = p.ABF1_a_rate;
RAP1_a = p.RAP1_a_rate;
REB1_e = p.REB1_e_rate;
ABF1_e = p.ABF1_e_rate;
RAP1_e = p.RAP1_e_rate;

% correct the RSC effects if there is a strong polymerase. The rates
% change to reflect the ratio between the polymerase and the RSC:
RSC_Poly_evic_ratio = (p.RSC_evic_intensity ./ (p.RSC_evic_intensity + p.poly_rate));
RSC_Poly_slide_ratio = (p.RSC_slide_intensity ./ (p.RSC_slide_intensity + p.poly_rate));

% make the eviction rates from the sites:
%{
RSC_evict = conv(PolyAT_sites, p.RSC_evic_intensity.*ones(1,p.RSC_evic_length),'same');
REB1_evict = conv(REB1_sites, p.TF_evic_intensity.*ones(1,p.REB1_width + p.nuc_width),'same');
ABF1_evict = conv(ABF1_sites, p.TF_evic_intensity.*ones(1,p.ABF1_width + p.nuc_width),'same');
RAP1_evict = conv(RAP1_sites, p.TF_evic_intensity.*ones(1,p.RAP1_width + p.nuc_width),'same');
e_rate = p.nuc_base_e_rate + RSC_evict + REB1_evict + ABF1_evict + RAP1_evict;
%}
RSC_evict = conv(PolyAT_sites, p.RSC_evic_intensity.*(gausswin(p.RSC_evic_length,2).*p.RSC_evic_length./sum(gausswin(p.RSC_evic_length,2)))','same');
REB1_evict = conv(REB1_sites, p.TF_evic_intensity.*gausswin((p.REB1_width + p.nuc_width),1.5) .* (p.REB1_width + p.nuc_width) ./ sum(gausswin((p.REB1_width + p.nuc_width),1.5)),'same');
ABF1_evict = conv(ABF1_sites, p.TF_evic_intensity.*gausswin((p.ABF1_width + p.nuc_width),1.5) .* (p.ABF1_width + p.nuc_width) ./ sum(gausswin((p.ABF1_width + p.nuc_width),1.5)),'same');
RAP1_evict = conv(RAP1_sites, p.TF_evic_intensity.*gausswin((p.RAP1_width + p.nuc_width),1.5) .* (p.RAP1_width + p.nuc_width) ./ sum(gausswin((p.RAP1_width + p.nuc_width),1.5)),'same');
e_rate = p.nuc_base_e_rate + RSC_evict + REB1_evict + ABF1_evict + RAP1_evict;


% make the left-right sliding rates from the sites:
%{
PolyAT_right = conv(PolyA_sites, p.RSC_slide_intensity.*ones(1,p.RSC_slide_length),'same');
PolyAT_left  = conv(PolyT_sites, p.RSC_slide_intensity.*ones(1,p.RSC_slide_length),'same');
PolyAT_right = conv(PolyAT_right, gausswin(p.RSC_slide_length)./sum(gausswin(p.RSC_slide_length)), 'same');
PolyAT_left = conv(PolyAT_left, gausswin(p.RSC_slide_length)./sum(gausswin(p.RSC_slide_length)), 'same');
r_rate = p.nuc_base_r_rate + PolyAT_right;
l_rate = p.nuc_base_l_rate + PolyAT_left;
%}
PolyAT_right = conv(PolyA_sites, p.RSC_slide_intensity.*(gausswin(p.RSC_slide_length,1.5).*p.RSC_slide_length./sum(gausswin(p.RSC_slide_length,1.5))),'same');
PolyAT_left  = conv(PolyT_sites, p.RSC_slide_intensity.*(gausswin(p.RSC_slide_length,1.5).*p.RSC_slide_length./sum(gausswin(p.RSC_slide_length,1.5))),'same');
l_rate = p.nuc_base_r_rate + PolyAT_right;
r_rate = p.nuc_base_l_rate + PolyAT_left;


% add the polymerase effects for the nucleosomes:
l_rate(p.poly_pos) = l_rate(p.poly_pos) .* RSC_Poly_slide_ratio;
l_rate(p.poly_pos) = l_rate(p.poly_pos) + p.poly_rate;
r_rate(p.poly_pos) = r_rate(p.poly_pos) .* RSC_Poly_slide_ratio;
e_rate(p.poly_pos) = e_rate(p.poly_pos) .* RSC_Poly_evic_ratio;

% make the TF rate vectors be only where the sites are:
REB1_a = REB1_sites .* REB1_a;
REB1_sites(REB1_sites > 0) = 1; % make all sites equal 1 for equal evic rate
REB1_e = REB1_sites .* REB1_e;
ABF1_a = ABF1_sites .* ABF1_a;
ABF1_sites(ABF1_sites > 0) = 1; % make all sites equal 1 for equal evic rate
ABF1_e = ABF1_sites .* ABF1_e;
RAP1_a = RAP1_sites .* RAP1_a;
RAP1_sites(RAP1_sites > 0) = 1; % make all sites equal 1 for equal evic rate
RAP1_e = RAP1_sites .* RAP1_e;

% add polymerase effects for the TFs (kicking them off the DNA) - right now
% the effect is half the effect of the sliding of the nucleosomes):
REB1_e(REB1_e > 0) = REB1_e(REB1_e > 0) + (p.poly_rate / 2);
ABF1_e(ABF1_e > 0) = ABF1_e(ABF1_e > 0) + (p.poly_rate / 2);
RAP1_e(RAP1_e > 0) = RAP1_e(RAP1_e > 0) + (p.poly_rate / 2);

end


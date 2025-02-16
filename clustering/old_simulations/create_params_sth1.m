genes = [86,169,185,144,168,3903,4284,3051,4694,4513,6210,3227,1841,2327,6178,3655,3656,905,5776];

tf_evic_eff = [0.0001];
RSC_evic_length = [40, 60, 70, 80]; % this is the eviction length of RSC - the sliding length will be twice this
RSC_evic_slide_length_ratio = [1, 1.5, 2];
rsc_evic_eff = [0.001, 0.003, 0.005, 0.01, 0.02];
rsc_evic_slide_eff_ratio = [1, 2, 4, 8, 16, 32]; % the ratio between slide and eviction

params = combvec(tf_evic_eff, RSC_evic_length, RSC_evic_slide_length_ratio, rsc_evic_eff, rsc_evic_slide_eff_ratio);
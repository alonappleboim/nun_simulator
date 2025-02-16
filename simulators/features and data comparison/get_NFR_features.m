function [ plus_one_delta, minus_one_delta, peak_num_delta, ... 
    plus_one_width_delta, minus_one_width_delta, peak_ratio_delta ] ...
        = get_NFR_features( sim_centers, data_centers, NFR_pos )
%GET_NFR_FEATURES get all of the specific features from the NFR
%   The function returns all the relevant features, and NaN for features
%   that weren't calculated for some reason.

[ plus_one_delta, minus_one_delta, peak_num_delta, sim_plus1_pos, sim_minus1_pos, data_plus1_pos, data_minus1_pos ] ...
    = get_peak_positions( sim_centers, data_centers, NFR_pos );

[ plus_one_width_delta, minus_one_width_delta ] = get_peak_widths( sim_centers, data_centers, ... 
    NFR_pos, sim_plus1_pos, sim_minus1_pos, data_plus1_pos, data_minus1_pos );

peak_ratio_delta = get_peak_height_ratio(sim_centers, data_centers, NFR_pos);
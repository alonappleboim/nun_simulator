function [ ratio ] = get_peak_height_ratio( sim_centers, data_centers, NFR_pos )
%GET_PEAK_HEIGHT_RATIO get the ratio delta between the sim +1 and -1, and
%the data +1 and -1.
%   The function finds the ratio between the two peaks in the sim and the
%   data, then finds the difference between the two ratios and multiplies
%   by a constant factor to get the final ratio feature.

factor = 5;

%%% find the PEAK LOCATIONS of the data and the simulation:
sim_smooth = conv(sim_centers, gausswin(100), 'same');
sim_smooth = conv(sim_smooth, gausswin(20), 'same');
[sim_peaks,sim_positions] = findpeaks(sim_smooth, 'MinPeakHeight', sum(sim_smooth)./(1.5*length(sim_smooth)));
data_smooth = conv(data_centers, gausswin(100), 'same');
data_smooth = conv(data_smooth, gausswin(20), 'same');
[data_peaks,data_positions] = findpeaks(data_smooth, 'MinPeakHeight', sum(data_smooth)./(1.5*length(data_smooth)));

% keep just the NFR peaks:
temp = sim_positions((sim_positions > NFR_pos(1)) & (sim_positions < NFR_pos(end)));
sim_peaks = sim_peaks((sim_positions > NFR_pos(1)) & (sim_positions < NFR_pos(end)));
sim_positions = temp;
temp = data_positions((data_positions > NFR_pos(1)) & (data_positions < NFR_pos(end)));
data_peaks = data_peaks((data_positions > NFR_pos(1)) & (data_positions < NFR_pos(end)));
data_positions = temp;

% find the ratios of the sim and the data:
if (length(sim_peaks)<2 || length(data_peaks)<2)
    ratio = nan;
    
else
    data_plus1_pos = data_positions(end);
    data_minus1_pos = data_positions(end-1);
    data_plus1_peak = data_peaks(end);
    data_minus1_peak = data_peaks(end-1); 
    [~, index] = min(abs(sim_positions - data_plus1_pos));
    sim_plus1_peak = sim_peaks(index);
    [~, index] = min(abs(sim_positions - data_minus1_pos));
    sim_minus1_peak = sim_peaks(index);
    
    % make sure we use the larger than 1 ratio, with the right sign. we use 
    % 0.9 because we don't want close peaks to get a 2 in the ratio, even 
    % though it should be low:
    sim_ratio = sim_plus1_peak / sim_minus1_peak;
    if (sim_ratio < 0.9)
        sim_ratio = -1/sim_ratio;
    end
    data_ratio = data_plus1_peak / data_minus1_peak;
    if (data_ratio < 0.9)
        data_ratio = -1/data_ratio;
    end

    ratio = abs(sim_ratio - data_ratio) * factor;
    
end

%{
    plot(NFR_pos, sim_smooth(NFR_pos), 'r')
    hold on
    plot(NFR_pos, data_smooth(NFR_pos) .* (sum(sim_smooth(NFR_pos)) ./ sum(data_smooth(NFR_pos))), 'b')
    legend('sim','wt')
%}

end


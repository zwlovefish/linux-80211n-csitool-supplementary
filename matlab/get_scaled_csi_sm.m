%GET_SCALED_CSI_SM Converts a CSI struct to a scaled CSI matrix.
% This version undoes Intel's spatial mapping to return the pure
% MIMO channel matrix H.
%
% (c) 2008-2011 Daniel Halperin <dhalperi@cs.washington.edu>
%
function ret = get_scaled_csi_sm(csi_st)
    % Pull out CSI
    csi = csi_st.csi;

    % Calculate the scale factor between RSSI and CSI
    csi_sq = csi .* conj(csi);
    csi_mag = sum(csi_sq(:));
    rssi_mag = dbinv(get_total_rss(csi_st));

    % Noise might be undefined
    % ... If so, set it to -92
    if (csi_st.noise == -127)
        noise = -92;
    else
        noise = csi_st.noise;
    end

    % Scale factor to convert to SNR. Two steps:
    %
    %   Scale CSI -> S : rssi_mag / (mean of csi_mag)
    %   N: noise in dBm
    scale = rssi_mag / (csi_mag / 30) * dbinv(-noise);
    ret = csi * sqrt(scale);
    if csi_st.Ntx == 2
        ret = ret * sqrt(2);
    elseif csi_st.Ntx == 3
        ret = ret * sqrt(dbinv(4.5));
    end
    
    % Remove the spatial mapping that was used for this CSI
    ret = remove_sm(ret, csi_st.rate);
end
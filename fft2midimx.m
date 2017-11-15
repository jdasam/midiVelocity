function [map_mx,midi_bins] = fft2midimx(fft_size, sr, midi_min, midi_max, midi_res)

midi_bins = [midi_min-midi_res:midi_res:midi_max+midi_res];

num_midi_bins = length(midi_bins);
map_mx = zeros(num_midi_bins-2, fft_size/2+1);

fftfrqs = [0:(fft_size/2)]/fft_size*sr;

% Center freqs' on log-frequency
center_freq = midi2hz(midi_bins);

for i = 1:(num_midi_bins-2)
    
    lin_pts = center_freq(i+[0 1 2]);
    left_line = 1/(lin_pts(2)-lin_pts(1))*(fftfrqs-lin_pts(1));
    right_line = 1/(lin_pts(3)-lin_pts(2))*(lin_pts(3)-fftfrqs);
    
    map_mx(i,1+[0:(fft_size/2)]) = max(0,min(left_line, right_line));
    
    sum_map = sum(map_mx(i,:));
    
    if sum_map == 0
        map_mx(i, 1+round(lin_pts(2)/sr*fft_size)) = 1;
    else    
        map_mx(i,1+[0:(fft_size/2)]) = map_mx(i,1+[0:(fft_size/2)])/sum(map_mx(i,1+[0:(fft_size/2)]));
    end
end

midi_bins = midi_bins(2:end-1);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = midi2hz(z)

f = 440*power(2,(z-69)/12);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function z = hz2midi(f)

z = 10*log2(f/440) + 69;


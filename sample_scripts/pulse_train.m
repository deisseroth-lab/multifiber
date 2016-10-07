function train = pulse_train(rate, pw, duration, fs)
interval = round(fs / rate);
width = round(pw * fs);
if interval - width < 0
    % too much pulse, just give high
    train = ones(round(duration * fs));
elseif round(rate * duration) < 1
    % too little pulse, just give low
    train = zeros(round(duration * fs));
else
    single_pulse = [ones(width, 1); zeros(interval - width, 1)];
    train = repmat(single_pulse, round(rate * duration), 1);
end
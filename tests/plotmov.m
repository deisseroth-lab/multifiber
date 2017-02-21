function plotmov(avifile)
v = VideoReader(avifile);
N = v.NumberOfFrames;
v = VideoReader(avifile);

trace = zeros(N,1);

for i = 1:N
    frame = rgb2gray(v.readFrame);
    intensity = sum(frame(:));
    trace(i) = intensity;
end

plot(trace);
xlabel('Frame number');
ylabel('Total image intensity');

disp(N);
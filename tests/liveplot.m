data = [];
line = plot(data);

for t = 1:1000
    newdata = rand(2,1);
    data = [data; newdata'];
    plot(data);
    xlim([max(0, t-10) t]);
    pause(0.01);
end
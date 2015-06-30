n = 3;
imshow('cameraman.tif');
r = 25;
for i = 1:n
    [x,y] = ginput(1);
    h = imellipse(gca(), [x - r/2, y - r/2, r, r]);
    wait(h);
    disp(getPosition(h));
end
function [ idx ] = chIdx(s, ch)
%CHIDX Get a channel's ID in a session
channels = s.Channels;
Nch = length(channels);
for idx = 1:Nch
    if strcmp( channels(idx).ID, ch.ID)
        return
    end
end

end


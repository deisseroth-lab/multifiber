classdef RunMean
    properties(GetAccess = private, SetAccess = public)
        acc
        n
        seen
    end

    methods
        function obj = RunMean(n)
            obj.n = n;
            obj.reset();
        end

        function add(obj, val)
            obj.seen = obj.seen + 1;
            ptr = mod(obj.seen, obj.n);
            obj.acc(ptr) = val;
        end

        function m = mean(obj)
            m = mean(obj.acc(1:min(obj.n, obj.seen)));
        end

        function reset(obj)
            obj.acc = zeros(obj.n, 1);
            obj.seen = 0;
        end
    end
end

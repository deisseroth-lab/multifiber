classdef Vec < handle
    %VEC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private, GetAccess = private)
        ptr = 0
        data = []
    end
    
    properties(Dependent)
        length
    end
    
    methods
        function obj = Vec(n)
            if nargin == 1
                obj.data = zeros(n, 1);
            end
        end
        
        function append(obj, x)
            obj.ptr = obj.ptr + 1;
            if obj.ptr > length(obj.data)
                obj.grow();
            end
            obj.data(obj.ptr,1) = x;
        end
        
        function l = get.length(obj)
            l = obj.ptr;
        end
        
        function m = mean(obj)
            m = mean(obj.data(1:obj.ptr,1));
        end
        
        function reset(obj)
            obj.ptr = 0;
            obj.data = [];
        end
    end
    
    methods(Access = private)
        function grow(obj)
            len = length(obj.data);
            obj.data = [obj.data zeros(len, 1)];
        end
    end
end


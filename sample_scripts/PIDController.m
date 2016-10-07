classdef PIDController < handle
    properties (Access = public)
        P = 0
        I = 0
        D = 0
    end

    properties (Access = private)
        Iaccumulator = 0
        prev_t = -1
        prev_err = 0
    end
    
    properties (SetObservable, Access = public)
        setpt = 0
    end
    
    properties (SetObservable, GetAccess = public, SetAccess = private)
        Pterm = 0
        Iterm = 0
        Dterm = 0
    end

    methods
        function PID = PIDController(P, I, D)
            if nargin == 3
                PID.P = P;
                PID.I = I;
                PID.D = D;
            end
        end
        
        function reset_I(PID)
            PID.Iaccumulator = 0;
        end

        function final = update(PID, val, t)
            err = val - PID.setpt;
            PID.Pterm = PID.P * err;
            if PID.prev_t
                dt = (t - PID.prev_t) * 24 * 3600;
                PID.Iaccumulator = PID.Iaccumulator + err * dt;
                PID.Iterm = PID.I * PID.Iaccumulator;
                PID.Dterm = PID.D * (err - PID.prev_err) / dt;
            end
            PID.prev_t = t;
            PID.prev_err = err;
            final = PID.Pterm + PID.Iterm + PID.Dterm;
        end
    end
end
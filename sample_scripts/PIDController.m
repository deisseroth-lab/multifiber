classdef PIDController < handle
    properties (Access = public)
        P = 0
        I = 0
        D = 0
        setpt = 0
    end

    properties (Access = private)
        Iaccumulator = 0
        prev_t = -1
        prev_err = 0
    end

    methods
        function PID = PIDController()
            % pass
        end
        
        function PID = PIDController(P, I, D)
            PID.P = P;
            PID.I = I;
            PID.D = D;
        end

        function final = update(PID, val, t)
            err = val - setpt;
            final = err; % P-term
            if PID.prev_t
                dt = t - PID.prev_t;
                PID.Iaccumulator = PID.Iaccumulator + 0.5 * err * dt;
                final = final + PID.Iaccumulator; % I-term
                final = final + (err - PID.prev_err) / dt; % D-term
            end
            PID.prev_t = t;
            PID.prev_err = err;
        end
    end
end
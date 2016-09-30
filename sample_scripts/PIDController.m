classdef PIDController < handle
    properties (Access = public)
        P
        I
        D
        setpt
    end

    properties (Access = private)
        Iaccumulator
        prev_t
        prev_err
    end

    methods
        function PID = PIDController(P, I, D)
            PID.P = P;
            PID.I = I;
            PID.D = D;
            PID.setpt = 0;
            PID.Iaccumulator = 0;
            PID.prev_t = -1;
            PID.prev_err = 0;
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
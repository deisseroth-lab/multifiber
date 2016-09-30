classdef FeedbackHandler
    properties(GetAccess = private, SetAccess = private)
        session
        ao_ch
        pulse
        flat
        pid
        ctrl_signal
        basepos
        baselim = 200
        base
        setpt = 0
    end

    properties(GetAccess = public, SetAccess = public)
        % none yet
    end


    methods
        function obj = FeedBackHandler()
            % Set up recording of baseline
            obj.base = zeros(obj.baselim, 1);
            obj.basepos = 0;
            
            % Set up a PID loop
            pid = PIDController(0.001, 0.0005, 0.0005);

            % Define a pulse
            obj.pulse = [1; zeros(9, 1)];
            obj.flat = zeros(10, 1);

            % Set up the analog output
            s = daq.createSession('ni');
            daq.getDevices();
            device = devices(1);
            ch = s.addAnalogOutputChannel(device.ID, 0, 'Voltage');
            s.Rate = 100;
            s.addlistener('DataRequired', @obj.provide);

            % Start outputting
            s.startBackground();

            % Save locals to instance
            obj.session = s;
            obj.ao_ch = ch;
            obj.pid = pid;
            obj.ctrl_signal = 0;
        end

        function obj = set.setpt(obj, pt)
            obj.setpt = pt;
            obj.pid.setpt = pt;
        end
        
        function update_baseline(obj, data)
            obj.basepos = obj.basepos + 1;
            obj.base(obj.basepos, 1) = data;

        function update(obj, data, channel)
    	    % Handle fiber fluorescence intensity data from the analog inputs
            % It is safe to assume that `provide` will be called more frequently
            % than `update`, so just remember the last control signal output by
            % the PID.
            if strcmp(channel, 'signal')
                m = mean(data);
                if obj.setpt == 0
                    obj.update_baseline(m)
                    if obj.basepos == obj.baselim
                        obj.setpt = mean(obj.base);
                    end
                else
                    obj.ctrl_signal = obj.pid.update(m, now * 24 * 3600);
                end
            end
        end

        function provide(obj, src, event)
            % Handle a request to provide data to the analog output counter
            % src is a session object
            % Decide if we need a pulse by chcking the current PID loop output
            % and using the output the rate parameter through a nonlearity and
            % random variable
            nonlinearity = 1 / (1 + exp(-obj.ctrl_signal));
            if rand(1) < nonlinearity &  
                src.queueOutputData(obj.pulse);
            else
                src.queueOutputData(obj.flat);
            end
        end
	end
end

classdef SimpleHandler < handle
    properties(GetAccess = private, SetAccess = private)
        session
        ao_ch
        pulse
        flat
    end

    methods
        function obj = FeedBackHandler()
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
        end

        function update(obj, data, channel)
    	    % Handle fiber fluorescence intensity data from the analog inputs
            % It is safe to assume that `provide` will be called more frequently
            % than `update`, so just remember the last control signal output by
            % the PID.
            if strcmp(channel, 'signal')
                obj.ctrl_signal = 0;
            end
        end

        function provide(obj, src, event)
            % Handle a request to provide data to the analog output counter
            % src is a session object
            % Decide if we need a pulse by chcking the current PID loop output
            % and using the output the rate parameter through a nonlearity and
            % random variable
            nonlinearity = 1 / (1 + exp(-obj.ctrl_signal));
            if rand(1) < nonlinearity && obj.setpt ~= 0
                disp('Pulse');
                src.queueOutputData(obj.pulse);
            else
                disp('Flat');
                src.queueOutputData(obj.flat);
            end
        end
	end
end

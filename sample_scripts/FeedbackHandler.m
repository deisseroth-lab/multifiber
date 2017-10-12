classdef FeedbackHandler < handle
    properties(GetAccess = private, SetAccess = private)
        session
        ao_ch
        pulse
        flat
        recent = [] 
        last_data = -1
    end

    methods
        function obj = FeedbackHandler()
            % Define a pulse
            obj.pulse = [1; zeros(99, 1)];
            obj.flat = zeros(100, 1);

            % Set up the analog output
            s = daq.createSession('ni');
            devices = daq.getDevices();
            device = devices(1);
            ch = s.addAnalogOutputChannel(device.ID, 0, 'Voltage');
            s.Rate = 1000;
            s.IsContinuous = true;
            s.addlistener('DataRequired', @obj.provide);  

            % Save locals to instance
            obj.session = s;
            obj.ao_ch = ch;
        end
        
        function stop(obj)
            obj.session.stop();
        end

        function update(obj, data, channel)
    	    % Handle fiber fluorescence intensity data from the analog inputs
            % It is safe to assume that `provide` will be called more frequently
            % than `update`, so just remember the last control signal output by
            % the PID.
            s = obj.session;
            if ~s.IsRunning
                % Start outputting
                s.queueOutputData(repmat(obj.flat, 5, 1));
                s.startBackground();
            end
            
            if strcmp(channel, 'signal')
                obj.recent = [obj.recent mean(data)];
            end
        end

        function provide(obj, src, event)
            % Handle a request to provide data to the analog output counter
            % src is a session object
            % Decide if we need a pulse by chcking the current PID loop output
            % and using the output the rate parameter through a nonlearity and
            % random variable
            if obj.last_data > 0 && (now - obj.last_data) / 24 / 3600 > 1
                % Assume we stopped recording
                obj.stop();
            end
            
            if length(obj.recent) > 0
                x = mean(obj.recent);
                obj.recent = [];
            else
                x = 0;
            end
            nonlinearity = 1 / (1 + exp(x));
            disp(['P = ' num2str(nonlinearity)]);
            if rand(1) < nonlinearity
                disp('Pulse');
                src.queueOutputData(obj.pulse);
            else
                disp('Flat');
                src.queueOutputData(obj.flat);
            end
        end
	end
end
classdef PIDHandler < handle
    properties(GetAccess = private, SetAccess = private)
        session
        ao_ch
        pulse
        flat
        baseline
        last_data = -1
        gui
        setpt_cache = [];
        last_ctrl_signal = 0;
        ctrl_signal_buffer;
    end
    
    properties(GetAccess = public, SetAccess = public)
        pid
        acquiring_baseline = false
    end

    methods
        function obj = PIDHandler()
            % Set up PID control
            obj.pid = PIDController();
            obj.ctrl_signal_buffer = Vec();
            
            % Set up baseline capturing
            obj.baseline = Vec();
            
            % Set up the GUI
            obj.gui = pidgui(obj);
            
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
        
        function establish_baseline(obj)
            obj.pid.setpt = obj.baseline.mean();
            obj.baseline = Vec();

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
                if obj.acquiring_baseline
                    obj.baseline.append(mean(data));
                else
                    ctrl_signal = obj.pid.update(mean(data));
                    obj.ctrl_signal_buffer.append(ctrl_signal);
                end
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
                disp('No new data for 1 second, assuming recording is over');
                obj.stop();
            end
            
            if obj.ctrl_signal_buffer.length > 0
                ctrl_signal = obj.ctrl_signal_buffer.mean();
                obj.last_ctrl_signal = ctrl_signal;
            else
                ctrl_signal = obj.last_ctrl_signal;
            end
            
            nonlinearity = 1 / (1 + exp(ctrl_signal));
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

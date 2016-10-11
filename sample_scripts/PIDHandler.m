classdef PIDHandler < handle
    properties(GetAccess = private, SetAccess = private)
        session
        ao_ch
        gui
        pulse
        flat
        baseline
        acquiring_baseline = false
        last_data = -1
        last_ctrl_signal = 0
        ctrl_signal_buffer
    end

    properties(GetAccess = public, SetAccess = public)
        pid
        rate = 20
        width = 0.005
    end

    properties(SetObservable, GetAccess = public, SetAccess = private)
        current_ctrl_signal = 0
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
            ch = s.addAnalogOutputChannel(device.ID, 1, 'Voltage');
            s.Rate = 1000;
            s.IsContinuous = true;
            s.addlistener('DataRequired', @obj.provide);

            % Save locals to instance
            obj.session = s;
            obj.ao_ch = ch;
        end
        
        function set.width(obj, value)
            % milliseconds to seconds
            obj.width = value / 1000;
        end

        function stop(obj)
            obj.session.stop();
        end

        function pulse = single_pulse(obj)
            pw = obj.width;
            r = min(obj.rate, 1 / pw / 2);
            pulse = pulse_train(r, pw, 1 / r, obj.session.Rate);
        end
        
        function train = make_pulses(obj, rate)
            % Supply half a second of data.
            % Force duty cycle to be no greater than 50%
            pw = obj.width;
            rate = min(rate, 1 / pw / 2);
            train = pulse_train(rate, pw, 0.5, obj.session.Rate);
        end

        function reset_baseline(obj)
            obj.baseline = Vec();
            obj.acquiring_baseline = true;
        end

        function establish_baseline(obj)
            obj.acquiring_baseline = false;
            obj.pid.setpt = obj.baseline.mean();
            obj.pid.reset_I();
        end

        function update(obj, data, channel)
    	    % Handle fiber fluorescence intensity data from the analog inputs
            % It is safe to assume that `provide` will be called more frequently
            % than `update`, so just remember the last control signal output by
            % the PID.
            s = obj.session;
            if ~s.IsRunning
                % Start outputting with 2 seconds of nothing
                s.queueOutputData(zeros(2 * s.Rate, 1));
                s.startBackground();
            end

            if strcmp(channel, 'signal')
                obj.last_data = now;
                if obj.acquiring_baseline
                    obj.baseline.append(mean(data));
                else
                    ctrl_signal = obj.pid.update(mean(data), now);
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
            if obj.last_data > 0 && (now - obj.last_data) * 24 * 3600 > 1
                % Assume we stopped recording
                disp('No new data for 1 second, assuming recording is over');
                obj.stop();
            end

            if obj.ctrl_signal_buffer.length > 0
                ctrl_signal = obj.ctrl_signal_buffer.mean();
                obj.ctrl_signal_buffer.reset();
                obj.last_ctrl_signal = ctrl_signal;
            else
                ctrl_signal = obj.last_ctrl_signal;
            end

            obj.current_ctrl_signal = ctrl_signal;
            if rand() < ctrl_signal
                src.queueOutputData(10 * obj.single_pulse());
            else
                src.queueOutputData(10 * zeros(length(obj.single_pulse()), 1));
            end
        end
	end
end

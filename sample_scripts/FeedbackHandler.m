classdef FeedbackHandler < handle
    properties(GetAccess = private, SetAccess = private)
        session
        ao_ch
        pulse
        flat
        setpt = 0
        gui
    end

    properties(GetAccess = public, SetAccess = public)
        basepos = 0;
        base
        ctrl_signal
        pid
        setting
    end


    methods
        function obj = FeedBackHandler()
            % Set up the feedback GUI
            obj.gui = pidgui(obj);
            
            % Set up recording of baseline
            obj.base = zeros(obj.baselim, 1);
            
            % Set up a PID loop
            pid = PIDController();

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
            gui.acquire_setpt_btn.Value = str(pt);
        end
        
        function update_baseline(obj, data)
            obj.basepos = obj.basepos + 1;
            
            % Exponentially expanding matrix as per std::vector
            if obj.basepos > size(obj.base, 1);
                sz = size(obj.basepos);
                obj.base = [obj.base; zeros(sz)];
            end
            
            obj.base(obj.basepos,1) = data;
        end

        function update(obj, data, channel)
    	    % Handle fiber fluorescence intensity data from the analog inputs
            % It is safe to assume that `provide` will be called more frequently
            % than `update`, so just remember the last control signal output by
            % the PID.
            if strcmp(channel, 'signal')
                disp('updating signal');
                m = mean(data);
                if obj.setting
                    obj.update_baseline(m)
                else
                    obj.ctrl_signal = obj.pid.update(m, now * 24 * 3600);
                    obj.gui.ctrlsig_txt.Value = str(obj.ctrl_signal);
                    obj.gui.pterm_txt.Value = str(obj.pid.P);
                    obj.gui.iterm_txt.Value = str(obj.pid.I);
                    obj.gui.dterm_txt.Value = str(obj.pid.D);
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
            obj.gui.ctrlrate_txt.Value = str(nonlinearity);
            if rand(1) < nonlinearity && obj.setpt ~= 0
                src.queueOutputData(obj.pulse);
            else
                src.queueOutputData(obj.flat);
            end
        end
	end
end

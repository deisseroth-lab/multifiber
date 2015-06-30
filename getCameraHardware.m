function [ adaptorsOut, devicesOut, formatsOut, IDsOut ] = getCameraHardware()
%getCameraHardware list information about all attached cameras
%   Returns four lists, with each row refering to an available camera
%   device.
adaptorsOut = []; devicesOut = {}; formatsOut = []; IDsOut = [];
i = 0;
adaptors = imaqhwinfo();
for adaptor = adaptors.InstalledAdaptors
    devices = imaqhwinfo(adaptor{:});
    for device = devices.DeviceInfo
        for format = device.SupportedFormats
            i = i + 1;
            adaptorsOut = [adaptorsOut adaptor];
            devNameParts = strsplit(device.DeviceName, ',');
            devicesOut{i} = devNameParts{1};
            formatsOut = [formatsOut format];
            IDsOut = [IDsOut device.DeviceID];
        end
    end
end
end


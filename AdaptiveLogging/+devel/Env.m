classdef Env
    
    % Copyright 2020 The MathWorks, Inc.
    
    enumeration
        DEV   % Development
        TEST  % Test
        UAT   % User Acceptance Test
        PROD  % Production
    end
    
    properties (Constant)
        IS_PCODED logical = endsWith(which('devel.Env'),'.p')
    end
    
    methods (Static)
        function retB = isDEV()
            retB = devel.Env.isMode(devel.Env.DEV);
        end
        
        function retB = isTEST()
            retB = devel.Env.isMode(devel.Env.TEST);
        end
        
        function retB = isUAT()
            retB = devel.Env.isMode(devel.Env.UAT);
        end
        
        function retB = isPROD()
            retB = devel.Env.isMode(devel.Env.PROD);
        end
        
        function mode = getMode()
            mode = devel.Env.getSetMode();
        end
        
        function setMode(mode)
            if ischar(mode)
                mode = devel.Env.(upper(mode));
            end
            
            assert( ...
                isa(mode, 'devel.Env') && ismember(mode, enumeration('devel.Env')), ...
                'Invalid environment mode');
            
            if (mode==devel.Env.DEV) && devel.Env.IS_PCODED
                devel.Log.warn('DEV mode unavailable with pcoded software');
                return;
            end
            
            devel.Env.getSetMode(mode);
            
            % reset the log level in case the new environment has a
            % different minimal log level
            devel.Log.setLevel(devel.Log.getLevel());
        end
                
        function enableBatch()
            devel.RootFlag.set(devel.RootFlag.BATCH_MODE);
        end
        
        function disableBatch()
            devel.RootFlag.clear(devel.RootFlag.BATCH_MODE);
        end
        
        function retB = isBatch()
            retB = devel.RootFlag.get(devel.RootFlag.BATCH_MODE);
        end
    end
    
    methods (Static, Access=private)
        function retB = isMode(mode)
            arguments
                mode (1,1) devel.Env
            end
            retB = devel.Env.getSetMode()==mode;
        end
        
        function currentMode = getSetMode(newMode)
            persistent storedMode
            if nargin
                storedMode = newMode;
            elseif isempty(storedMode)
                if devel.Env.IS_PCODED
                    storedMode = devel.Env.PROD;
                else
                    storedMode = devel.Env.DEV;
                end
            end
            currentMode = storedMode;
        end
    end
end

classdef Log < Simulink.IntEnumType
    
    % Copyright 2020 The MathWorks, Inc.
    
    enumeration
        OFF (0)   % The highest possible rank and is intended to turn off logging.
        FATAL (1) % Severe errors that cause premature termination.
        ERROR (2) % Other runtime errors or unexpected conditions.
        WARN (3)  % Use of deprecated APIs, 'almost' errors, other runtime situations that are undesirable or unexpected, but not necessarily "wrong".
        INFO (4)  % Interesting runtime events (startup/shutdown). Be conservative and keep to a minimum.
        DEBUG (5) % Detailed information on the flow through the system. Expect these to be written to logs only.
        TRACE (6) % Most detailed information. Expect these to be written to logs only.
    end
    
    methods (Static)
        function level = getLevel()
            level = devel.Log.getSetLevel();
        end
        
        function setLevel(level)
            if ischar(level)
                level = devel.Log.(upper(level));
            end
            
            assert( ...
                isa(level, 'devel.Log') && ismember(level, enumeration('devel.Log')), ...
                'Invalid log level');
            
            % Enforce a minimal value in case of log level.
            % This code is mirrored in
            % scenePrefsUI.mlapp/LOG_LEVELValueChanged()
            if devel.Env.isDEV()
                % DEV
                level = devel.Log(max(level, devel.Log.WARN));
            elseif devel.Env.isTEST()
                % TEST
                level = devel.Log(max(level, devel.Log.INFO));
            elseif devel.Env.isUAT()
                % UAT
                level = devel.Log(max(level, devel.Log.WARN));
            end
            
            devel.Log.getSetLevel(level);
        end
        
        function fatal(conditionH, message, messageID)
            % fatal triggered if condition is false
            if devel.Env.isPROD() || (devel.Log.getSetLevel()<devel.Log.FATAL)
                % PROD
                return
            end
            
            assert(isa(conditionH, 'function_handle'), 'Invalid 1st argument');
            
            if conditionH()
                return
            end
            
            assert(ischar(message)||isstring(message), 'Invalid message type');
            
            if devel.Env.isDEV()
                % DEV
                warning("[ERROR] "+message);
                disp('Fatal error detected: Type dbquit to interrupt');
                keyboard;
            else
                % TEST UAT
                if nargin<3
                    messageID = 'SCENE:Error';
                end
                ME = MException(messageID, message);
                throwAsCaller(ME);
            end
        end
        
        function error(varargin)
            if devel.Env.isPROD() || (devel.Log.getSetLevel()<devel.Log.ERROR)
                % PROD
                return
            end
            pattern = repmat('%s\n', [1, numel(varargin)]);
            pattern = pattern(1:end-2);
            messageC = sprintf(pattern, varargin{:});
            if devel.Env.isDEV()
                % DEV
                warning('off', 'backtrace');
                warning(['[ERROR] ', messageC]);
                warning('on', 'backtrace');
                keyboard;
            elseif devel.Env.isTEST()
                % TEST
                ME = MException('SCENE:Error', messageC);
                throwAsCaller(ME);
            else
                % UAT
                warning('off', 'backtrace');
                warning(['[ERROR] ', messageC]);
                warning('on', 'backtrace');
                disp('Strike a key to continue...');
                pause;
            end
        end
        
        function errorDlg(messageC, titleC)
            if devel.Env.isBatch()
                return
            end
            if nargin<2
                titleC = 'ERROR';
            end
            uiwait(errordlg(messageC, titleC));
        end
        
        function warn(varargin)
            if devel.Log.getSetLevel()<devel.Log.WARN
                return
            end
            pattern = repmat('%s\n', [1, numel(varargin)]);
            pattern = pattern(1:end-2);
            % DEV TEST UAT PROD
            warning('off', 'backtrace');
            warning(pattern, varargin{:});
            warning('on', 'backtrace');
        end
        
        function warnDlg(messageC, titleC)
            if devel.Env.isBatch()
                return
            end
            if nargin<2
                titleC = 'WARNING';
            end
            devel.Log.warn(messageC);
            uiwait(warndlg(messageC, titleC, 'modal'));
        end
        
        function info(varargin)
            if devel.Log.getSetLevel()<devel.Log.INFO
                return
            end
            % DEV TEST UAT PROD
            pattern = repmat('%s\n', [1,numel(varargin)]);
            fprintf(1, ['## ', pattern], varargin{:});
        end
        
        function infoDlg(messageC, titleC)
            if devel.Env.isBatch()
                return
            end
            if nargin<2
                titleC = 'INFO';
            end
            devel.Log.info(messageC);
            createMode.WindowStyle = 'non-modal';
            createMode.Interpreter = 'tex';
            messageC = strrep(messageC, '\', '\\');
            messageC = strrep(messageC, '_', '\_');
            uiwait(msgbox(['\fontsize{12} ', messageC], titleC, 'help', createMode));
        end
        
        function debug(varargin)
            if devel.Env.isPROD() || (devel.Log.getSetLevel()<devel.Log.DEBUG)
                % PROD
                return
            end
            % DEV UAT TEST
            pattern = repmat('%s\n', [1,numel(varargin)]);
            fprintf(1, ['[%i] ', pattern], devel.Log.getCounter, varargin{:});
        end

        function trace(tagC, messageC)
            if devel.Env.isPROD() || (devel.Log.getSetLevel()<devel.Log.TRACE)
                % PROD
                return
            end
            % DEV UAT TEST
            fprintf(devel.Log.getTraceFID(), ...
                ['[%i][%s] %s', newline], ...
                devel.Log.getCounter, tagC, messageC);
        end
        
        function openTrace()
            cacheFolderC = Simulink.fileGenControl('get', 'CacheFolder');
            traceFullPathC = fullfile(cacheFolderC, 'trace.log');
            winopen(traceFullPathC);
        end
    end
    
    methods (Static, Access=private)
        function currentLevel = getSetLevel(newLevel)
            persistent storedLevel
            if nargin
                storedLevel = newLevel;
                scene.Prefs.write('LOG_LEVEL', char(storedLevel));
            elseif isempty(storedLevel)
                if devel.Env.isDEV()
                    % DEV
                    storedLevel = devel.Log.TRACE;
                elseif devel.Env.isPROD()
                    % PROD
                    storedLevel = devel.Log.WARN;
                else
                    % TEST UAT
                    storedLevel = devel.Log.INFO;
                end
                scene.Prefs.write('LOG_LEVEL', char(storedLevel));
            end
            currentLevel = storedLevel;
        end
        
        function value = getCounter()
            % counter used to number the output messages
            persistent counter
            if isempty(counter)
                counter = 1;
            else
                counter = counter+1;
            end
            value = counter;
        end
        
        function [fidOut, traceFullPathC] = getTraceFID()
            persistent fid
            % check the fid validity
            try
                ftell(fid);
            catch
                fid = [];
            end
            if isempty(fid)
                % open or create the trace file for writing
                % append data to the end of the file
                cacheFolderC = Simulink.fileGenControl('get', 'CacheFolder');
                traceFullPathC = fullfile(cacheFolderC, 'trace.log');
                fid = fopen(traceFullPathC, 'a');
            end
            fidOut = fid;
        end
    end
end

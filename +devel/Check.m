classdef Check
    
    % Copyright 2020 The MathWorks, Inc.
    
    properties (Constant, Access=private)
        TEMPDIR_FILES_MAX = 5000
        RAM_MIN = 1024^3 % bytes
    end
    
    methods (Static)
        function mustBeAString(inputS)
            % required in R2019b where mustBeA() is not available
            if ~isstring(inputS)
                if devel.Env.isDEV()
                    warning("[ERROR] String expected");
                    keyboard;
                end
                error("String expected");
            end
        end
        
        function mustBeAChar(inputC)
            % required in R2019b where mustBeA() is not available
            if ~ischar(inputC)
                if devel.Env.isDEV()
                    warning("[ERROR] Char expected");
                    keyboard;
                end
                error("Char expected");
            end
        end
        
        function assertScalarH(in)
            % test for a scalar handle, hence non empty
            if ischar(in) || ~isscalar(in) || ~ishandle(in)
                devel.Check.throwError('Handle scalar expected');
            end
        end
        
        function assertVectorH(in)
            % test for column of handles, can be empty
            if ischar(in) || (~isempty(in) && (~iscolumn(in) || ~all(ishandle(in))))
                devel.Check.throwError('Handle column expected');
            end
        end
        
        function assertRowCell(in, messageC)
            % test for a row cell array, can be empty
            if ~iscell(in) || (~isempty(in) && ~isrow(in))
                if nargin<2
                    messageC = 'Row cell array expected';
                end
                devel.Check.throwError(messageC);
            end
        end
        
        function statusB = checkTemporaryFolder()
            % check the system temp folder
            % status is true if folder OK
            if isempty(tempdir)
                statusB = true;
            else
                nbTempFiles = numel(dir(tempdir));
                statusB = nbTempFiles<=devel.Check.TEMPDIR_FILES_MAX;
                if ~statusB
                    devel.Log.warn( ...
                        ['Too many files (', num2str(nbTempFiles), ') in temporary folder "', tempdir, '"'], ...
                        'Try to empty this folder to improve MATLAB performance');
                end
            end
        end
        
        function statusB = checkPhysicalMemory()
            % check the available physical RAM memory
            % status is true if memory OK
            try
                [~, sys] = memory;
                statusB = sys.PhysicalMemory.Available>=devel.Check.RAM_MIN;
                if ~statusB
                    devel.Log.warn( ...
                        'Physical memory is getting low!', ...
                        ['Available memory (RAM) = ', ...
                        num2str(round(sys.PhysicalMemory.Available/1024^2)), ' MB']);
                end
            catch
                statusB = false;
                devel.Log.warn('Physical memory check failed');
            end
        end
    end
    
    methods (Static, Access=private)
        function throwError(errMsgC)
            stack = dbstack('-completenames');
            msgS = string(errMsgC)+newline;
            for idx = 3:numel(stack)
                item = stack(idx);
                linkC = ['<a href="matlab:edit(''',item.file,''')">',item.name,'</a>'];
                msgS = msgS + string(linkC) + " L" + item.line + newline;
            end
            devel.Log.warn(msgS);
            error(errMsgC);
        end
    end
end

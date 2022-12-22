classdef SetParam < handle
    % Stacked implementation of set_param()
    
    % Copyright 2019-2022 The MathWorks, Inc.
    
    properties (Access=private)
        handle double = -1
        stack
    end
    
    methods
        function this = SetParam(handle)
            this.stack = {};
            if nargin
                this.handle = handle;
            end
        end
        
        function stack = getStack(this)
            stack = this.stack;
        end
                
        function clear(this)
            this.stack = {};
        end
        
        function push(this, paramName, paramValue)
            this.stack = [this.stack, {paramName; paramValue}];
        end
        
        function hasChangedB = update(this, paramName, paramValue)
            % similar to push but check if the value changes
            assert(ishandle(this.handle), 'Target handle undefined');
            
            currentValue = get_param(this.handle, paramName);
            
            if ~isempty(this.stack)
                idx = strcmp(this.stack(1, :), paramName);
                isInStackB = any(idx);
                if isInStackB
                    % parameter was previously stacked
                    refValue = this.stack{2, idx};
                else
                    % parameter not stacked yet
                    refValue = currentValue;
                end
            else
                isInStackB = false;
                refValue = currentValue;
            end
            
            hasChangedB = ~isequal(refValue, paramValue);
            
            if hasChangedB
                if isInStackB
                    if isequal(paramValue, currentValue)
                        % remove the useless request
                        this.stack = this.stack(:, ~idx);
                    else
                        % update the stacked value
                        this.stack{2, idx} = paramValue;
                    end
                else
                    % stack the value
                    this.push(paramName, paramValue);
                end
            end
        end
        
        function disp(this)
            disp(this.stack');
        end
        
        function apply(this, handle)
            if nargin>1
                assert(~ishandle(this.handle), 'Target handle already defined');
                this.handle = handle;
            end
            if ~isempty(this.stack)
                set_param(this.handle, this.stack{:});
                
                % empty the stack after applying the changes
                this.stack = {};
            end
        end
    end
end

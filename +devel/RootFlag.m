classdef RootFlag
    % Root flags identifiers must be declared in an enumeration class
    % named "DevelFlagValue", see the example in DevelFlagValue_example.m
    
    % Copyright 2016-2023 The MathWorks, Inc.
    
    methods (Static)
        function retB = isDefined(flagS)
            arguments
                flagS (1,1) string
            end
            root = groot;
            retB = isfield(root.UserData, flagS);
        end
        
        function valueB = get(flagS)
            arguments
                flagS (1,1) string = string(DevelRootFlag.UNDEF)
            end
            valueB = false;
            if ~nargin
                [~, flags] = enumeration('DevelRootFlag');
                cellfun(@(x) disp(x+" = "+devel.RootFlag.get(DevelRootFlag.(x))), flags);
                return
            end
            root = groot;
            if isfield(root.UserData, flagS)
                valueB = root.UserData.(flagS);
            end
        end
        
        function set(flagS, valueB)
            arguments
                flagS (1,1) string
                valueB (1,1) logical = true
            end
            root = groot;
            root.UserData.(flagS) = valueB;
        end
        
        function clear(flagS)
            arguments
                flagS (1,1) string
            end
            root = groot;
            root.UserData.(flagS) = false;
        end
        
        function reset()
            arrayfun(@(x) devel.RootFlag.clear(x), enumeration('DevelRootFlag'));
        end
    end
end

classdef RootValue
    % Root values identifiers must be declared in an enumeration class
    % named "DevelRootValue", see the example in DevelRootValue_example.m
    
    % Copyright 2019-2023 The MathWorks, Inc.
    
    methods (Static)
        function retB = isDefined(flagS)
            arguments
                flagS (1,1) string
            end
            root = groot;
            retB = isfield(root.UserData, flagS);
        end
        
        function value = get(flagS)
            arguments
                flagS (1,1) string
            end
            value = nan;
            root = groot;
            if isfield(root.UserData, flagS)
                value = root.UserData.(flagS);
            end
        end
        
        function set(flagS, value)
            arguments
                flagS (1,1) string
                value
            end
            root = groot;
            root.UserData.(flagS) = value;
        end
    end
end

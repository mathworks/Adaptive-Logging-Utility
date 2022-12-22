classdef RootValue
    % Root values identifiers must be declared in an enumeration class
    % named "DevelRootValue", see the example in DevelRootValue_example.m

    % Copyright 2019-2022 The MathWorks, Inc.
    
    methods (Static)
        function retB = isDefined(flag)
            arguments
                flag (1,1) DevelRootValue
            end
            root = groot;
            retB = isfield(root.UserData, char(flag));
        end
        
        function value = get(flag)
            arguments
                flag (1,1) DevelRootValue
            end
            value = nan;
            root = groot;
            nameC = char(flag);
            if isfield(root.UserData, nameC)
                value = root.UserData.(nameC);
            end
        end
        
        function set(flag, value)
            arguments
                flag (1,1) DevelRootValue
                value
            end
            root = groot;
            root.UserData.(char(flag)) = value;
        end
    end
end

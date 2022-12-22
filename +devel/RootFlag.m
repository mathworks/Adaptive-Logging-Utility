classdef RootFlag
    % Root flags identifiers must be declared in an enumeration class
    % named "DevelFlagValue", see the example in DevelFlagValue_example.m

    % Copyright 2016-2021 The MathWorks, Inc.

    methods (Static)
        function retB = isDefined(flag)
            arguments
                flag (1,1) DevelRootFlag
            end
            root = groot;
            retB = isfield(root.UserData, char(flag));
        end

        function valueB = get(flag)
            arguments
                flag (1,1) DevelRootFlag
            end
            valueB = false;
            if ~nargin
                [~, flags] = enumeration('DevelRootFlag');
                cellfun(@(x) disp(x+" = "+devel.RootFlag.get(DevelRootFlag.(x))), flags);
                return
            end
            root = groot;
            nameC = char(flag);
            if isfield(root.UserData, nameC)
                valueB = root.UserData.(nameC);
            end
        end

        function set(flag, valueB)
            arguments
                flag (1,1) DevelRootFlag
                valueB (1,1) logical = true
            end
            root = groot;
            root.UserData.(char(flag)) = valueB;
        end

        function clear(flag)
            arguments
                flag (1,1) DevelRootFlag
            end
            root = groot;
            root.UserData.(char(flag)) = false;
        end

        function reset()
            arrayfun(@(x) devel.RootFlag.clear(x), enumeration('DevelRootFlag'));
        end
    end
end

classdef RootValue
    
    % Copyright 2019-2020 The MathWorks, Inc.
    
    enumeration
        % Declare your VALUES identifiers here
        
        DUMMY_LABEL
        
        % SCENE specific
        
        ANIMATION_STYLER
        ITEM_STYLER
        SCENARIO_CLOSED_LISTENER_TOKEN
    end
    
    methods (Static)
        function retB = isDefined(flag)
            arguments
                flag (1,1) devel.RootValue
            end
            root = groot;
            retB = isfield(root.UserData, char(flag));
        end
        
        function value = get(flag)
            arguments
                flag (1,1) devel.RootValue
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
                flag (1,1) devel.RootValue
                value
            end
            root = groot;
            root.UserData.(char(flag)) = value;
        end
    end
end

classdef RootFlag
    
    % Copyright 2016-2020 The MathWorks, Inc.
    
    enumeration
        % Declare your FLAGS identifiers here
        
        BATCH_MODE

        DUMMY_LABEL
        
        % SCENE specific
        
        SCENE_IS_STARTED
        
        IGNORE_ACTIVITY_COPYFCN
        IGNORE_ACTIVITY_PREDELETEFCN
        IGNORE_ACTIVITY_PRESAVEFCN
        IGNORE_ACTIVITY_MASKINIT
        
        IGNORE_MODEL_CLOSEFCN
        IGNORE_MODEL_INITFCN
        
        IGNORE_NODES_REFRESH
        
        CLOSE_EDITOR_SILENTLY
        
        REVIEW_REPOSITORY				% Repository.review() is running
        MIGRATE_ACTIVITIES				% migration is running
    end
    
    methods (Static)
        function retB = isDefined(flag)
            arguments
                flag (1,1) devel.RootFlag
            end
            root = groot;
            retB = isfield(root.UserData, char(flag));
        end
        
        function valueB = get(flag)
            arguments
                flag (1,1) devel.RootFlag
            end
            valueB = false;
            if ~nargin
                [~, flags] = enumeration('devel.RootFlag');
                cellfun(@(x) disp(x+" = "+devel.RootFlag.get(devel.RootFlag.(x))), flags);
                return;
            end
            root = groot;
            nameC = char(flag);
            if isfield(root.UserData, nameC)
                valueB = root.UserData.(nameC);
            end
        end
        
        function set(flag, valueB)
            arguments
                flag (1,1) devel.RootFlag
                valueB (1,1) logical = true
            end
            root = groot;
            root.UserData.(char(flag)) = valueB;
        end
        
        function clear(flag)
            arguments
                flag (1,1) devel.RootFlag
            end
            root = groot;
            root.UserData.(char(flag)) = false;
        end
        
        function reset()
            arrayfun(@(x) devel.RootFlag.clear(x), enumeration('devel.RootFlag'));
        end
    end
end

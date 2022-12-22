classdef Base
    
    % Copyright 2020-2021 The MathWorks, Inc.
    
    methods (Static)
        function pushDir(folderS)
            arguments
                folderS (1,1) string
            end
            if startsWith(folderS, filesep) || contains(folderS, ':')
                targetS = folderS;
            else
                targetS = fullfile(string(pwd), folderS);
            end
            devel.Log.fatal(@()(exist(targetS, 'dir')==7), "Folder not found: "+targetS);
            devel.Base.getSetDir(string(pwd));
            cd(folderS);
        end
        
        function popDir()
            folderS = devel.Base.getSetDir();
            if folderS==""
                return
            end
            devel.Log.fatal(@()(exist(folderS, 'dir')==7), "Folder not found: "+folderS);
            cd(folderS);
        end
    end
    
    methods (Static, Access=private)
        function folderS = getSetDir(folderS)
            % used by pushDir() and popDir()
            arguments
                folderS (1,1) string = ""
            end
            
            persistent folderStackS
            if isempty(folderStackS)
                if nargin  % push
                    folderStackS = folderS;
                else  % pop
                    folderS = "";
                end
            else
                if nargin  % push
                    folderStackS = [folderStackS, folderS];
                else  % pop
                    folderS = folderStackS(end);
                    folderStackS = folderStackS(1:end-1);
                end
            end
        end
    end
end

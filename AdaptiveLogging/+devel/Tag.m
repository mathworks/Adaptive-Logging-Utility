classdef Tag < handle
	
	% Copyright 2018-2020 The MathWorks, Inc.
	
	properties (Access = private)
		obj
		tags
		values
	end
	
	methods
		function this = Tag(block)
			this.tags = {};
			this.values = {};
			if ~nargin
				this.obj = [];
				return;
			end
			switch class(block)
				case 'char'
					this.obj = get_param(block, 'Object');
				case 'double'
					if ishandle(block) % Simulink
						this.obj = get_param(block, 'Object');
					else % Stateflow
						Root = sfroot;
						this.obj = Root.idToHandle(block);
					end
				otherwise
					this.obj = block;
			end
			if isempty(this.obj.Tag)
				this.obj.Tag = '';
			end
			tokens = regexp(this.obj.Tag, '\[(\w+=?[\w \.]*)\]', 'tokens');
			for idx = 1:numel(tokens)
				token = tokens{idx};
				[tagC, valueC] = strtok(token{1}, '=');
				this.tags = [this.tags, tagC];
				if isempty(valueC)
					this.values = [this.values, NaN];
				elseif strcmp(valueC, '=')
					this.values = [this.values, {''}];
				else
					this.values = [this.values, valueC(2:end)];
				end
			end
		end
		
		function disp(this)
			if isempty(this.obj)
				disp('No block object stored');
			else
				disp(['Block: "', this.obj.Name, '"']);
			end
			if isempty(this.tags)
				disp('No tags stored');
			else
				for idx = 1:numel(this.tags)
					value = this.values{idx};
					if isnan(value)
						disp(['[', this.tags{idx}, ']']);
					else
						disp(['[', this.tags{idx}, ']=', value]);
					end
				end
			end
		end
		
		function flag = exist(this, tag)
			if nargin<2
				flag = ~isempty(this.tags);
			else
				flag = ismember(tag, this.tags);
			end
		end
		
		function value = get(this, tag)
			idx = strcmp(tag, this.tags);
			if ~any(idx)
				value = NaN;
			else
				value = this.values(idx);
				if numel(value)==1
					value = value{1};
				end
				if numel(value)==0
					value = '';
				end
			end
		end
		
		function newValue = set(this, tag, newValue)
			if ~ismember(tag, this.tags)
				devel.Log.warn(['Tag "', tag, '" not found']);
				newValue = NaN;
				return;
			end
			idx = find(strcmp(tag, this.tags));
			currentValue = this.values{idx};
			assert(ischar(currentValue)||~isnan(currentValue), ['Cannot set a value for tag "', tag, '"']);
			assert(ischar(currentValue), 'Value should be a string');
			this.values{idx} = newValue;
		end
		
		function n = size(this)
			n = numel(this.tags);
		end
		
		function add(this, newTagC, newValue)
			if nargin<3
				newValue = NaN;
			end
			if ismember(newTagC, this.tags)
				devel.Log.warn(['Tag "', newTagC, '" already defined']);
				return;
			end
			assert(ischar(newValue)||isnan(newValue), 'Value should be a string');
			this.tags{end+1} = newTagC;
			this.values{end+1} = newValue;
			this.exportTags;
		end
		
		function remove(this, removedTagC)
			if nargin<2
				this.tags = {};
				this.values = {};
			else
				[this.tags, idx] = setdiff(this.tags, removedTagC);
				this.values = this.values(idx);
			end
			this.exportTags;
		end
	end
	
	methods (Access=private)
		function exportTags(this)
			tagC = '';
			for idx = 1:numel(this.tags)
				tagC = [tagC, '[', this.tags{idx}]; %#ok<*AGROW>
				if ~isnan(this.values{idx})
					tagC = [tagC, '=', this.values{idx}];
				end
				tagC = [tagC, ']'];
			end
			this.obj.Tag = tagC;
		end
	end
end

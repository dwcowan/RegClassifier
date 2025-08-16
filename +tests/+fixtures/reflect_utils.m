function utils = reflect_utils
%REFLECT_UTILS Reflection helpers for tests.
%   Provides lightweight utilities to inspect class and method presence
%   without executing any business logic.

utils.classExists = @classExists;
utils.methodExists = @methodExists;
utils.missingArgumentsBlocks = @missingArgumentsBlocks;
end

function tf = classExists(className)
tf = exist(className,'class') == 8;
end

function tf = methodExists(className, methodName)
if ~classExists(className)
    tf = false;
    return;
end
mc = meta.class.fromName(className);
tf = any(strcmp({mc.MethodList.Name}, methodName));
end

function missing = missingArgumentsBlocks(className)
missing = {};
file = which(className);
if isempty(file); return; end
text = fileread(file);
funcStarts = regexp(text,'\nfunction','start');
funcStarts = [funcStarts numel(text)+1];
for i=1:numel(funcStarts)-1
    segment = text(funcStarts(i):funcStarts(i+1)-1);
    token = regexp(segment,'function\s+(?:[^\n=]*=\s*)?(\w+)\s*\(','tokens','once');
    if isempty(token); continue; end
    name = token{1};
    if ~contains(segment,'arguments')
        missing{end+1} = name; %#ok<AGROW>
    end
end
end

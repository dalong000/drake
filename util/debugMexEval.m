function varargout = debugMexEval(fun,varargin)
% syntax is equavalent to feval, but this routine writes the inputs to a
% .mat file, which can be loaded and run from a standalone application to
% help debug mex files. 
%
% Note: on mac, I needed to do the following to run debugMex from the
% command line:
%  export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/Applications/MATLAB_R2014a.app/bin/maci64
%  export DYLD_FORCE_FLAT_NAMESPACE=1
%  export DYLD_INSERT_LIBRARIES=PATH_TO_DRAKE/pod-build/lib/libdrakeDebugMex.dylib 
% I've put these into debugMex.sh (use "source debugMex.sh" at the command
% line)
%
% on another platform, you presumably need to:
%  export LD_PRELOAD=libdrakeDebugMex.so
%  export LD_LIBRARY_PATH=PATH_TO_DRAKE/pod-build/lib/:$LD_LIBRARY_PATH%  
% but this is untested (so far)

% note: adding the -DMX_COMPAT_32 changed my symbol from _mxGetProperty_730
% to _mxGetProperty_700, which is what I needed

% debugMex executable needs to keep a global table and fills in the right
% pointer.  will need to handle the case that this pointer does not exists,
% and give a useful warning so that people put a debugMexEval around the
% function that creates that pointer, as well. 
%
% note: it appears that the matrix library cannot load matlab class objects
% with the matlab engine disconnected.  The work-around is that I write out the 
% class objects passed in here as structures, and the debugMex executable 
% overloads the mxGetProperty method using this technique: 
%   http://www.ibm.com/developerworks/library/l-glibc/index.html
%   https://blogs.oracle.com/DatabaseEmporium/entry/where_is_ld_preload_under
% sigh.  

typecheck(fun,'char');

% logic to keep track of individual function calls
persistent count;
if isempty(count), 
  count = 1;
  appendstr = '';
else
  count = count+1;
  appendstr = '-append';
end
countstr = sprintf('%d',count);  
if (length(countstr)>5) error('oops.  need to increase the count limit'); end
countstr=[repmat('0',1,5-length(countstr)),countstr];

% convert classes to structures, so that they can be loaded without the
% matlab engine attached.  (note: i don't feel like I should have to do
% this!)
% todo: need to do this recursively (e.g, for properties that are classes)
S = warning('off');
for i=1:length(varargin)
  varargin_to_write{i} = obj2struct(varargin{i});
end
warning(S);

% Write out consequitive calls with the notation nrhs_0001, etc.
eval(sprintf('fun_%s = which(fun);',countstr));
eval(sprintf('nrhs_%s = length(varargin);',countstr));
eval(sprintf('nlhs_%s = nargout;',countstr));
eval(sprintf('varargin_%s = varargin_to_write;',countstr));
eval(sprintf('save([''/tmp/mex_debug.mat''],''fun_%s'',''nrhs_%s'',''nlhs_%s'',''varargin_%s'',''%s'')',countstr,countstr,countstr,countstr,appendstr));

varargout=cell(1,nargout);
[varargout{:}] = feval(fun,varargin{:});


end


function s = obj2struct(obj)

if isobject(obj)
  for i=1:numel(obj)  % support obj arrays
    s(i) = struct(obj(i));
  end
  if isfield(s,'debug_mex_classname')
    error('i assumed that you didn''t use this as a property name');
  end
  [s.debug_mex_classname] = deal(class(obj));
else
  s = obj;
end

if isstruct(s)
  f = fieldnames(s);
  for i=1:numel(s)
    for j=1:numel(f)
      s(i).(f{j})=obj2struct(s(i).(f{j}));
    end
  end
end

end
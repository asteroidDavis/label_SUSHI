classdef SysText
    %SysText A module for system dependent text functions
    %   newLine() -gets the system new line character using a java dependency
    
    properties
    end
    
    methods(Static)
        %Returns the systems new line characters
        function newLineCharacter = newLine()
            newLineCharacter = char(java.lang.System.getProperty...
                ('line.separator'));
        end
    end
    
end


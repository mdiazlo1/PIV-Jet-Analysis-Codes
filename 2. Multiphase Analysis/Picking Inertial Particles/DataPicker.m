function [selectedXData, selectedYData] = DataPicker(hFig,hPlot)
   
%     title("Hold shift and select all particles of interest then close the window to finish")
    
    % create and enable the brush object
    hBrush = brush(hFig);
    hBrush.ActionPostCallback = @OnBrushActionPostCallback;
    hBrush.Enable = 'on';
    
    selectedXData = [];
    selectedYData = [];
    
    uiwait

    % turn off the brush
    
    function OnBrushActionPostCallback(~, ~)
       
        xData = hPlot.XData;
        yData = hPlot.YData;
        brushedDataIndices = hPlot.BrushData;

        
        selectedXData = [xData(logical(brushedDataIndices))];
        selectedYData = [yData(logical(brushedDataIndices))];
        
        
    end
end
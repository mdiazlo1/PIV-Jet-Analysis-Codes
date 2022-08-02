classdef ParticleDiameter
    %This class is used to be able to obtain the particle diameter and
    %design the grid to be used for PIV and PTV interpolation

    properties
        GridType
        DiameterBuffer
        IntWinSize
        avgDiameter
        DiameterOfParticle
        ParticleLocationX
        ParticleLocationY
    end

    methods
        function obj = ParticleDiameter(GridType,DiameterBuffer,IntWinSize,avgDiameter,DiameterOfParticle,ParticleLocationX,ParticleLocationY) %This is my constructor
            obj.GridType = GridType;
            obj.DiameterBuffer = DiameterBuffer;
            obj.IntWinSize = IntWinSize;
            obj.avgDiameter = avgDiameter;
            obj.DiameterOfParticle = DiameterOfParticle;
            obj.ParticleLocationX = ParticleLocationX;
            obj.ParticleLocationY = ParticleLocationY;
        end
        function [D_HL,D_HR,D_VUP,D_VD] = GridSpacing(obj) %This is to obtain grid spacing
            switch obj.GridType
                case 'Constant Diameter'
                    D_HL = ceil(48/obj.IntWinSize);%Number of interrogation windows to the left; 12 for intwin 4
                    D_HR = ceil(56/obj.IntWinSize); %Number of interrogation windows to the right; 24 for intwin 4
                    D_VUP = ceil(32/obj.IntWinSize); %Number of inerrogation windows above the particle; 8 for intwin 4
                    D_VD = ceil(32/obj.IntWinSize); %Number of interrogation; 8 for intwin 4
                case 'Deformable Diameter'
                    D_HL = ceil((28+obj.avgDiameter + obj.DiameterBuffer)/obj.IntWinSize);%Number of interrogation windows to the left; 12 for intwin 4
                    D_HR = ceil((36+obj.avgDiameter + obj.DiameterBuffer)/obj.IntWinSize); %Number of interrogation windows to the right; 24 for intwin 4
                    D_VUP = ceil((12+obj.avgDiameter + obj.DiameterBuffer)/obj.IntWinSize); %Number of inerrogation windows above the particle; 8 for intwin 4
                    D_VD = ceil((12+obj.avgDiameter + obj.DiameterBuffer)/obj.IntWinSize); %Number of interrogation; 8 for intwin 4
            end
        end
        function [LeftBound,RightBound,UpperBound,LowerBound,Diameter] = GridEdges(obj)
            [D_HL,D_HR,D_VUP,D_VD] = GridSpacing(obj);
            switch obj.GridType
                case 'Constant Diameter'
                    Diameter = obj.avgDiameter+obj.DiameterBuffer; %pix
                    LeftBound = ceil(obj.ParticleLocationX - Diameter/2 - D_HL*obj.IntWinSize);
                    RightBound = ceil(obj.ParticleLocationX + Diameter/2+D_HR*obj.IntWinSize);
                    UpperBound = ceil(obj.ParticleLocationY + Diameter/2+D_VUP*obj.IntWinSize);
                    LowerBound = ceil(obj.ParticleLocationY - Diameter/2 - D_VD*obj.IntWinSize);
                case 'Deformable Diameter'
                    Diameter = obj.DiameterOfParticle+obj.DiameterBuffer; %pix
                    LeftBound = ceil(obj.ParticleLocationX - D_HL*obj.IntWinSize);
                    RightBound = ceil(obj.ParticleLocationX+D_HR*obj.IntWinSize);
                    UpperBound = ceil(obj.ParticleLocationY+D_VUP*obj.IntWinSize);
                    LowerBound = ceil(obj.ParticleLocationY - D_VD*obj.IntWinSize);
            end
        end
    end
end
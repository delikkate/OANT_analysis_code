function [dicomFolderVec, nVol, date, dicomFolderNum] = getDicomFolderVec(subNum, sesNum)
%last change: 2016-12-23 KD

switch subNum
    case {1}
        if sesNum == 1
            dicomFolderVec = [10 14 18 22 27 31 35 39]; % vector with numeric prefixes of folders containing data from 8 functional runs
            nVol = [141 137 137 141 137 136 136 138]; % how many volumes (=how many DICOM files) are in each of these functional folders
            dicomFolderNum = 6; % numeric prefix of the folder containing anatomical data
            date = '201508191010'; % session date formatted as yyyymmddhhmm (copied from the session folder name)
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 26 30 34 38];
            nVol = [137 136 136 138 135 137 141 137];
            dicomFolderNum = 6;
            date = '201509021200';
        end
        
        
    case {2}
        if sesNum == 1
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [133 137 137 140 133 135 136 141];
            dicomFolderNum = 6;
            date = '201510210810';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 26 30 34 38];
            nVol = [138 133 135 138 137 138 134 141];
            dicomFolderNum = 6;
            date = '201511030810';
        end
        
        
    case {3}
        if sesNum == 1
            dicomFolderVec = [10 14 18 26 31 35 39 43];
            nVol = [135 138 136 137 131 137 141 139];
            dicomFolderNum = 6;
            date = '201510211000';
        elseif sesNum == 2
            dicomFolderVec = [12 17 21 25 29 33 37 41];
            nVol = [137 135 137 138 140 134 136 134];
            dicomFolderNum = 8;
            date = '201511050800';
        end
        
        
        case {4}
        if sesNum == 1
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [135 135 135 135 134 144 136 140];
            dicomFolderNum = 2;
            date = '201511031010';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 26 32 36 40];
            nVol = [137 137 132 135 138 135 137 138];
            dicomFolderNum = 2;
            date = '201511170810';
        end
        
        
        case {5}
        if sesNum == 1
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [138 136 140 139 139 138 137 135];
            dicomFolderNum = 6;
            date = '201511050950';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 26 30 34 38];
            nVol = [138 136 139 136 139 142 135 140];
            dicomFolderNum = 6;
            date = '201511171040';
        end
        
        
        
        case {6}
        if sesNum == 1
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [141 137 137 133 132 139 137 137];
            dicomFolderNum = 2;
            date = '201511171220';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 26 30 34 38];
            nVol = [135 138 136 140 132 139 136 139];
            dicomFolderNum = 2;
            date = '201512031000';
        end
        
        
        case {7}
        if sesNum == 1
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [136 141 138 138 138 135 139 135];
            dicomFolderNum = 2;
            date = '201512021210';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 26 30 34 38];
            nVol = [137 138 136 141 139 136 135 137];
            dicomFolderNum = 2;
            date = '201512171010';
        end
        
        
        
        case {8}
        if sesNum == 1
            dicomFolderVec = [10 16 20 24 31 35 39 43];
            nVol = [135 142 136 137 133 138 136 139];
            dicomFolderNum = 2;
            date = '201512101140';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 26 30 34 38];
            nVol = [135 132 135 138 140 131 136 139];
            dicomFolderNum = 2;
            date=('201512230840');
        end
        
        
        case {9}
        if sesNum == 1
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [138 135 136 133 131 135 133 139];
            dicomFolderNum = 2;
            date = '201602050820';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 26 30 34 38];
            nVol = [135 134 138 133 137 139 135 137];
            dicomFolderNum = 2;
            date = '201602190820';
        end
        
        
        case {10}
        if sesNum == 1
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [134 139 138 138 134 140 135 140];
            dicomFolderNum = 2;
            date = '201602051010';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 26 30 34 38];
            nVol = [136 141 140 139 138 132 134 138];
            dicomFolderNum = 2;
            date = '201602191010';
        end
        
        
        case {11}
        if sesNum == 1
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [136 137 138 138 134 134 133 137];
            dicomFolderNum = 2;
            date = '201602051210';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 26 32 36 40];
            nVol = [136 137 136 139 133 140 136 139];
            dicomFolderNum = 2;
            date = '201602191210';
        end
        
        
        case {12}
        if sesNum == 1
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [137 134 135 137 134 139 137 136];
            dicomFolderNum = 2;
            date = '201606090810';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 26 30 34 38];
            nVol = [138 134 140 139 134 140 137 136];
            dicomFolderNum = 2;
            date = '201606230830';
        end
        
        
        case {13}
        if sesNum == 1
            dicomFolderVec = [15 19 23 27]; % we acquired only 4 runs in this session
            nVol = [136 134 132 136];
            dicomFolderNum = 2;
            date = '201602151010';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 26 30 34 38];
            nVol = [136 139 134 136 134 135 135 134];
            dicomFolderNum = 2;
            date = '201602291000';
        end
        
        
        case {14}
        if sesNum == 1
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [140 139 137 140 133 135 138 132];
            dicomFolderNum = 2;
            date = '201602151150';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 26 30 34 38];
            nVol = [133 136 140 134 138 138 138 135];
            dicomFolderNum = 2;
            date = '201602291210';
        end
        
        
        case {15} % excluded due to excessive head motion
        if sesNum == 1
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [138 137 138 135 140 136 137 139];
            dicomFolderNum = 2;
            date = '201605170810';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [136 136 136 139 141 135 140 137];
            dicomFolderNum = 2;
            date = '201606010820';
        end        
        
        
        case {16}
        if sesNum == 1
            dicomFolderVec = [10 18 22 26 31 35 39 43];
            nVol = [139 139 137 137 137 135 135 139];
            dicomFolderNum = 2;
            date = '201605171000';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 26 30 34 38];
            nVol = [138 137 133 134 140 138 136 137];
            dicomFolderNum = 2;
            date = '201606010950';
        end  
        
        
        case {17}
        if sesNum == 1
            dicomFolderVec = [10 14 18 24 29 33 37 41];
            nVol = [136 135 140 136 134 134 139 139];
            dicomFolderNum = 2;
            date = '201605171200';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 26 30 34 38];
            nVol = [134 136 135 137 138 142 135 141];
            dicomFolderNum = 2;
            date = '201606011200';
        end  
        
        
        case {18} % excluded due to excessive head motion
        if sesNum == 1
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [137 135 136 132 130 135 139 135];
            dicomFolderNum = 2;
            date = '201602150810';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 26 30 34 38];
            nVol = [138 136 136 136 142 137 134 136];
            dicomFolderNum = 2;
            date = '201602290810';
        end
        

        case {19}
        if sesNum == 1
            dicomFolderVec = [10 14 18 22 29 33 37 41];
            nVol = [139 138 132 134 140 136 136 138];
            dicomFolderNum = 2;
            date = '201612060800';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [135 136 135 140 135 141 138 136];
            dicomFolderNum = 2;
            date = '201612200810';
        end
        
        
        case {20}
        if sesNum == 1
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [134 138 136 135 136 134 139 134];
            dicomFolderNum = 2;
            date = '201612061120';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [140 136 134 137 136 138 138 135];
            dicomFolderNum = 2;
            date = '201612201000';
        end
        
        
        case {21}
        if sesNum == 1
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [139 132 139 135 137 140 137 139];
            dicomFolderNum = 2;
            date = '201612070800';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [133 136 135 140 132 137 131 136];
            dicomFolderNum = 2;
            date = '201612210800';
        end
        
        
        case {22}
        if sesNum == 1
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [137 136 136 137 137 139 135 135];
            dicomFolderNum = 2;
            date = '201612071210';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [138 138 138 141 138 135 138 136];
            dicomFolderNum = 2;
            date = '201612211210';
        end
        
        
        case {23} % excluded due to non-compliance with training protocol
        if sesNum == 1
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [138 141 137 137 138 136 132 140];
            dicomFolderNum = 2;
            date = '201612070810';
        elseif sesNum == 2
            dicomFolderVec = [10 14 18 22 27 31 35 39];
            nVol = [136 138 136 139 137 134 139 138];
            dicomFolderNum = 2;
            date = '201612210950';
        end
        
          
    otherwise
        dicomFolderVec = [];
        nVol = [];
        error('Unspecified dicomFolderVec');
end


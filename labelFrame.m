function L_Frame = labelFrame(inputFrame)
[row,cln] = size(inputFrame);
L_Frame = uint8(inputFrame);
newLabel = 0;
C = [];
for rw = 1:row
    for cl = 1:cln
        if L_Frame(rw,cl) ~= 0
            if rw == 1 && cl == 1
                newLabel = newLabel + 1;
                C = [C newLabel];
                lx = newLabel;
            elseif rw == 1 && cl == 2
                lq = L_Frame(rw,cl-1);
                if lq ~= 0
                    lx = lq;
                else
                    newLabel = newLabel + 1;
                    C = [C newLabel];
                    lx = newLabel;
                end
            elseif rw == 1 && cl > 2
                lq = L_Frame(rw,cl-1);
                ls = L_Frame(rw,cl-2);
                if lq ~= 0
                    lx = lq;
                elseif ls ~= 0
                    lx = ls;
                else
                    newLabel = newLabel + 1;
                    C = [C newLabel];
                    lx = newLabel;
                end
            elseif rw == 2 && cl == 1
                lp = L_Frame(rw-1,cl);
                if lp ~= 0
                    lx = lp;
                else
                    newLabel = newLabel + 1;
                    C = [C newLabel];
                    lx = newLabel;
                end
            elseif rw == 2 && cl == 2
                lp = L_Frame(rw-1,cl);
                lq = L_Frame(rw,cl-1);
                if lp ~= lq && lp ~= 0 && lq ~= 0
                    lx = lp;
                    lt = lq;
                    for k = 1:length(C)
                        if C(k) == lt
                            C(k) = C(lp);
                            ind = L_Frame == lq;
                            L_Frame(ind) = C(k);
                        end
                    end
                elseif lp ~= 0
                    lx = lp;
                elseif lq ~= 0
                    lx = lq;
                else
                    newLabel = newLabel + 1;
                    C = [C newLabel];
                    lx = newLabel;
                end
            elseif rw == 2 && cl > 2
                lp = L_Frame(rw-1,cl);
                lq = L_Frame(rw,cl-1);
                ls = L_Frame(rw,cl-2);
                if lp ~= lq && lp ~= 0 && lq ~= 0
                    lx = lp;
                    lt = lq;
                    for k = 1:length(C)
                        if C(k) == lt
                            C(k) = C(lp);
                            ind = L_Frame == lq;
                            L_Frame(ind) = C(k);
                        end
                    end
                elseif lp ~= ls && lp ~= 0 && lq == 0 && ls ~= 0
                    lx = lp;
                    lt = ls;
                    for k = 1:length(C)
                        if C(k) == lt
                            C(k) = C(lp);
                            ind = L_Frame == ls;
                            L_Frame(ind) = C(k);
                        end
                    end
                elseif lp ~= 0
                    lx = lp;
                elseif lq ~= 0
                    lx = lq;
                elseif ls ~= 0
                    lx = ls;
                else
                    newLabel = newLabel + 1;
                    C = [C newLabel];
                    lx = newLabel;
                end
            elseif rw > 2 && cl == 1
                lp = L_Frame(rw-1,cl);
                lr = L_Frame(rw-2,cl);
                if lp ~= 0
                    lx = lp;
                elseif lr ~= 0
                    lx = lr;
                else
                    newLabel = newLabel + 1;
                    C = [C newLabel];
                    lx = newLabel;
                end
            elseif rw > 2 && cl == 2
                lp = L_Frame(rw-1,cl);
                lq = L_Frame(rw,cl-1);
                lr = L_Frame(rw-2,cl);
                if lp ~= lq && lp ~= 0 && lq ~= 0
                    lx = lp;
                    lt = lq;
                    for k = 1:length(C)
                        if C(k) == lt
                            C(k) = C(lp);
                            ind = L_Frame == lq;
                            L_Frame(ind) = C(k);
                        end
                    end
                elseif lq ~= lr && lp == 0 && lq ~= 0 && lr ~= 0
                    lx = lr;
                    lt = lq;
                    for k = 1:length(C)
                        if C(k) == lt
                            C(k) = C(lr);
                            ind = L_Frame == lq;
                            L_Frame(ind) = C(k);
                        end
                    end
                elseif lp ~= 0
                    lx = lp;
                elseif lq ~= 0
                    lx = lq;
                elseif lr ~= 0
                    lx = lr;
                else
                    newLabel = newLabel + 1;
                    C = [C newLabel];
                    lx = newLabel;
                end
            else
               
                lp = L_Frame(rw-1,cl);
                lq = L_Frame(rw,cl-1);
                lr = L_Frame(rw-2,cl);
                ls = L_Frame(rw,cl-2);
                lc = L_Frame(rw-1,cl-1);
                lf = L_Frame(rw-2,cl-2);
                if lp == 0 && lq == 0 && lr == 0 && ls == 0
                    if lc ~= 0
                        lx = lc;
                    elseif lf ~= 0
                        lx = lf;
                    else
                        newLabel = newLabel + 1;
                        C = [C newLabel];
                        lx = newLabel;
                        
                    end
                elseif lp == 0 && lq == 0 && lr ~= 0 && ls ~= 0
                    if lr == ls
                        lx = ls;
                    elseif lc ~= 0
                        lx = lc;
                    elseif lf ~= 0
                        lx = lf;
                    else
                        lx = lr;
                        lt = ls;
                        for k = 1:length(C)
                            if C(k) == lt
                                C(k) = C(lr);
                                ind = L_Frame == ls;
                                L_Frame(ind) = C(k);
                            end
                        end
                    end
                elseif lp ~= lq && lp ~= 0 && lq ~= 0
                    if lc ~= 0
                        lx = lc;
                    elseif lf ~= 0
                        lx = lf;
                    else
                        lx = lp;
                        lt = lq;
                        for k = 1:length(C)
                            if C(k) == lt
                                C(k) = C(lp);
                                ind = L_Frame == lq;
                                L_Frame(ind) = C(k);
                            end
                        end
                    end
                elseif lq ~= 0
                    lx = lq;
                elseif lp ~= 0
                    lx = lp;
                end
            end
            L_Frame(rw,cl) = lx;
        end
    end
end
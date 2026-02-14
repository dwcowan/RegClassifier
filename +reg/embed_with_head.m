function Eproj = embed_with_head(Ebase, head)
%EMBED_WITH_HEAD Apply trained projection head and L2-normalize
useGPU = canUseGPU();
X = dlarray(single(Ebase'),'CB');
if useGPU, X = gpuArray(X); end
Z = predict(head, X);
Z = gather(extractdata(Z))';
n = vecnorm(Z,2,2); n(n==0)=1; Eproj = Z ./ n;

% Clean up GPU memory
if useGPU && gpuDeviceCount > 0
    clear X Z;
    wait(gpuDevice);
end
end

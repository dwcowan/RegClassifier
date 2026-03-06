function Eproj = embed_with_head(Ebase, head)
%EMBED_WITH_HEAD Apply trained projection head and L2-normalize
useGPU = canUseGPU();
N = size(Ebase, 1);
projDim = head.Layers(end).OutputSize;
Eproj = zeros(N, projDim, 'single');

% Process in mini-batches to avoid GPU OOM on large inputs
mb = 4096;
for s = 1:mb:N
    e = min(N, s+mb-1);
    X = dlarray(single(Ebase(s:e,:)'),'CB');
    if useGPU, X = gpuArray(X); end
    Z = predict(head, X);
    Eproj(s:e,:) = gather(extractdata(Z))';
end

% L2-normalize
n = vecnorm(Eproj,2,2); n(n==0)=1; Eproj = Eproj ./ n;

% Clean up GPU memory
if useGPU && gpuDeviceCount > 0
    wait(gpuDevice);
end
end

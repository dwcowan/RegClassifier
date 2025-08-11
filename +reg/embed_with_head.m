function Eproj = embed_with_head(Ebase, head)
%EMBED_WITH_HEAD Apply trained projection head and L2-normalize
X = dlarray(single(Ebase'),'CB');
if canUseGPU, X = gpuArray(X); end
Z = predict(head, X);
Z = gather(extractdata(Z))';
n = vecnorm(Z,2,2); n(n==0)=1; Eproj = Z ./ n;
end

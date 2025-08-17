function h = compute_sha256(path)
%COMPUTE_SHA256 Compute SHA-256 of a file (MATLAB). For CI audit or baseline updates.
fid = fopen(path, 'rb');
if fid == -1
    error('compute_sha256:OpenFail','Cannot open %s', path);
end
d = java.security.MessageDigest.getInstance('SHA-256');
while true
    data = fread(fid, 8192, '*uint8');
    if isempty(data), break; end
    d.update(data);
end
fclose(fid);
h = char(org.apache.commons.codec.binary.Hex.encodeHex(d.digest()))';
end

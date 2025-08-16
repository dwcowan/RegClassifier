function h = compute_sha256(filePath)
%COMPUTE_SHA256 Compute file SHA256 hash.
%   H = COMPUTE_SHA256(FILEPATH) returns the hexadecimal SHA256 hash of the
%   file at FILEPATH.

import java.security.*
import java.io.*
md = MessageDigest.getInstance('SHA-256');
file = FileInputStream(File(filePath));
digest = java.security.DigestInputStream(file, md);
while digest.read() ~= -1
end
hash = typecast(md.digest(),'uint8');
h = lower(reshape(dec2hex(hash)',1,[]));
digest.close();
file.close();
end

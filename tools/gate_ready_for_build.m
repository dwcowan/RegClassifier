function gate_ready_for_build()
%GATE_READY_FOR_BUILD Composite gate to ensure readiness to leave clean-room.
% Runs style, contracts, tests hygiene, and ensures API manifest stability.

    fprintf('[gate_ready_for_build] Checking readiness...\n');
    tools.check_style();
    tools.check_contracts();
    tools.check_tests();

    % Ensure API manifest exists and is up to date
    repoRoot = fileparts(mfilename('fullpath')); repoRoot = fileparts(repoRoot);
    manifest = fullfile(repoRoot, 'api_manifest.json');
    if ~isfile(manifest)
        error('gate_ready_for_build:NoManifest', 'api_manifest.json missing. Run tools.snapshot_api.');
    end
    tools.check_api_drift();

    fprintf('[gate_ready_for_build] READY\n');
end

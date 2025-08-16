function gate_cc4m_release()
%GATE_CC4M_RELEASE Release gate that runs CC4M refinement checks plus existing guards.

    fprintf('[gate_cc4m_release] Running release gate...\n');
    tools.check_style();
    tools.check_contracts();
    tools.check_cc4m();
    tools.check_api_drift();

    % Optionally run tests & perf (leave to CI pipeline specifics)
    fprintf('[gate_cc4m_release] OK\n');
end

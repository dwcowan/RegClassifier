function print_mode()
%PRINT_MODE Display current repository mode from contexts/mode.json.
    m = tools.read_mode();
    fprintf('[mode] %s\n', m);
end

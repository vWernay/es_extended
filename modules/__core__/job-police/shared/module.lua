module.getFines = function()
    local resName = GetCurrentResourceName()
    local fines = json.decode(LoadResourceFile(resName, 'modules/__core__/job-police/fines.json'))

    return fines
end
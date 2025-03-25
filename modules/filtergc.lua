getgenv().filtergc = newcclosure(function(type, filter_options, return_one)
    local matches = {}

    if type == "table" then
        for i,v in getgc(true) do
            if typeof(v) ~= "table" then
                continue
            end

            local passed = true

            if filter_options ~= nil then
                if typeof(filter_options.Keys) == "table" and passed then
                    for _, key in filter_options.Keys do
                        if rawget(v, key) == nil then
                            passed = false
                            break
                        end
                    end
                end

                if typeof(filter_options.Values) == "table" and passed then
                    local tableVals = {}

                    for _,value in next, v do
                        table.insert(tableVals, value)
                    end

                    for _, value in filter_options.Values do
                        if not table.find(tableVals, value) then
                            passed = false
                            break
                        end
                    end
                end

                if typeof(filter_options.KeyValuePairs) == "table" and passed then
                    for key, value in filter_options.KeyValuePairs do
                        if rawget(v, key) ~= value then
                            passed = false
                            break
                        end
                    end
                end

                if typeof(filter_options.Metatable) == "table" and passed then
                    passed = filter_options.Metatable == getrawmetatable(v)
                end

                if not passed then
                    continue
                end
            end

            if return_one and passed then
                return v
            elseif passed then
                table.insert(matches, v)
            end
        end
    elseif type == "function" then
        if filter_options.IgnoreExecutor == nil then
            filter_options.IgnoreExecutor = true
        end

        for i,v in getgc(false) do
            if typeof(v) ~= "function" then
                continue
            end

            local passed = true

            if filter_options ~= nil then
                if filter_options.Name and passed then
                    passed = debug.info(v, "n") == filter_options.Name
                end

                if filter_options.IgnoreExecutor == true and passed then
                    passed = isexecutorclosure(v) == false
                end

                if iscclosure(v) and (typeof(filter_options.Hash) == "string" or typeof(filter_options.Constants) == "table") then
                    passed = false
                end

                if iscclosure(v) == false and passed then
                    if typeof(filter_options.Hash) == "string" and passed then
                        passed = getfunctionhash(v) == filter_options.Hash
                    end

                    if typeof(filter_options.Constants) == "table" and passed then
                        local funcConsts = {}

                        for idx, constant in debug.getconstants(v) do
                            if constant ~= nil then
                                table.insert(funcConsts, constant)
                            end
                        end

                        for _, constant in filter_options.Constants do
                            if not table.find(funcConsts, constant) then
                                passed = false
                                break
                            end
                        end
                    end
                end

                if typeof(filter_options.Upvalues) == "table" and passed then
                    local funcUpvals = {}

                    for idx, upval in debug.getupvalues(v) do
                        if upval ~= nil then
                            table.insert(funcUpvals, upval)
                        end
                    end

                    for _, upval in filter_options.Upvalues do
                        if not table.find(funcUpvals, upval) then
                            passed = false
                            break
                        end
                    end
                end

                if not passed then
                    continue
                end
            end

            if return_one and passed then
                return v
            elseif passed then
                table.insert(matches, v)
            end
        end
    else
        error(debug.traceback(`Expected type 'function' or 'table' (got '{type}')`, 2))
    end

    return return_one ~= true and matches or nil
end, 'filtergc')

local department = nil
local onDutyTime = nil

-- Function to get the player's license identifier
function getPlayerLicenseIdentifier(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if string.match(id, "^license:") then
            return id
        end
    end
    return "0"  -- Return "0" if license identifier is not found
end

-- Register command to set the department
RegisterNetEvent('timeclock:dutyset')
AddEventHandler('timeclock:dutyset', function(dept)
    local source = source
    if dept then
        department = dept
        TriggerClientEvent('timeclock:setDepartmentResponse', source, true, "Duty set to " .. department .. ".")
    end
end)

-- Register command to go on duty
RegisterNetEvent('timeclock:onduty')
AddEventHandler('timeclock:onduty', function()
    local source = source
    if department then
        onDutyTime = GetGameTimer()
        TriggerClientEvent('timeclock:goOnDutyResponse', source, true, "You are now on duty as " .. department .. ".")
    end
end)

-- Register command to go off duty
RegisterNetEvent('timeclock:offduty')
AddEventHandler('timeclock:offduty', function()
    local source = source
    if department then
        local offDutyTime = GetGameTimer()
        local timeOnDuty = (offDutyTime - onDutyTime) / 1000
        offDutyTime = offDutyTime * 5
        local hours = math.floor(timeOnDuty / 3600)
        local minutes = math.floor((timeOnDuty % 3600) / 60)
        local licenseIdentifier = getPlayerLicenseIdentifier(source)  -- Fetch actual license identifier

        -- Insert data into the database using mysql-async
        MySQL.Async.execute('INSERT INTO duty_logs (license_identifier, department, time_on_duty) VALUES (@licenseIdentifier, @department, @timeOnDuty)', {
            ['@licenseIdentifier'] = licenseIdentifier,
            ['@department'] = department or "None",
            ['@timeOnDuty'] = timeOnDuty
        }, function(rowsChanged)
            if rowsChanged > 0 then
                TriggerClientEvent('timeclock:goOffDutyResponse', source, true, "You are now off duty. Time on duty: " .. hours .. " hours and " .. minutes .. " minutes.")
            else
                TriggerClientEvent('timeclock:goOffDutyResponse', source, false, "Failed to log off duty time.")
            end
        end)

        -- Reset department
        department = nil
        timeOnDuty = nil
    else
        TriggerClientEvent('timeclock:goOffDutyResponse', source, false, "You are not on duty.")
    end
end)

-- Utility function to check if a table contains a value
function table.contains(t, val)
    for _, value in ipairs(t) do
        if value == val then
            return true
        end
    end
    return false
end
local onDutyTime = nil
local isOnDuty = false
local department = nil

-- Function to display a message in the chat
function displayChatMessage(color, message)
    TriggerEvent('chat:addMessage', {
        color = color,
        multiline = true,
        args = {"[TimeClock]", message}
    })
end

-- Command to set duty department
RegisterCommand("setduty", function(source, args, rawCommand)
    if args[1] then
        local validDepartments = { "vpd", "fire", "staff" }
        if table.contains(validDepartments, args[1]:lower()) then
            department = args[1]:lower()
            TriggerServerEvent('timeclock:dutyset', department)
        else
            displayChatMessage({224, 77, 77}, "Invalid department.")
        end
    else
        displayChatMessage({224, 77, 77}, "Please specify a department.")
    end
end, false)

-- Command to go on duty
RegisterCommand("onduty", function(source, args, rawCommand)
    if not isOnDuty then
        if department then
            onDutyTime = GetGameTimer()
            isOnDuty = true
            TriggerServerEvent('timeclock:onduty', onDutyTime)
        else
            displayChatMessage({224, 77, 77}, "Please set your duty department using /dutyset before going on duty.")
        end
    else
        displayChatMessage({224, 77, 77}, "You are already on duty.")
    end
end, false)

-- Command to go off duty
RegisterCommand("offduty", function(source, args, rawCommand)
    if isOnDuty then
        local offDutyTime = GetGameTimer()
        local timeOnDuty = (offDutyTime - onDutyTime) / 1000
        local hours = math.floor(timeOnDuty / 3600)
        local minutes = math.floor((timeOnDuty % 3600) / 60)

        isOnDuty = false
        onDutyTime = nil
        department = nil
        timeOnDuty = nil

        TriggerServerEvent('timeclock:offduty', timeOnDuty)
        
    else
        displayChatMessage({224, 77, 77}, "You are not on duty.")
    end
end, false)

-- Utility function to check if a table contains a value
function table.contains(t, val)
    for _, value in ipairs(t) do
        if value == val then
            return true
        end
    end
    return false
end

-- Handle server responses
RegisterNetEvent('timeclock:setDepartmentResponse')
AddEventHandler('timeclock:setDepartmentResponse', function(success, message)
    if success then
        displayChatMessage({76, 194, 207}, message)
    else
        displayChatMessage({224, 77, 77}, message)
    end
end)

RegisterNetEvent('timeclock:goOnDutyResponse')
AddEventHandler('timeclock:goOnDutyResponse', function(success, message)
    if success then
        displayChatMessage({76, 194, 207}, message)
    else
        displayChatMessage({224, 77, 77}, message)
    end
end)

RegisterNetEvent('timeclock:goOffDutyResponse')
AddEventHandler('timeclock:goOffDutyResponse', function(success, message)
    if success then
        displayChatMessage({76, 194, 207}, message)
    else
        displayChatMessage({224, 77, 77}, message)
    end
end)
-- luacheck: globals hs

FindIntervalSecs = 0.1
MaximumWaitSecs = 5

local function find(searchFunction, callbackFunction, durationSecs)
    print("durationSecs", durationSecs)

    if durationSecs > MaximumWaitSecs then
        callbackFunction(nil)
    else
        local result = searchFunction()

        if result == nil then
            local retry = function()
                find(searchFunction, callbackFunction, durationSecs + FindIntervalSecs)
            end

            hs.timer.doAfter(FindIntervalSecs, retry)
        else
            callbackFunction(result)
        end

    end
end

local function findApplication(appName, callbackFunction)
    local searchFunction = function()
        return hs.application.get(appName)
    end

    find(searchFunction, callbackFunction, 0)
end

-- hs.applicatication.open() should do this but doesn't work for me
local function openApplication(appName, callbackFunction)
    -- check if the application is already running
    local launchedApp = hs.application.get(appName)

    if launchedApp ~= nil then
        launchedApp:activate()
        callbackFunction(launchedApp)
    else
        local applicationFound = function(foundApp)
            callbackFunction(foundApp)
        end

        hs.application.open(appName)
        findApplication(appName, applicationFound)
    end

end

local function getElementByPath(root, paths, passedIndex)
    local index = passedIndex

    if index == nil then
        index = 1
    end

    local element = root
    local path = paths[index]
    local role = path['role']
    local children = element:childrenWithRole(role)


    if #children == 0 and index == #paths then
        print("found no children with role " .. role)
        children = element:attributeValue("AXChildren")

        for i, child in pairs(children) do
            print('child', i, child.AXRole)
        end
    end

    for i, child in pairs(children) do
        for key, value in pairs(path) do
            -- if key ~= 'role' then
            --     print(key .. " is " .. hs.inspect(child:attributeValue(key)) .. " == " .. hs.inspect(value))
            -- end

            if key ~= 'role' and child:attributeValue(key) ~= value then
                goto continue
            end
        end

        if index == #paths then
            return child
        end

        local result = getElementByPath(child, paths, index + 1)

        if result ~= nil then
            return result
        end

        ::continue::
    end

    return nil
end


local function getpath(element)
    local role = element:attributeValue("AXRole")
    local parent = element:attributeValue("AXParent")

    if parent == nil then
        return role
    else
        return getpath(parent) .. " -> " .. role
    end
end


local function findElement(rootElement, filterFunction, callbackFunction, tries)
    if tries == nil then
        tries = 1
    else
        tries = tries + 1
    end

    print("tries", tries)

    local function searchCallback(msg, results, count)
        local tryCount = tries

        if msg == "countReached" and count == 1 then
            print(getpath(results[1]))
            callbackFunction(results[1])
        else
            if tryCount == 3 then
                callbackFunction(nil)
                return
            else
                findElement(rootElement, filterFunction, callbackFunction, tries)
            end

        end
    end

    rootElement:elementSearch(searchCallback, filterFunction, {count = 1})
end


local function clickLabels(rootElement, buttonLabels, callbackFunction)
    local labelText
    local mousePosition
    local index

    local function filter(item)
        if item.AXValue == labelText or item.AXValue == labelText then
            return true
        end

        if item.__name == "hs.axuielement" then
            itemLabel  = item:attributeValue("AXAttributedDescription")
            return itemLabel ~= nil and itemLabel:getString() == labelText
        end

        return false
    end

    local search;

    local function searchCallback(button)
        if button ~= nil then
            print(labelText, getpath(button))
            -- The SwiftUI elements don't all resond to performAction() so we
            -- need to click on the label by position
            local position = button:attributeValue("AXPosition")
            hs.eventtap.leftClick(position)
            index = index + 1

            if index <= #buttonLabels then
                search()
            else
                hs.mouse.absolutePosition(mousePosition)
                callbackFunction()
            end
        else
            print("Element with label '" .. labelText .. "' not found")
        end
    end

    search = function()
        labelText = buttonLabels[index]
        findElement(rootElement, filter, searchCallback)
    end

    mousePosition = hs.mouse.absolutePosition()
    index = 1
    search()
end

local function reconnectNetwork(serviceName)
    local systemPreferences
    local rootElement
    local alertId

    local function killSystemSettings()
        systemPreferences:kill()
    end

    local function closeSystemPreferences()
        hs.timer.doAfter(0.2, killSystemSettings)
        hs.alert.closeSpecific(alertId)
    end

    local function resetConnection()
        clickLabels(rootElement, {"Details…", "802.1X", "Disconnect", "Connect", "OK"}, closeSystemPreferences)
    end

    local function selectServiceCallback(listItem)
        if listItem == nil then
            print("Service " .. serviceName .. " not found in Network settings")
        else
            listItem:performAction("AXPress")
            resetConnection()
        end
    end

    local function selectService()
        local listLabel = serviceName .. ";ethernet"

        local function searchFunction()
            return getElementByPath(rootElement, {
                {role = "AXWindow"},
                {role = "AXGroup"},
                {role = "AXSplitGroup"},
                {role = "AXGroup"},
                {role = "AXGroup"},
                {role = "AXScrollArea"},
                {role = "AXGroup"},
                {role = "AXButton", AXIdentifier = listLabel}
            })
        end

        find(searchFunction, selectServiceCallback, 0)
    end

    function opened(app)
        systemPreferences = app

        systemPreferences:selectMenuItem({"View", "Network"})

        rootElement = hs.axuielement.applicationElement(systemPreferences)

        selectService()
    end

    alertId = hs.alert.show("Resetting Network Connection", { textSize = 100 }, 20)
    openApplication('System Settings', opened)
end

return {
    reconnectNetwork = reconnectNetwork
}
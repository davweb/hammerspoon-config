local findIntervalSecs = 0.25;
local maximumWaitSecs = 5;

local function find(searchFunction, callbackFunction, durationSecs)
    print('durationSecs', durationSecs)

    if durationSecs > maximumWaitSecs then
        callbackFunction(nil)
    else
        local result = searchFunction()

        if result == nil then
            local retry = function()
                find(searchFunction, callbackFunction, durationSecs + findIntervalSecs)
            end

            hs.timer.doAfter(findIntervalSecs, retry)
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

local function clickByLabel(rootElement, buttonLabels, callbackFunction)
    local labelText
    local mousePosition

    function filter(item)
        if item.AXValue == labelText or item.AXValue == labelText then
            return true
        end

        if item.__name == 'hs.axuielement' then
            itemLabel  = item:attributeValue('AXAttributedDescription')

            if itemLabel ~= nil and itemLabel:getString() == labelText then
                return true
            end
        end

        return false
    end

    function searchCallback(msg, results, count)
        if msg == 'countReached' and count == 1 then
            local button = results[1]

            -- The SwiftUI elements don't all resond to perfßormAction() so we
            -- need to click on the label by position
            local position = button:attributeValue("AXPosition")
            hs.eventtap.leftClick(position)

            if #buttonLabels > 1 then
                table.remove(buttonLabels, 1)
                hs.timer.doAfter(1, search)
            else
                hs.mouse.absolutePosition(mousePosition)
                hs.timer.doAfter(1, callbackFunction)
            end
        else
            print('Element with label "' .. labelText .. '" button not found')
        end
    end

    function search()
        labelText = buttonLabels[1]
        rootElement:elementSearch(searchCallback, filter, {count = 1})
    end

    mousePosition = hs.mouse.absolutePosition()
    search()
end

local function reconnectNetwork(serviceName)
    local systemPreferences
    local rootElement

    function closeSystemPreferences()
        systemPreferences:kill()
    end

    function resetConnection()
        clickByLabel(rootElement, {'Details…', '802.1X', 'Disconnect', 'Connect', 'OK'}, closeSystemPreferences)
    end

    function selectServiceCallback(msg, results, count)
      if msg == 'countReached' then
          local listItem = results[1]
          listItem:performAction("AXPress")
          hs.timer.doAfter(1, resetConnection)
      else
          print('Service ' .. serviceName .. ' not found in Network settings')
      end
    end

    function selectService()
        local listLabel = serviceName .. ';'

        rootElement:elementSearch(selectServiceCallback, function (item)
            itemId = item:attributeValue("AXIdentifier")

            if itemId ~= nil then
                local start, finish = string.find(itemId, listLabel)
                return start == 1
            else
                return false
            end
        end, {count = 1})
    end


    function openNetwork()
        systemPreferences:selectMenuItem({"View", "Network"})
        hs.timer.doAfter(2, selectService)
    end

    function opened(app)
        systemPreferences = app
        rootElement = hs.axuielement.applicationElement(systemPreferences)
        hs.timer.doAfter(1, openNetwork)
    end

    openApplication('System Settings', opened)
  end

  return {
    reconnectNetwork = reconnectNetwork
  }
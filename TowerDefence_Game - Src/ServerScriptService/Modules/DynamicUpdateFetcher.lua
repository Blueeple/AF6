local HttpService = game:GetService("HttpService")

local githubUsername = "Blueeple"
local repoName = "Tower-Defence-Game-V3"
local branch = "main"
local filePath = "DynamicFetchStore/ItemShop/"

local accessToken = "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"

local headers = {
    ["Authorization"] = "Bearer " .. accessToken
}

local DynamicStoreFetcher = {}

function DynamicStoreFetcher:Get(...)
    if not typeof(...) == "string" then return nil end

    local rawFileUrl = string.format("https://raw.githubusercontent.com/%s/%s/%s/%s%s%s", githubUsername, repoName, branch, filePath .. ... .. ".json", "?cache_bust=",tostring(os.time()))
    local success, response = pcall(function()
        return HttpService:GetAsync(rawFileUrl, true, headers)
    end)
    
    if success then
        local jsonData = HttpService:JSONDecode(response)
        return jsonData
    else
        warn("Failed to fetch JSON file: " .. response)
    end
end

return DynamicStoreFetcher
local HttpService = game:GetService("HttpService")
local MessagingService = game:GetService("MessagingService")

local githubUsername = "Blueeple"
local repoName = "Battle-Grounds-Game"
local branch = "main"
local filePath = "GameStore/"

local accessToken = "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"

local headers = {
    ["Authorization"] = "Bearer " .. accessToken
}

local DynamicStoreFetcher = {}

function DynamicStoreFetcher:Get(...)
    if typeof(...) ~= "string" then return nil end

    local rawFileUrl = string.format("https://raw.githubusercontent.com/%s/%s/%s/%s", githubUsername, repoName, branch, filePath .. ...)
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
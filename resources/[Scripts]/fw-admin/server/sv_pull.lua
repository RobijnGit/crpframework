local ServerRootPath = GetResourcePath("fw-admin"):match("(.+)resources"):sub(1, -2)
local RepositoryDirectory = {
    ServerRootPath,
    ServerRootPath .. "/resources/[Clothing]",
    ServerRootPath .. "/resources/[Vehicles]"
}

function PullRepositories()
    for k, v in ipairs(RepositoryDirectory) do
        PullRepoByDirectory(v)
    end
end

function PullRepoByDirectory(Directory)
    local FetchSuccess = os.execute("cd " .. Directory .. " && git fetch")
    if not FetchSuccess then return print("Fetch failed in " .. Directory) end

    local PullSuccess = os.execute("cd " .. Directory .. " && git pull")
    if not PullSuccess then return print("Pull failed in " .. Directory) end

    print("Successfully pulled in " .. Directory)
end
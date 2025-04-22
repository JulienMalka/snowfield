local match_modes = {
    ALL = "all",
    FIRST = "first",
    UNIQUE = "unique",
}

--- Execute a shell command and return its output
local function execute_command(cmd)
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()
    return result
end

--- Get all folders from the Maildir structure
local function get_maildir_folders(maildir_path)
    local cmd = "find " .. maildir_path .. " -type d -name cur | sed 's|/cur$||' | sed 's|" .. maildir_path .. "/||'"
    local output = execute_command(cmd)
    
    local folders = {}
    for folder in string.gmatch(output, "([^\n]+)") do
        if folder ~= "" then
            folders[#folders+1] = folder
        end
    end
    
    return folders
end

--- Check if one path is a parent of another
local function is_parent_path(parent, child)
    return child:match("^" .. parent .. "/") ~= nil
end

--- Generate rules based on folder structure
local function generate_rules(maildir_path)
    local folders = get_maildir_folders(maildir_path)
    local rules = {}
    
    -- Create a sorted copy of folders, from longest path to shortest
    -- This ensures we process children before parents
    local sorted_folders = {}
    for _, folder in ipairs(folders) do
        table.insert(sorted_folders, folder)
    end
    table.sort(sorted_folders, function(a, b) 
        return #a > #b 
    end)
    
    -- Store each folder's subfolder tags for exclusion
    local subfolder_tags = {}
    for _, folder in ipairs(sorted_folders) do
        subfolder_tags[folder] = {}
    end
    
    -- Collect all subfolder-specific tags for each folder
    for _, folder in ipairs(sorted_folders) do
        local parts = {}
        for part in string.gmatch(folder, "([^/]+)") do
            table.insert(parts, part)
        end
        
        -- For each folder, find its parent folders and add its deepest tag to their exclusion list
        if #parts > 0 then
            local deepest_tag = string.lower(parts[#parts])
            local parent_path = ""
            
            for i = 1, #parts - 1 do
                if i > 1 then
                    parent_path = parent_path .. "/"
                end
                parent_path = parent_path .. parts[i]
                
                -- Add this tag to the parent's exclusion list
                if subfolder_tags[parent_path] then
                    table.insert(subfolder_tags[parent_path], deepest_tag)
                end
            end
        end
    end
    
    -- Now generate rules with proper exclusions
    for _, folder in ipairs(folders) do
        -- Skip Trash and Sent as they're already handled
        if folder ~= "Trash" and folder ~= "Sent" then
            local query_parts = {}
            local exclusion_parts = {}
            
            -- Convert each folder component to a lowercase tag requirement
            for part in string.gmatch(folder, "([^/]+)") do
                table.insert(query_parts, "tag:" .. string.lower(part))
            end
            
            -- Add exclusions for subfolder-specific tags
            if subfolder_tags[folder] then
                for _, tag in ipairs(subfolder_tags[folder]) do
                    table.insert(exclusion_parts, "not tag:" .. tag)
                end
            end
            
            -- Build the complete query
            local query = table.concat(query_parts, " and ")
            if #exclusion_parts > 0 then
                query = query .. " and " .. table.concat(exclusion_parts, " and ")
            end
            
            -- Add rule for this folder
            rules[#rules+1] = {
                folder = folder,
                query = query,
            }
        end
    end
    
    -- Sort rules by complexity (number of tags) - more specific rules first
    table.sort(rules, function(a, b)
        if a.folder == "Trash" then return true end
        if b.folder == "Trash" then return false end
        if a.folder == "Sent" then return true end
        if b.folder == "Sent" then return false end
        
        local a_count = select(2, string.gsub(a.query, "tag:", ""))
        local b_count = select(2, string.gsub(b.query, "tag:", ""))
        return a_count > b_count
    end)

   local final_rules = {}
    for _, rule in ipairs(rules) do
        if string.lower(rule.folder) ~= "drafts" then
            table.insert(final_rules, rule)
        end
    end 
    
    return final_rules
end

-- Path to maildir
local maildir_path = os.getenv("HOME") .. "/Maildir"

--- Configuration for notmuch-mailmover.
--
--- @class config
--- @field maildir      string                  Path to the maildir
--- @field notmuch_config string                Path to the notmuch configuration
--- @field rename       boolean                 Rename the files when moving
--- @field max_age_days number                  Maximum age (days) of the messages to be procssed
--- @field rule_match_mode config.match_mode    Match mode for rules
--- @field rules        rule[]                  List of rules
---
--- @class rule
--- @field folder string Folder to move the messages to
--- @field query  string Notmuch query to match the messages
local config = {
    maildir = maildir_path,
    notmuch_config = "/home/julien/.config/notmuch/default/config",
    rename = true,
    max_age_days = 356,
    rule_match_mode = match_modes.UNIQUE,
    rules = generate_rules(maildir_path),
}


return config

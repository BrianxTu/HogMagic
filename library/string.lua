function string:startswith(prefix)
    return string.sub(self, 1, string.len(prefix)) == prefix
end

function string:endswith(suffix)
    return suffix == "" or string.sub(self, -string.len(suffix)) == suffix
end

function string:trim()
    return self:gsub("^%s*(.-)%s*$", "%1")
end

function string:split(separator)
    separator = separator or "%s"
    local fields = {}
    local pattern = string.format("([^%s]+)", separator)
    self:gsub(pattern, function(c) table.insert(fields, c) end)
    return fields
end

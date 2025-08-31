-- license_check.lua
-- Tebex anti-leak and license validation
-- Developer: iboss21 (https://github.com/iboss21)

local tebexSecret = "YOUR_TEBEX_SECRET" -- Set in config.lua
local isValid = false

function CheckLicense()
    PerformHttpRequest("https://plugin.tebex.io/license", function(statusCode, response, headers)
        if statusCode == 200 and response then
            local data = json.decode(response)
            if data and data.valid then
                isValid = true
            else
                print("[Telegram] Invalid Tebex license!")
            end
        else
            print("[Telegram] Tebex license check failed!")
        end
    end, "POST", json.encode({secret = tebexSecret}), { ["Content-Type"] = "application/json" })
end

function IsLicenseValid()
    return isValid
end

return {
    CheckLicense = CheckLicense,
    IsLicenseValid = IsLicenseValid
}

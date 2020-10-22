-- TODO: Use "AceComm-3.0" as mixin to allow instances to communicate between clients
ReagentProfessions = LibStub("AceAddon-3.0"):NewAddon("ReagentProfessions", "AceConsole-3.0", "AceEvent-3.0")

function ReagentProfessions:OnInitialize()
    -- Code that you want to run when the addon is first loaded goes here.
    self.db = LibStub("AceDB-3.0"):New("ReagentProfessionsDB")
end

function ReagentProfessions:OnEnable()
    -- Called when the addon is enabled
    self:Print("ReagentProfessions enabled!")

    self:RegisterEvent("TRADE_SKILL_SHOW")
end

function ReagentProfessions:OnDisable()
    -- Called when the addon is disabled
    self:Print("ReagentProfessions disabled!")
end

function ReagentProfessions:TRADE_SKILL_SHOW()

	self:Print("ReagentProfessions trade skill show fired!")
end

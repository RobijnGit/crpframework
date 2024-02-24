Config = Config or {}

Config.DefaultRolePermissions = {
    -- Dashboard
    ['Dashboard.Visible'] = false,
    ['Dashboard.ShowWarrents'] = false,
    ['Dashboard.ShowBulletin'] = false,
    
    -- Reports
    ['Reports.Visible'] = false,
    ['Reports.Edit'] = false,
    ['Reports.Create'] = false,
    ['Reports.Delete'] = false,
    
    -- Profiles
    ['Profiles.Edit'] = false,
    ['Profiles.Create'] = false,
    ['Profiles.Delete'] = false,
    ['Profiles.ShowHousing'] = false,
    ['Profiles.ShowNotes'] = false,
    
    -- Evidence
    ['Evidence.Visible'] = false,
    ['Evidence.Edit'] = false,
    ['Evidence.Create'] = false,
    ['Evidence.Delete'] = false,
    
    -- Staff
    ['Staff.GiveCerts'] = false,
    ['Staff.ShowStrikes'] = false,
    ['Staff.GiveStrikes'] = false,
    
    -- Legislation
    ['Legislation.Edit'] = false,
    ['Legislation.Create'] = false,
    ['Legislation.Delete'] = false,
}

--[[
    Permissions list:

    Dashboard:
    Dashboard.Visible - Can user see page?
    Dashboard.ShowWarrents - Can user see warrents?
    Dashboard.ShowBulletin - Can user see bulletin board?

    Reports:
    Reports.Visible - Can user see page?
    Reports.Edit - Can user edit reports?
    Reports.Create - Can user create reports?
    Reports.Delete - Can user delete reports?

    Profiles:
    Profiles.Visible - Can user see page?
    Profiles.Edit - Can user edit profile?
    Profiles.Create - Can user create profile?
    Profiles.Delete - Can user delete profile?
    Profiles.ShowHousing - Can use see profile housing?

    Evidence:
    Evidence.Visible - Can user see page?
    Evidence.Edit - Can user edit evidence?
    Evidence.Create - Can user create evidence?
    Evidence.Delete - Can user delete evidence?

    Staff:
    Staff.Visible - Can user see page?
    Staff.ShowStrikes - Can user see strikes? 
    Staff.GiveStrikes - Can user give strikes?

    Legislation:
    Legislation.Visible - Can user see page?
    Legislation.Edit  - Can user edit legislation?
    Legislation.Create - Can user create legislation?
    Legislation.Delete - Can user delete legislation?

    Categories:
    Categories.Show<CategoryType> - Can user see/create reports with category type?
]]
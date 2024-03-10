import { get } from "svelte/store";
import { IsGov, IsEms, IsJudge } from "./stores";

export const DefaultReport = `<p><strong>[DEPARTMENT] Rapport</strong></p><p>[DATE_TIMESTAMP]</p><p>&nbsp;</p><p><strong>Reporting Officer:</strong></p><p>[REPORTING_OFFICER]</p><p>&nbsp;</p><p><strong>Assisterende Agent(en):</strong></p><p>&nbsp;</p><p><strong>Verdachte(n):</strong></p><p>&nbsp;</p><p><strong>Slachtoffer(s):</strong></p><p>&nbsp;</p><p><strong>Getuige(n):</strong></p><p>&nbsp;</p><p><strong>Locatie:</strong></p><p>&nbsp;</p><p><strong>Debrief:</strong></p><p></p>`
export const DefaultMedicalReport = `<p><strong>Los Santos Medical Group Rapport</strong></p><p>[DATE_TIMESTAMP]</p><p>&nbsp;</p><p><strong>Is er vermoeden van inwendig/uitwendig bloedverlies:</strong> Ja/Nee</p><p>&nbsp;</p><p><strong>Is er vermoeden van niet uitwendig waarneembaar letsel:</strong> Ja/Nee</p><p>&nbsp;</p><p><strong>Is er vermoeden van inwendig waarneembaar letsel:</strong> Ja/Nee</p><p>&nbsp;</p><p><strong>Behandelaar:</strong></p><p>[REPORTING_OFFICER]</p><p>&nbsp;</p><p><strong>Mede-behandelaars(en):</strong></p><p>&nbsp;</p><p><strong>Patiënt(en):</strong></p><p>&nbsp;</p><p><strong>Locatie van incident:</strong></p><p>&nbsp;</p><p><strong>Waar heeft de patiënt last van?</strong></p><p>&nbsp;</p><p><strong>Behandeling:</strong></p>`
export const MCUReport = `<figure class="image"><img src="https://lh3.googleusercontent.com/HhFsWBEKklEsPQRgiKgHl23r8_hllz4s3pgmPxkQRgWxU4QU1D3m6wuAIDqJzi9ITN17-s_-9CT1hl1zPBmw-enXqw8oRmnA9UdEcZNoNXCRmBeBDv2xax-dfd8PSQlr5IAEW28R6EPGGH3CNrrJHec"></figure><p><strong>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; LOS SANTOS&nbsp;</strong></p><p><strong>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; MAJOR CRIME DIVISION</strong></p><p>&nbsp;</p><h2><strong>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;CASE REPORT</strong></h2><p>&nbsp;</p><p>&nbsp;</p><p><strong>FILE INFORMATION </strong><i><strong>#000-0000-G</strong></i></p><p>SUBJECT:&nbsp;</p><p>DETECTIVE(S):</p><p>[REPORTING_OFFICER]</p><p>DATE: [DATE_TIMESTAMP]</p><p>LOCATION:</p><p>&nbsp;</p><p><strong>SUSPECT (1) INFORMATION:</strong></p><p>NAME:</p><p>SURNAME:</p><p>STATE-ID:</p><p>&nbsp;</p><p><strong>BEVINDINGEN RAPPORT:</strong></p><p>&nbsp;</p><p>&nbsp;</p>`;
export const CivilianReport = `<p><strong>[DEPARTMENT] Aangifte</strong></p><p>[DATE_TIMESTAMP]</p><p>&nbsp;</p><p><strong>Reporting Officer:</strong></p><p>[REPORTING_OFFICER]</p><p>&nbsp;</p><p><strong>Aangever:</strong></p><p>#[bsn] - [voor- en achternaam] ([telefoonnummer])</p><p>&nbsp;</p><p><strong>Debrief:</strong></p><p>Tussen [datum en tijd] en [datum en tijd] werd in de buurt van [locatie], het in de aanhef vermelde feit gepleegd en de aangever verklaarde het volgende over het in de aanhef vermelde incident:</p><p>&nbsp;</p>`
export const BurnReport = `<p><strong>Brandwonden Rapport</strong></p><p>[DATE_TIMESTAMP]</p><p>&nbsp;</p><p><strong>Is de patiënt aanspreekbaar:</strong> Ja/Nee</p><p>&nbsp;</p><p><strong>Behandelaar:</strong></p><p>[REPORTING_OFFICER]</p><p>&nbsp;</p><p><strong>Mede-behandelaars(en):</strong></p><<p>&nbsp;</p><p><strong>Patiënt(en):</strong></p><p>&nbsp;</p><p><strong>Locatie van de behandeling:</strong></p><p>&nbsp;</p><p><strong>Wat is er gebeurd?</strong></p><p>&nbsp;</p><p><strong>Wat voor brandwond is het?</strong></p><p>&nbsp;</p><p><strong>Behandeling:</strong></p>`
export const GunshotReport = `<p><strong>Shotwonden Rapport</strong></p><p>[DATE_TIMESTAMP]</p><p>&nbsp;</p><p><strong>Is de patiënt aanspreekbaar:</strong> Ja/Nee</p><p>&nbsp;</p><p><strong>Behandelaar:</strong></p><p>[REPORTING_OFFICER]</p><p>&nbsp;</p><p><strong>Mede-behandelaars(en):</strong></p><<p>&nbsp;</p><p><strong>Patiënt(en):</strong></p><p>&nbsp;</p><p><strong>Locatie van de behandeling:</strong></p><p>&nbsp;</p><p><strong>Hoeveel schotwonden zijn er in het lichaam te vinden?</strong></p><p>&nbsp;</p><p><strong>Behandeling:</strong></p>`
export const VehicleReport = `<p><strong>Voertuig Ongeluk Rapport</strong></p><p>[DATE_TIMESTAMP]</p><p>&nbsp;</p><p><strong>Is er vermoeden van inwendig/uitwendig bloedverlies:</strong> Ja/Nee</p><p>&nbsp;</p><p><strong>Is er vermoeden van inwendig waarneembaar letsel:</strong> Ja/Nee</p><p>&nbsp;</p><p><strong>Is de patiënt aanspreekbaar:</strong> Ja/Nee</p><p>&nbsp;</p><p><strong>Is de patiënt uit de auto gevallen:</strong> Ja/Nee</p><p>&nbsp;</p><p><strong>Behandelaar:</strong></p><p>[REPORTING_OFFICER]</p><p>&nbsp;</p><p><strong>Mede-behandelaars(en):</strong></p><<p>&nbsp;</p><p><strong>Patiënt(en):</strong></p><p>&nbsp;</p><p><strong>Locatie van de behandeling:</strong></p><p>&nbsp;</p><p><strong>Waar heeft de patiënt last van?</strong></p><p>&nbsp;</p><p><strong>Behandeling:</strong></p>`
export const ReceiptReport = `<p><strong>Receptuur Rapport</strong></p><p>[DATE_TIMESTAMP]</p><p>&nbsp;</p><p><strong>Behandelaar:</strong></p><p>[REPORTING_OFFICER]</p><p>&nbsp;</p><p><strong>Patiënt(en):</strong></p><p>&nbsp;</p><p><strong>Locatie van de behandeling:</strong></p><p>&nbsp;</p><p><strong>Geneesmiddel:</strong></p><p>&nbsp;</p><p><strong>Aantal:</strong></p><p>&nbsp;</p><p><strong>Opmerkingen:</strong></p><p>&nbsp;</p><p><strong>Bevindingen:</strong></p>`
export const FysioReport = `<p><strong>Fysio Rapport</strong></p><p>[DATE_TIMESTAMP]</p><p>&nbsp;</p><p><strong>Behandelaar:</strong></p><p>[REPORTING_OFFICER]</p><p>&nbsp;</p><p><strong>Patiënt(en):</strong></p><p>&nbsp;</p><p><strong>Locatie van de behandeling:</strong></p><p>&nbsp;</p><p><strong>Bevindingen:</strong></p>`
export const MentalReport = `<p><strong>Mentale Status Rapport</strong></p><p>[DATE_TIMESTAMP]</p><p>&nbsp;</p><p><strong>Is de persoon normaal aanspreekbaar:</strong> Ja/Nee</p><p>&nbsp;</p><p><strong>Heeft de persoon een ongeluk meegemaakt en hier angst voor:</strong> Ja/Nee</p><p>&nbsp;</p><p><strong>Is de persoon al eerder in behandeling geweest:</strong> Ja/Nee</p><p>&nbsp;</p><p><strong>Behandelaar:</strong></p><p>[REPORTING_OFFICER]</p><p>&nbsp;</p><p><strong>Patiënt(en):</strong></p><p>&nbsp;</p><p><strong>Locatie van de behandeling:</strong></p><p>&nbsp;</p><p><strong>Wat is de oorzaak van de klacht?</strong></p><p>&nbsp;</p><p><strong>Bevindingen:</strong></p>`

export const MdwTabs = [
    { Hidden: true, Permission: "Dashboard.Visible", Label: "Dashboard", Destination: "Dashboard" },
    { Hidden: true, Permission: "Reports.Visible", Label: "Rapporten", Destination: "Reports" },
    { Hidden: false, Label: "Profielen", Destination: "Profiles" },
    { Hidden: true, Permission: "Evidence.Visible", Label: "Bewijs", Destination: "Evidence" },
    { Hidden: false, Label: "Eigendommen", Destination: "Properties" },
    { Hidden: false, Label: "Straffen", Destination: "Charges" },
    { Hidden: false, Label: "Personeel", Destination: "Staff" },
    { Hidden: false, Label: "Wetgeving", Destination: "Legislation" },
    { Hidden: false, Label: "Bedrijven", Destination: "Businesses" },
    { Hidden: true, Permission: "Dashboard.Visible", Label: "Roster", Destination: "Roster" },
];

export const LicensesLocale = {
    "driver": "Rijbewijs",
    "hunting": "Jaag Vergunning",
    "weapon": "Wapen Vergunning",
    "fishing": "Vis Vergunning",
    "flying": "Vliegbrevet",
    "business": "Bedrijfs Vergunning",
}

export const PermissionsLocale = {
    "Dashboard.Visible": "Dashboard: Tab Visible",
    "Dashboard.ShowWarrents": "Dashboard: Show Warrents",
    "Dashboard.ShowBulletin": "Dashboard: Show Bulletin",
    "Reports.Visible": "Reports: Tab Visible",
    "Reports.Edit": "Reports: Edit Report",
    "Reports.Create": "Reports: Create Report",
    "Reports.Delete": "Reports: Delete Report",
    "Reports.Export": "Reports: Export Report",
    "Profiles.Visible": "Profiles: Tab Visible",
    "Profiles.Edit": "Profiles: Edit Profile",
    "Profiles.Create": "Profiles: Create Profile",
    "Profiles.Delete": "Profiles: Delete Profile",
    "Profiles.ShowHousing": "Profiles: Show Housing",
    "Profiles.ShowNotes": "Profiles: Show Notes",
    "Evidence.Visible": "Evidence: Tab Visible",
    "Evidence.Edit": "Evidence: Edit Evidence",
    "Evidence.Create": "Evidence: Create Evidence",
    "Evidence.Delete": "Evidence: Delete Evidence",
    "Staff.Visible": "Staff: Tab Visible",
    "Staff.GiveCerts": "Staff: Give/Remove Officer Certs",
    "Staff.ShowStrikes": "Staff: Show Officer Strikes",
    "Staff.GiveStrikes": "Staff: Give Officer Strike",
    "Legislation.Visible": "Legislations: Tab Visible",
    "Legislation.Edit": "Legislations: Edit Legislation",
    "Legislation.Create": "Legislations: Create Legislation",
    "Legislation.Delete": "Legislations: Delete Legislation",
    "Config.EditCharges": "Config: Edit Charges",
    "Config.DeleteCharges": "Config: Delete Charges",
}

export const ReportTypes = [
    { Label: "Fysio Rapport", Jobs: ["ems", "judge"], Certs: false },
    { Label: "Receptuur Rapport", Jobs: ["ems", "judge"], Certs: false },
    { Label: "Medische Rapport", Jobs: ["ems", "judge"], Certs: false },
    { Label: "Brandwonden Rapport", Jobs: ["ems", "judge"], Certs: false },
    { Label: "Schotwonden Rapport", Jobs: ["ems", "judge"], Certs: false },
    { Label: "Mentale Status Rapport", Jobs: ["ems", "judge"], Certs: false },
    { Label: "Voertuig Ongeluk Rapport", Jobs: ["ems", "judge"], Certs: false },
    { Label: "Incidenten Rapport", Jobs: ["pd", "judge"], Certs: false },
    { Label: "Onderzoek Rapport", Jobs: ["pd", "judge"], Certs: false },
    { Label: "MCU Onderzoek Rapport", Jobs: ["pd", "judge"], Certs: [7, 8] },
    { Label: "Beslagname Rapport", Jobs: ["pd", "judge"], Certs: false },
    { Label: "Burger Rapport", Jobs: ["pd", "judge"], Certs: false },
    { Label: "Prikbord", Jobs: ["pd", "ems", "judge"], Certs: false },
    { Label: "BOLO", Jobs: ["pd", "judge"], Certs: false },
    { Label: "Notitie", Jobs: ["pd", "judge"], Certs: false },
];

export const GetReportTypes = (Certs, JustArray) => {
    let Retval = [];

    const _IsGov = get(IsGov);
    const _IsJudge = get(IsJudge);
    const _IsEms = get(IsEms);
    const Job = (_IsGov || _IsJudge) ? ( _IsEms ? "ems" : "pd"  ) : "";

    for (let i = 0; i < ReportTypes.length; i++) {
        const Type = ReportTypes[i];

        if (Type.Jobs.includes(Job) && (!Type.Certs || Type.Certs.some(item => Certs.includes(item)))) {
            if (JustArray) {
                Retval.push(Type.Label)
            } else {
                Retval.push({ Text: Type.Label, Value: Type.Label });
            }
        };
    };

    return Retval;
};
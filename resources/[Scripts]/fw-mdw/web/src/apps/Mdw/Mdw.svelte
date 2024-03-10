<script>
    import { CurrentTab, IsPublic, MdwCharges, MdwTags, MdwCerts, ShowLoader, MdwModalsTags, MdwModalsCerts, MdwModalsUnits, MdwEvidence, MdwModalsPerson, ImageHoverData, MdwModalsEvidence, MdwModalsProfiles, MdwModalsCharges, MdwRanks, MdwRoles, MdwModalsPermissions, MdwModalsRoles, MdwModalsExport, MdwModalsChargeEditor, MdwModalsVehicleHistory } from "../../stores";
    import { Debug, IsEnvBrowser, OnEvent } from "../../utils/Utils";
    import MdwTopbar from "./MdwTopbar.svelte"
    import MdwNavbar from "./MdwNavbar.svelte"
    import MdwContainer from "./MdwContainer.svelte"

    import ModalsTags from "./modals/Modals.Tags.svelte";
    import ModalsCerts from "./modals/Modals.Certs.svelte";
    import ModalsRoles from "./modals/Modals.Roles.svelte";
    import ModalsUnits from "./modals/Modals.Units.svelte";
    import ModalsPerson from "./modals/Modals.Persons.svelte";
    import ModalsEvidence from "./modals/Modals.Evidence.svelte";
    import ModalsProfiles from "./modals/Modals.Profile.svelte";
    import ModalsCharges from "./modals/Modals.Charges.svelte";
    import ModalsPermissions from "./modals/Modals.Permissions.svelte";
    import ModalsChargeEditor from "./modals/Modals.ChargeEditor.svelte";
    import ModalsVehicleHistory from "./modals/Modals.VehicleHistory.svelte";
    import ModalsExport from "./modals/Modals.Export.svelte";
    import AppWrapper from "../../components/AppWrapper.svelte";

    let MdwVisible = IsEnvBrowser();
    let Opacity = IsEnvBrowser() ? 1.0 : 0.0;

    OnEvent("Mdw/SetVisiblity", Data => {
        IsPublic.set(Data.IsPublic);
        if (Data.IsPublic) CurrentTab.set("Profiles");
        MdwVisible = Data.Visible;

        if (!Data.Visible && $ImageHoverData.Show) {
            ImageHoverData.set({ Show: false, Source: "", Top: 0, Left: 0 });
        };

        Opacity = Data.Visible ? 1.0 : 0.0
    });

    OnEvent("Mdw/SetCharges", Data => {
        MdwCharges.set(Data);
        Debug("SetCharges -> Charges were set!");
    });

    OnEvent("Mdw/SetTags", Data => {
        MdwTags.set(Data);
        Debug("SetTags -> Tags were set!");
    });

    OnEvent("Mdw/SetCerts", Data => {
        MdwCerts.set(Data);
        Debug("SetCerts -> Certs were set!");
    });

    OnEvent("Mdw/SetRanks", Data => {
        MdwRanks.set(Data);
        Debug("SetRanks -> Ranks were set!");
    });

    OnEvent("Mdw/SetEvidence", Data => {
        MdwEvidence.set(Data);
        Debug("SetEvidence -> Evidence were set!");
    });

    OnEvent("Mdw/SetRoles", Data => {
        MdwRoles.set(Data);
        Debug("SetRoles -> Roles were set!");
    });
</script>

<AppWrapper AppName="Mdw" Focused={MdwVisible}>
    <div class="mdw-wrapper {MdwVisible ? "mdw-wrapper-in" : "mdw-wrapper-out"}" style="opacity: {MdwVisible ? Opacity : 0.0}">
        {#if $MdwModalsExport.Show} <ModalsExport/> {/if}
        {#if $MdwModalsTags.Show} <ModalsTags/> {/if}
        {#if $MdwModalsCerts.Show} <ModalsCerts/> {/if}
        {#if $MdwModalsRoles.Show} <ModalsRoles/> {/if}
        {#if $MdwModalsUnits.Show} <ModalsUnits/> {/if}
        {#if $MdwModalsPerson.Show} <ModalsPerson/> {/if}
        {#if $MdwModalsEvidence.Show} <ModalsEvidence/> {/if}
        {#if $MdwModalsProfiles.Show} <ModalsProfiles/> {/if}
        {#if $MdwModalsCharges.Show} <ModalsCharges/> {/if}
        {#if $MdwModalsPermissions.Show} <ModalsPermissions/> {/if}
        {#if $MdwModalsChargeEditor.Show} <ModalsChargeEditor/> {/if}
        {#if $MdwModalsVehicleHistory.Show} <ModalsVehicleHistory/> {/if}
    
        {#if $ShowLoader}
            <div class="mdw-loader-modal">
                <div class="mdw-loader-modal-container">
                    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" style="margin: auto; background: transparent; display: block; shape-rendering: auto;" width="13.5vh" height="13.5vh" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid">
                        <g transform="rotate(0 50 50)">
                            <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                                <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.9166666666666666s" repeatCount="indefinite"></animate>
                            </rect>
                        </g>
                        <g transform="rotate(30 50 50)">
                            <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                                <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.8333333333333334s" repeatCount="indefinite"></animate>
                            </rect>
                        </g>
                        <g transform="rotate(60 50 50)">
                            <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                                <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.75s" repeatCount="indefinite"></animate>
                            </rect>
                        </g>
                        <g transform="rotate(90 50 50)">
                            <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                                <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.6666666666666666s" repeatCount="indefinite"></animate>
                            </rect>
                        </g>
                        <g transform="rotate(120 50 50)">
                            <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                                <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.5833333333333334s" repeatCount="indefinite"></animate>
                            </rect>
                        </g>
                        <g transform="rotate(150 50 50)">
                            <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                                <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.5s" repeatCount="indefinite"></animate>
                            </rect>
                        </g>
                        <g transform="rotate(180 50 50)">
                            <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                                <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.4166666666666667s" repeatCount="indefinite"></animate>
                            </rect>
                        </g>
                        <g transform="rotate(210 50 50)">
                            <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                                <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.3333333333333333s" repeatCount="indefinite"></animate>
                            </rect>
                        </g>
                        <g transform="rotate(240 50 50)">
                            <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                                <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.25s" repeatCount="indefinite"></animate>
                            </rect>
                        </g>
                        <g transform="rotate(270 50 50)">
                            <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                                <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.16666666666666666s" repeatCount="indefinite"></animate>
                            </rect>
                        </g>
                        <g transform="rotate(300 50 50)">
                            <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                                <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.08333333333333333s" repeatCount="indefinite"></animate>
                            </rect>
                        </g>
                        <g transform="rotate(330 50 50)">
                            <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                                <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="0s" repeatCount="indefinite"></animate>
                            </rect>
                        </g>
                    </svg>
                </div>
            </div>
        {/if}
        <MdwTopbar on:mouseenter={() => { Opacity = 0.5 }} on:mouseleave={() => { Opacity = 1.0}}/>
    
        {#if Opacity > 0.0}
            <MdwNavbar/>
            <MdwContainer/>
        {/if}
    </div>
</AppWrapper>

<style>
    .mdw-wrapper {
        position: absolute;
        top: 200%;
        left: 50%;
        transform: translate(-50%, -50%);
        width: 174.5vh;
        height: 96vh;
        background-color: #2e465e;
        overflow: hidden auto
    }

    .mdw-wrapper-in {
        animation: mdwWrapperIn 500ms ease-in-out;
        animation-fill-mode: forwards;
    }

    .mdw-wrapper-out {
        animation: mdwWrapperOut 500ms ease-in-out;
        animation-fill-mode: forwards;
    }

    @keyframes mdwWrapperIn {
        0% { top: 200% }
        100% { top: 50% }
    }

    @keyframes mdwWrapperOut {
        0% { top: 50% }
        100% { top: 200% }
    }

    .mdw-loader-modal {
        position: absolute;
        z-index: 999;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.7);
    }

    .mdw-loader-modal-container {
        position: absolute;
        top: 50%;
        left: 50%;
        width: max-content;
        min-width: 20%;
        height: max-content;
        padding: 2.5vh 0;
        transform: translate(-50%, -50%);
        background-color: rgb(34, 40, 49);
    }
</style>
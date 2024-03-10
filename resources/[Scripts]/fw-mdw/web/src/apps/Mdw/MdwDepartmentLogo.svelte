<script>
    import { MdwProfile } from "../../stores";

    const DepartmentLogos = {
        LSPD: "mdw-lspd",
        BCSO: "mdw-bcso",
        SASP: "mdw-sasp",
        SDSO: "mdw-sdso",
        RANGER: "mdw-ranger",
    }
</script>

<img class="mdw-department-logo" src="./images/{DepartmentLogos[$MdwProfile.department] || "mdw-generic"}.png" alt="">

<style>
    .mdw-department-logo {
        position: relative;
        margin-left: 1.7vh;
        margin-top: 3.2vh;
        width: 30vh;
    }
</style>
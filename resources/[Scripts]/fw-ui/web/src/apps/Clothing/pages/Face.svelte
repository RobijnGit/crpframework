<script>
    import ClothingTab from "../components/ClothingTab.svelte";
    import CardSlider from "../components/CardSlider.svelte";
    import CardValue from "../components/CardValue.svelte";
</script>


<!-- Nose -->
<ClothingTab
    Title="Neus"
    DisableTextureField={true}
>
    <div style="width: 100%;">
        <CardSlider componentId="FaceNose" valueId={0} label="Neus breedte"/>
        <CardSlider componentId="FaceNose" valueId={1} label="Piekhoogte"/>
        <CardSlider componentId="FaceNose" valueId={2} label="Piekverlaging"/>
    </div>
    
    <div style="width: 100%;">
        <CardSlider componentId="FaceNose" valueId={3} label="Bothoogte"/>
        <CardSlider componentId="FaceNose" valueId={4} label="Pieklengte"/>
        <CardSlider componentId="FaceNose" valueId={5} label="Botendraai"/>
    </div>
</ClothingTab>

<!-- Eyebrows -->
<ClothingTab
    Title="Wenkbrauwen"
    DisableTextureField={true}
>
    <div style="width: 100%;">
        <CardSlider componentId="FaceEyebrows" valueId={0} label="Wenkbrauwhoogte"/>
        <CardSlider componentId="FaceEyebrows" valueId={1} label="Wenkbrauwdiepte"/>
    </div>
</ClothingTab>

<!-- Eye Color -->
<ClothingTab
    Title="Oogkleur"
    AmountComponents={33}
    DisableTextureField={true}
>
    <div style="width: 100%;">
        <CardValue componentId="FaceEyeColor" valueType="Drawable"/>
    </div>
</ClothingTab>

<!-- Cheeks -->
<ClothingTab
    Title="Wangen"
    DisableTextureField={true}
>
    <div style="width: 100%;">
        <CardSlider componentId="FaceCheeks" valueId={0} label="Jukbeenhoogte"/>
        <CardSlider componentId="FaceCheeks" valueId={1} label="Jukbeenbreedte"/>
        <CardSlider componentId="FaceCheeks" valueId={2} label="Wangbreedte"/>
    </div>
</ClothingTab>

<!-- Jaw Bone -->
<ClothingTab
    Title="Kaakbeen"
    DisableTextureField={true}
>
    <div style="width: 100%;">
        <CardSlider componentId="FaceJawBone" valueId={0} label="Kaakbeenbreedte"/>
        <CardSlider componentId="FaceJawBone" valueId={1} label="Kaakbeenlengte"/>
    </div>
</ClothingTab>

<!-- Chin -->
<ClothingTab
    Title="Kin"
    DisableTextureField={true}
>
    <div style="width: 100%;">
        <CardSlider componentId="FaceChin" valueId={0} label="Kinbeenhoogte"/>
        <CardSlider componentId="FaceChin" valueId={1} label="Kinbeenlengte"/>
    </div>
    
    <div style="width: 100%;">
        <CardSlider componentId="FaceChin" valueId={2} label="Kinbeenbreedte"/>
        <CardSlider componentId="FaceChin" valueId={3} label="Kin gespleten"/>
    </div>
</ClothingTab>

<!-- Miscellaneous Features -->
<ClothingTab
    Title="Miscellaneous"
    DisableTextureField={true}
>
    <div style="width: 100%;">
        <CardSlider componentId="FaceMisc" valueId={0} label="Ogen scheel"/>
        <CardSlider componentId="FaceMisc" valueId={1} label="Lippendikte"/>
    </div>
    
    <div style="width: 100%;">
        <CardSlider componentId="FaceMisc" valueId={2} label="Nekdikte"/>
    </div>
</ClothingTab>
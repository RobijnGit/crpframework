(()=>{"use strict";var e={185:(e,t,a)=>{Object.defineProperty(t,"__esModule",{value:!0});const r=a(586),n=a(483);n.FW.RegisterServer("fw-medical:Server:HealPlayer",(async(e,t)=>{const a=n.FW.Functions.GetPlayer(e);if(!a)return;const r=n.FW.Functions.GetPlayer(t);r&&await a.Functions.RemoveItemByName("medkit",1,!0)&&(emitNet("fw-medical:Client:ClearBoneDamage",t),emitNet("fw-medical:Client:ResetBleeding",t),emitNet("fw-medical:Client:HealPlayer",t),r.Functions.Notify("Je wonden zijn verholpen..","success"))})),n.FW.RegisterServer("fw-medical:Server:RevivePlayer",(async(e,t)=>{const a=n.FW.Functions.GetPlayer(e);if(!a)return;const r=n.FW.Functions.GetPlayer(t);r&&await a.Functions.RemoveItemByName("medkit",1,!0)&&(emitNet("fw-medical:Client:ClearBoneDamage",t),emitNet("fw-medical:Client:ResetBleeding",t),emitNet("fw-medical:Client:Revive",t,!0),r.PlayerData.metadata.hunger<5&&r.Functions.SetMetaData("hunger",5),r.PlayerData.metadata.thirst<5&&r.Functions.SetMetaData("thirst",5))})),n.FW.RegisterServer("fw-medical:Server:TakeBlood",((e,t)=>{if(!n.FW.Functions.GetPlayer(e))return;const a=n.FW.Functions.GetPlayer(t);a&&(a.Functions.Notify("Je bloed is afgenomen.."),emitNet("chat:addMessage",e,{args:[a.PlayerData.metadata.bloodtype,a.PlayerData.citizenid],template:'\n            <div class="chat-message error">\n                <div class="chat-message-body">\n                    <strong>Bloedmonster:</strong><br>\n                    Bloedtype: {0}<br>\n                    BSN: {1}<br>\n                </div>\n            </div>\n        '}))})),n.FW.RegisterServer("fw-medical:Server:SwabDNA",((e,t)=>{if(!n.FW.Functions.GetPlayer(e))return;const a=n.FW.Functions.GetPlayer(t);a&&(a.Functions.Notify("Je speeksel is afgenomen.."),emitNet("chat:addMessage",e,{args:[a.PlayerData.metadata.slimecode,a.PlayerData.citizenid],template:'\n            <div class="chat-message error">\n                <div class="chat-message-body">\n                    <strong>DNA-sample:</strong><br>\n                    Code: {0}<br>\n                    BSN: {1}<br>\n                </div>\n            </div>\n        '}))})),n.FW.Commands.Add("factuur","Schrijf een medische factuur uit.",[{name:"Player ID",help:"Het ID van de speler"},{name:"Bedrag",help:"Hoeveel bedraagt het factuur?"}],!0,(async(e,t)=>{const a=n.FW.Functions.GetPlayer(e);if(!a)return;if("ems"!=a.PlayerData.job.name||!a.PlayerData.job.onduty)return a.Functions.Notify("Geen toegang..","error");const i=n.FW.Functions.GetPlayer(Number(t[0]));if(!i)return;let s=Number(t[1]);if(s<=0)return a.Functions.Notify("Factuur moet minstens € 1,00 euro zijn!","error");const o=n.FW.Shared.CalculateTax("Services",s);await r.exp["fw-financials"].RemoveMoneyFromAccount("1001","2",i.PlayerData.charinfo.account,o,"BILL","Ziekenkosten",!0)&&(r.exp["fw-financials"].AddMoneyToAccount(a.PlayerData.citizenid,a.PlayerData.charinfo.account,"2",Math.ceil(.85*s),"BILL","Ziekenkosten"),r.exp["fw-financials"].AddMoneyToAccount(i.PlayerData.citizenid,i.PlayerData.charinfo.account,a.PlayerData.charinfo.account,Math.ceil(.15*s),"BILL","Ziekenkosten"),r.exp["fw-financials"].AddMoneyToAccount("1001","1","1",o-s,"BILL",`Services Tax. (Medisch Factuur: ${r.exp["fw-businesses"].NumberWithCommas(s)})`),emitNet("chatMessage",e,"SYSTEM","warning",`Je hebt een factuur uitgeschreven van ${r.exp["fw-businesses"].NumberWithCommas(s)} - Je ontvangt €${Math.ceil(.15*s)}!`),emitNet("chatMessage",i.PlayerData.source,"SYSTEM","warning",`Je kreeg een factuur van ${r.exp["fw-businesses"].NumberWithCommas(o)}!`),emit("fw-logs:Server:Log","ems","Bill Sent",`User: [${a.PlayerData.source}] - ${a.PlayerData.citizenid} - ${a.PlayerData.charinfo.firstname} ${a.PlayerData.charinfo.lastname}\nTarget: [${i.PlayerData.source}] - ${i.PlayerData.citizenid} - ${i.PlayerData.charinfo.firstname} ${i.PlayerData.charinfo.lastname}\nBill: ${r.exp["fw-businesses"].NumberWithCommas(s)}`,"green"))}))},483:(e,t,a)=>{Object.defineProperty(t,"__esModule",{value:!0}),t.FW=void 0;const r=a(586),n=a(714),i=a(180);t.FW=r.exp["fw-core"].GetCoreObject(),a(185);let s=[];onNet("fw-medical:Server:SetDeathState",(e=>{const a=source,r=t.FW.Functions.GetPlayer(a);r&&r.Functions.SetMetaData("isdead",e)})),t.FW.RegisterServer("fw-medical:Server:SaveHealth",((e,a,r)=>{const n=t.FW.Functions.GetPlayer(e);n&&(n.Functions.SetMetaData("health",a),n.Functions.SetMetaData("armor",r))})),t.FW.RegisterServer("fw-medical:Server:PayMedicalFee",(async(e,a)=>{const i=t.FW.Functions.GetPlayer(e);if(!i)return;const s=a?n.Config.MedicalFee*n.Config.FeeMultiplier:n.Config.MedicalFee;await r.exp["fw-financials"].RemoveMoneyFromAccount("1001","2",i.PlayerData.charinfo.account,s,"BILL","Medische Zorg",!0)&&r.exp["fw-financials"].AddMoneyToAccount(i.PlayerData.citizenid,i.PlayerData.charinfo.account,"2",s,"BILL","Medische Zorg")})),t.FW.RegisterServer("fw-medical:Server:ClearInventory",(e=>{const a=t.FW.Functions.GetPlayer(e);a&&r.exp["fw-inventory"].ClearInventory(`ply-${a.PlayerData.citizenid}`)})),t.FW.Functions.CreateCallback("fw-medical:Server:GetHospitalBed",((e,a)=>{const r=t.FW.Functions.GetPlayer(e);if(!r)return;const n=(new i.Vector3).setFromArray(GetEntityCoords(GetPlayerPed(e))),c=o(n,r.PlayerData.metadata.jailtime>0||r.PlayerData.metadata.islifer);c&&(s.push(c.BedId),setTimeout((()=>{const e=s.indexOf(c.BedId);s.splice(e,1)}),15e3),a(c))})),t.FW.Functions.CreateCallback("fw-medical:Server:CanCheckIn",((e,a)=>{if(!t.FW.Functions.GetPlayer(e))return;let r=0;const n=t.FW.GetPlayers();for(let e=0;e<n.length;e++){const i=n[e],s=t.FW.Functions.GetPlayer(i.ServerId);if(s&&"ems"==s.PlayerData.job.name&&s.PlayerData.job.onduty&&r++,r>=2)return a(!1)}a(!0)}));const o=(e,t)=>{let a=0,r=Number.MAX_SAFE_INTEGER;for(let i=0;i<n.Config.HospitalBeds.length;i++){const s=n.Config.HospitalBeds[i],o=s.Center.getDistance(e);(!s.IsPrison||t)&&r>o&&(a=i,r=o)}for(let e=0;e<n.Config.HospitalBeds[a].Beds.length;e++){const t=n.Config.HospitalBeds[a].Beds[e];if(!s.includes(t.BedId))return t}return!1};t.FW.Commands.Add("setemsvehicle","Geef een ambulance voertuig aan een werknemer",[{name:"Id",help:"Werknemer Server ID"},{name:"Vehicle",help:"Speedo / Motor / Taurus / Flight / Water / Commander"},{name:"Status",help:"True / False"}],!0,((e,a)=>{const r=t.FW.Functions.GetPlayer(e),n=t.FW.Functions.GetPlayer(Number(a[0]));n&&r&&"ems"==r.PlayerData.job.name&&r.PlayerData.metadata.ishighcommand&&("true"==a[2].toLowerCase()?(n.Functions.SetMetaDataTable("ems-vehicle",a[1].toUpperCase(),!0),n.Functions.Notify(`Je hebt een voertuig specialisatie ontvangen! (${a[1].toUpperCase()})`,"success"),r.Functions.Notify(`Specialisatie ${a[1].toUpperCase()} gegeven aan ${n.PlayerData.citizenid}`,"success")):(n.Functions.SetMetaDataTable("ems-vehicle",a[1].toUpperCase(),!1),n.Functions.Notify(`Je specialisatie is afgenomen.. (${a[1].toUpperCase()})`,"error"),r.Functions.Notify(`Specialisatie ${a[1].toUpperCase()} ontnomen van ${n.PlayerData.citizenid}`,"error")))})),onNet("fw-hospital:Server:PurchaseVehicle",(async e=>{const a=source,n=t.FW.Functions.GetPlayer(a);if(!n)return;if("ems"!=n.PlayerData.job.name)return;const i=t.FW.Shared.HashVehicles[GetHashKey(e.Vehicle)],s=await t.FW.Functions.GeneratePlate(),o=await t.FW.Functions.GenerateVin(),c=e.Shared?"2":n.PlayerData.charinfo.account,l=t.FW.Shared.CalculateTax("Vehicle Registration Tax",i.Price);await r.exp["fw-financials"].RemoveMoneyFromAccount("1001","1",c,l,"PURCHASE",`Voertuig aankoop ${i.Name}`,!1)?(r.exp.ghmattimysql.execute("INSERT INTO `player_vehicles` (`citizenid`, `vehicle`, `plate`, `garage`, `vinnumber`) VALUES (?, ?, ?, ?, ?)",[e.Shared?"gov_ems":n.PlayerData.citizenid,e.Vehicle,s,"gov_crusade",o]),r.exp.ghmattimysql.executeSync("INSERT INTO `vehicles_ownership` (seller, buyer, plate, price, timestamp) VALUES (?, ?, ?, ?, ?)",["1001",e.Shared?"gov_ems":n.PlayerData.citizenid,s,l,(new Date).getTime()]),TriggerClientEvent("FW:Notify",n.PlayerData.source,`Je hebt een ${i.Name} gekocht..`,"success")):n.Functions.Notify("Niet genoeg geld..","error")}))},862:(e,t)=>{Object.defineProperty(t,"__esModule",{value:!0}),t.easeCubicBezier=t.easeInOutQuint=t.easeOutQuint=t.easeInQuint=t.easeInOutQuart=t.easeOutQuart=t.easeInQuart=t.easeInOutCubic=t.easeOutCubic=t.easeInCubic=t.easeInOutQuad=t.easeOutQuad=t.easeInQuad=t.easeInOutSine=t.easeOutSine=t.easeInSine=t.linear=t.lerp=t.clamp=void 0,t.clamp=(e,t,a)=>Math.max(t,Math.min(a,e)),t.lerp=(e,t,a)=>e*(1-a)+t*a,t.linear=e=>(0,t.clamp)(e,0,1),t.easeInSine=e=>1-Math.cos(e*Math.PI/2),t.easeOutSine=e=>Math.sin(e*Math.PI/2),t.easeInOutSine=e=>-(Math.cos(Math.PI*e)-1)/2,t.easeInQuad=e=>(e=(0,t.clamp)(e,0,1))*e,t.easeOutQuad=e=>(e=(0,t.clamp)(e,0,1))*(2-e),t.easeInOutQuad=e=>(e=(0,t.clamp)(e,0,1))<.5?2*e*e:(4-2*e)*e-1,t.easeInCubic=e=>(e=(0,t.clamp)(e,0,1))*e*e,t.easeOutCubic=e=>(e=(0,t.clamp)(e,0,1),--e*e*e+1),t.easeInOutCubic=e=>(e=(0,t.clamp)(e,0,1))<.5?4*e*e*e:(e-1)*(2*e-2)*(2*e-2)+1,t.easeInQuart=e=>(e=(0,t.clamp)(e,0,1))*e*e*e,t.easeOutQuart=e=>(e=(0,t.clamp)(e,0,1),1- --e*e*e*e),t.easeInOutQuart=e=>(e=(0,t.clamp)(e,0,1))<.5?8*e*e*e*e:1-8*--e*e*e*e,t.easeInQuint=e=>(e=(0,t.clamp)(e,0,1))*e*e*e*e,t.easeOutQuint=e=>(e=(0,t.clamp)(e,0,1),1+--e*e*e*e*e),t.easeInOutQuint=e=>(e=(0,t.clamp)(e,0,1))<.5?16*e*e*e*e*e:1+16*--e*e*e*e*e,t.easeCubicBezier=(e,t,a,r,n)=>3*e*Math.pow(1-e,2)*t+3*e*e*(1-e)*r+e*e*e},180:function(e,t,a){var r=this&&this.__createBinding||(Object.create?function(e,t,a,r){void 0===r&&(r=a);var n=Object.getOwnPropertyDescriptor(t,a);n&&!("get"in n?!t.__esModule:n.writable||n.configurable)||(n={enumerable:!0,get:function(){return t[a]}}),Object.defineProperty(e,r,n)}:function(e,t,a,r){void 0===r&&(r=a),e[r]=t[a]}),n=this&&this.__exportStar||function(e,t){for(var a in e)"default"===a||Object.prototype.hasOwnProperty.call(t,a)||r(t,e,a)};Object.defineProperty(t,"__esModule",{value:!0}),t.Degrees=t.Radians=void 0,n(a(862),t),n(a(903),t),t.Radians=e=>e*Math.PI/180,t.Degrees=e=>180*e/Math.PI},903:(e,t)=>{Object.defineProperty(t,"__esModule",{value:!0}),t.Vector3=void 0;class a{constructor(e=0,t=0,a=0){this.x=e,this.y=t,this.z=a}setFromArray(e){return this.x=e[0],this.y=e[1],this.z=e[2],this}setFromObject(e){return this.x=e.x,this.y=e.y,this.z=e.z,this}getArray(){return[this.x,this.y,this.z]}add(e){return this.x+=e.x,this.y+=e.y,this.z+=e.z,this}addScalar(e){return this.x+=e,this.y+=e,this.z+=e,this}sub(e){return this.x-=e.x,this.y-=e.y,this.z-=e.z,this}cross(e){const t=this.x,a=this.y,r=this.z,n=e.x,i=e.y,s=e.z;return this.x=a*s-r*i,this.y=r*n-t*s,this.z=t*i-a*n,this}equals(e){return this.x===e.x&&this.y===e.y&&this.z===e.z}subScalar(e){return this.x-=e,this.y-=e,this.z-=e,this}multiply(e){return this.x*=e.x,this.y*=e.y,this.z*=e.z,this}multiplyScalar(e){return this.x*=e,this.y*=e,this.z*=e,this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this.z=Math.round(this.z),this}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this.z=Math.floor(this.z),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this.z=Math.ceil(this.z),this}magnitude(){return Math.sqrt(this.x*this.x+this.y*this.y+this.z*this.z)}normalize(){let e=this.magnitude();return isNaN(e)&&(e=0),this.multiplyScalar(1/e)}forward(){const e=a.fromObject(this).multiplyScalar(Math.PI/180);return new a(-Math.sin(e.z)*Math.abs(Math.cos(e.x)),Math.cos(e.z)*Math.abs(Math.cos(e.x)),Math.sin(e.x))}right(){const e=a.fromObject(this).multiplyScalar(Math.PI/180);return new a(Math.cos(e.z)*Math.abs(Math.cos(e.y)),Math.sin(e.z)*Math.abs(Math.cos(e.y)),-Math.sin(e.y))}up(){return this.right().cross(this.forward())}up2(){return this.forward().cross(this.right())}angle(e){const t=this.dot(e);return Math.acos(t)*(180/Math.PI)}dot(e){return this.x*e.x+this.y*e.y+this.z*e.z}getDistance(e){const[t,a,r]=[this.x-e.x,this.y-e.y,this.z-e.z];return Math.sqrt(t*t+a*a+r*r)}getDistanceFromArray(e){const[t,a,r]=[this.x-e[0],this.y-e[1],this.z-e[2]];return Math.sqrt(t*t+a*a+r*r)}getDistance2D(e,t){const[a,r]=[this.x-e,this.y-t];return Math.sqrt(a*a+r*r)}copy(){return a.fromArray(this.getArray())}toObject(){return{x:this.x,y:this.y,z:this.z}}toArray(){return[this.x,this.y,this.z]}static fromArray(e){return new a(e[0],e[1],e[2])}static fromObject(e){return new a(e.x,e.y,e.z)}}t.Vector3=a},714:(e,t,a)=>{Object.defineProperty(t,"__esModule",{value:!0}),t.Config=void 0;const r=a(180);t.Config={AdrenalineTimer:10,MedicalFee:125,FeeMultiplier:2,RespawnTimer:300,MinorTimer:60,EnableGovTimer:!0,OxyBloodThreshold:65,RagdollBones:["LLEG","RLEG","LFOOT","RFOOT"],VehicleCerts:{emsspeedo:"SPEEDO",emstau:"TAURUS",emsmotor:"MOTOR",emsexp:"COMMANDER",emsaw139:"FLIGHT",dinghy4:"WATER"},HospitalBeds:[{Center:new r.Vector3(347.17,-1400.94,32.5),Beds:[{BedId:1,Model:1004440924,Coords:new r.Vector3(361.18,-1407.45,32.06)},{BedId:2,Model:1004440924,Coords:new r.Vector3(365.27,-1402.61,32.06)},{BedId:3,Model:1004440924,Coords:new r.Vector3(367.84,-1404.77,32.06)},{BedId:4,Model:1004440924,Coords:new r.Vector3(370.38,-1406.9,32.06)},{BedId:5,Model:1004440924,Coords:new r.Vector3(366.33,-1411.76,32.06)},{BedId:6,Model:1004440924,Coords:new r.Vector3(372.98,-1409.09,32.06)},{BedId:7,Model:1004440924,Coords:new r.Vector3(368.9,-1413.92,32.06)}]},{Center:new r.Vector3(-818.38,-1228.65,7.34),Beds:[{BedId:8,Model:1631638868,Coords:new r.Vector3(-800.1,-1234.66,6.9)},{BedId:9,Model:1631638868,Coords:new r.Vector3(-804.13,-1231.27,6.9)},{BedId:10,Model:1631638868,Coords:new r.Vector3(-806.74,-1229.08,6.9)},{BedId:11,Model:1631638868,Coords:new r.Vector3(-809.52,-1226.75,6.9)},{BedId:12,Model:1631638868,Coords:new r.Vector3(-812.25,-1224.46,6.9)},{BedId:13,Model:1631638868,Coords:new r.Vector3(-809.21,-1220.92,6.9)},{BedId:14,Model:1631638868,Coords:new r.Vector3(-805.48,-1224.05,6.9)},{BedId:15,Model:1631638868,Coords:new r.Vector3(-801.01,-1227.8,6.9)},{BedId:16,Model:1631638868,Coords:new r.Vector3(-797.06,-1231.11,6.9)}]},{Center:new r.Vector3(1670.36,3654.27,35.34),Beds:[{BedId:17,Model:1004440924,Coords:new r.Vector3(1676.07,3647.12,34.9)}]},{Center:new r.Vector3(-252.43,6322.02,32.45),Beds:[{BedId:18,Model:1004440924,Coords:new r.Vector3(-244.22,6317.58,32.01)}]},{Center:new r.Vector3(1765.11,2594.72,45.73),IsPrison:!0,Beds:[{BedId:19,Model:2117668672,Coords:new r.Vector3(1771.98,2591.8,45.3)},{BedId:20,Model:2117668672,Coords:new r.Vector3(1771.98,2594.88,45.3)},{BedId:21,Model:2117668672,Coords:new r.Vector3(1771.98,2597.95,45.3)},{BedId:22,Model:2117668672,Coords:new r.Vector3(1761.87,2597.73,45.3)},{BedId:23,Model:2117668672,Coords:new r.Vector3(1761.87,2594.64,45.3)},{BedId:24,Model:2117668672,Coords:new r.Vector3(1761.87,2591.56,45.3)}]}]}},586:(e,t,a)=>{Object.defineProperty(t,"__esModule",{value:!0}),t.GetRandom=t.Delay=t.exp=void 0,t.exp=a.g.exports,t.Delay=e=>new Promise((t=>setTimeout(t,e))),t.GetRandom=(e,t)=>Math.floor(Math.random()*(t-e+1))+e}},t={};function a(r){var n=t[r];if(void 0!==n)return n.exports;var i=t[r]={exports:{}};return e[r].call(i.exports,i,i.exports,a),i.exports}a.g=function(){if("object"==typeof globalThis)return globalThis;try{return this||new Function("return this")()}catch(e){if("object"==typeof window)return window}}(),a(483)})();
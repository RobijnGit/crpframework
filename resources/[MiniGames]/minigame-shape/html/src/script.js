"use strict"

import { $, delay, playSound } from './helpers.js'
import { doPuzzle } from './puzzle-handler.js'

// runs on site load and handles entire  flow
async function start(duration,puzzlelength,amount){

    // reset from previous
    $('.try-again').classList.add('hidden')
    $('.spy-icon').src = 'assets/spy-icon.png'

    const dialing = playSound('assets/dialing.mp3', 0.1)

    // mock loading screen
    setInformationText('VERBINDING MAKEN')
    await delay(10)
    setInformationText('BEVEILIGING DOORBREKEN..')
    await delay(8)
    setInformationText('BEVEILIGINGS CODE ERROR; HEEFT MENSELIJKE CAPTCHA TEST NODIG..')
    await delay(3)

    // hide text and show squares
    $('#text-container').classList.toggle('hidden')
    $('#number-container').classList.toggle('hidden')


    // activate puzzle a times, break on fail
    let submitted
    let answer
    let result = true

    for (let i = 0; i < amount && result; i++) {
        [submitted, answer] = await doPuzzle(duration,puzzlelength)
        result = (submitted?.toLowerCase() == answer)
    }

    // hide squares and show text
    $('.answer-section').classList.add('hidden')
    $('.number-container').classList.add('hidden')
    $('#text-container').classList.remove('hidden')
    
    // display result
    setInformationText((result) ? 'Het beveiligingssysteem is uitgeschakeld!' : "Het systeem accepteerde jouw antwoord niet..")
    
    if(!result) {
    	$('.spy-icon').src = 'assets/failed.png'
    	$('#answer-reveal').textContent = answer
        await delay(5)
    }

    fetch('https://minigame-shape/callback', {
        method: 'POST', 
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            success: result
        }) 
      });

    $(".bg").classList.add('hidden');

    $('#submitted-reveal').textContent = (result) ? 'Good job, indeed the' : ((submitted == null) ?  "The time ran out," : `You wrote "${submitted || ' '}", the`)
}


function setInformationText(text){
    
    const capitalized = text.toUpperCase()
    const infoText = `<span class="capital">${capitalized.charAt(0)}</span>${capitalized.substring(1)}`
    
    $("#loading-text").innerHTML = infoText
}


// count visitors
window.dataLayer = window.dataLayer || [];
function gtag(){dataLayer.push(arguments);}
gtag('js', new Date());
gtag('config', 'G-7E64QM2WXT');


window.addEventListener('message', function(event){
    if (event.data.action == "open") {
        start(event.data.duration, event.data.length,event.data.amount)
        $(".bg").classList.remove('hidden');
    }
})

// start(12, 4, 4)
// $(".bg").classList.remove('hidden');
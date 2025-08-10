
let chars = {};
let selectedindex = null;
let maxChar = null;

$(document).ready(function () {
    window.addEventListener("message", function (event) {
        let data = event.data;

        if (data.type == "display") {
            if (data.bool) return $("body").fadeIn();
            $("body").fadeOut();
        }
        if (data.type == "sendChars") {
            chars = {};
            maxChar = data.maxchars;
            data.data.forEach((element, index) => {
                const charnumber = index + 1;
                const charinf = element;
                chars[charnumber] = charinf;
            });
            selectedindex = 1;
            const totalUsed = Object.keys(chars).length;
            if (totalUsed >= maxChar) {
                $(".newCharText").hide();
            } else {
                $(".newCharText").show();
            }

            if (chars[selectedindex]) {
                loadchar();
            } else {
                setCreator();
            }
        }
    });
});
// 

async function ChangeChar(deger = 1) {
    if (!maxChar || selectedindex + deger > maxChar || selectedindex + deger <= 0) {
        return;
    }
    if (chars[(selectedindex + deger)]) {
        selectedindex = selectedindex + deger;
        loadchar(selectedindex);

    } else {
        selectedindex = selectedindex + deger;
        $.post("https://PX-MultiCharacter/delSkin");
        setCreator();
    }
}

function setCreator() {
    $(".playerInformationBox").fadeOut();
    $(".createCharacterBox").fadeIn();
    $(".charName").html("CREATE <div class='charSurname'>CHARACTER</div>");
}

function ckplayer() {
    const selectedChar = chars[selectedindex];
    if (!selectedChar) return;
    const charId = selectedChar.charidentifier;
    $.post("https://PX-MultiCharacter/deleteChar", JSON.stringify({ charId: charId }));
}

function openCreateArea() {
    $(".createCharacterBox").fadeIn();
    $(".createnewkarakteryaziaminakoyumbunukoyanin").fadeIn();
}

function playchar() {
    if (chars[selectedindex]) {
        $.post("https://PX-MultiCharacter/selectChar", JSON.stringify({ charid: chars[selectedindex].charidentifier }));
    } else {
        createChar();
    }
}

function loadchar() {
    $(".createCharacterBox").css("display", "none");
    $(".charName").html(`${chars[selectedindex].firstname} <div class="charSurname">${chars[selectedindex].lastname}</div>`);
    $("#job").text(chars[selectedindex].job || "Sivil");
    $("#nationality").text(chars[selectedindex].nationality || "Türkiye");
    $("#birthdate").text(chars[selectedindex].birthdate || "");
    $("#cash").text(chars[selectedindex].cash || 0);
    $("#bank").text(chars[selectedindex].bank || 0);
    $(".playerInformationBox").fadeIn("slow");
    $(".createCharacterBox").fadeOut();
    $.post("https://PX-MultiCharacter/getSkinOfChar", JSON.stringify({ charidentifier: chars[selectedindex].charidentifier }));
    console.log(chars[selectedindex].charidentifier);
}

function createChar() {
    const firstname = $("#isimsoyisim").val().trim();
    const lastname = $("#lastname").val().trim();
    const cid = selectedindex;
    const gender = $("#genderS").val();
    const birthdate = $("#dogumTarihi").val();
    const nationality = $("#countrylist").val();
    if (!firstname || !lastname || !gender || !birthdate || !nationality) {
        return;
    }
    $.post("https://PX-MultiCharacter/createChar", JSON.stringify({
        firstname, lastname, cid, gender, birthdate, nationality
    }));
    $(".createChar").fadeOut();
}

function exitgame() {
    $.post("https://PX-MultiCharacter/exitgame", JSON.stringify({}));
}

async function loadCountries() {
    try {
        const response = await fetch('https://countriesnow.space/api/v0.1/countries/');
        if (response.ok) {
            const data = await response.json();
            const result = data.data;
            result.forEach(obj => {
                $("#countrylist").append(`<option value="${obj.country}">${obj.country}</option>`);
            });
        }
    } catch (error) {
        console.error("Error loading countries:", error);
    }
}

$(document).ready(function () {
    loadCountries();
    // Config.DeleteChar değerini al
    $.post('https://PX-MultiCharacter/getDeleteCharConfig', JSON.stringify({}));

    const hoverSound = document.getElementById('hoverSound');
    const clickSound = document.getElementById('clickSound');
    const elements = $('.playGameText, .photoModeText, .creditsText, .exitGameText, .newCharText');
    elements.hover(function () {
        hoverSound.currentTime = 1;
        hoverSound.play();
    });
    elements.on('click', function () {
        clickSound.currentTime = 0;
        clickSound.play();
    });
});

$(document).on("keydown", function () {
    switch (event.keyCode) {
        case 27:
            $(".createnewkarakteryaziaminakoyumbunukoyanin").fadeOut();
            $(".createCharacterBox").fadeOut();
    }
});

function openCredits() {
    $.post('https://PX-MultiCharacter/openCredits', JSON.stringify({}));
    document.body.classList.add('credits-active');
}

function closeCredits() {
    document.getElementById('creditsModal').style.display = 'none';
    document.body.classList.remove('credits-active');
}

window.addEventListener('message', function (event) {
    if (event.data.action === "showCredits") {
        document.getElementById('creditsModal').style.display = 'block';
        var content = document.querySelector('.credits-modal-content p');
        content.innerHTML = event.data.credits;
        var modalContent = document.querySelector('.credits-modal-content');
        modalContent.style.animation = 'none';
        // trigger reflow for restart animation
        void modalContent.offsetWidth;
        modalContent.style.animation = null;
        // Animasyon bitince modalı kapat
        modalContent.addEventListener('animationend', closeCredits, { once: true });
    }

    if (event.data.action === "setDeleteCharConfig") {
        if (!event.data.deleteCharEnabled) {
            $('.playerDelete').hide();
        } else {
            $('.playerDelete').show();
        }
    }
});


window.addEventListener('keydown', function (e) {
    if (document.body.classList.contains('credits-active')) {
        if (e.key === 'Escape' || e.key === 'Esc' || e.keyCode === 27) {
            document.getElementById('creditsModal').style.display = 'none';
            document.body.classList.remove('credits-active');
        }
    }

    if (document.body.classList.contains('photo-mode-active')) {
        if (e.key === 'Escape' || e.key === 'Esc' || e.keyCode === 27) {
            document.getElementById('photoModeModal').style.display = 'none';
            document.body.classList.remove('photo-mode-active');
        }
    }
});

function photoMode() {
    document.body.classList.add('photo-mode-active');
    document.getElementById('photoModeModal').style.display = 'block';
}
function closePhotoMode() {
    document.body.classList.remove('photo-mode-active');
    document.getElementById('photoModeModal').style.display = 'none';
}

$(document).ready(function () {
    // Photo Mode filtre barı için click event
    $('.photo-filters-bar').on('click', '.filter-thumb', function () {
        $('.filter-thumb').removeClass('selected');
        $(this).addClass('selected');
        const filter = $(this).data('filter');
        $.post('https://PX-MultiCharacter/setFilter', JSON.stringify({ filter }));
    });
});

// Sayfa yüklendiğinde çevirileri al ve uygula
fetch('https://PX-MultiCharacter/getTranslations', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: '{}'
})
    .then(res => res.json())
    .then(translations => {
        console.log(translations)
        if (translations.PlayGame) {
            document.getElementById('playGameText').innerText = translations.PlayGame;
        }
    })
    .catch(err => {
        console.error("fetch error (getTranslations):", err);
    });

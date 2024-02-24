var ProgressCircle = undefined;

$('document').ready(function () {
    Progressbar = {};

    Progressbar.Progress = function (data) {
        $('.progress-bar__fill').stop(true, true);
        $('.progressbar-text').text(data.label);
        $('.progress-bar__fill').css('width', '0%');
        $('.progress-bar-container').css('display', 'flex');

        $('.progress-bar__fill').animate({
            width: '100%'
        }, data.duration, () => {
            $('.progress-bar-container').hide();
            $.post('https://fw-progressbar/FinishAction', JSON.stringify({}));
        });
    };

    Progressbar.ProgressCancel = function () {
        $('.progress-bar__fill').stop(true, true).css({width: 0});
        $('.progress-bar-container').hide();
    };

    window.addEventListener('message', function (event) {
        switch (event.data.action) {
            case 'progress':
                Progressbar.Progress(event.data);
                break;
            case 'cancel':
                Progressbar.ProgressCancel();
                break;
        }
    });
});
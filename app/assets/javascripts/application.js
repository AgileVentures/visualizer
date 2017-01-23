// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require turbolinks
//= require_tree .

//   ____            __ _        _                 _
//  / ___|_ __ __ _ / _| |_     / \   ___ __ _  __| | ___ _ __ ___  _   _
// | |   | '__/ _` | |_| __|   / _ \ / __/ _` |/ _` |/ _ \ '_ ` _ \| | | |
// | |___| | | (_| |  _| |_   / ___ \ (_| (_| | (_| |  __/ | | | | | |_| |
//  \____|_|  \__,_|_|  \__| /_/   \_\___\__,_|\__,_|\___|_| |_| |_|\__, |
//                                                                  |___/
//

document.addEventListener("turbolinks:load", function() {
    $(function () {
        $(document).foundation();
    });

    $('#webhook-input').on('change keyup paste', function () {
        $('#slack-webhook-button').prop("disabled", false);
    });

    $('#api-input').on('change keyup paste', function () {
        $('#slack-api-button').prop("disabled", false);
    });


    $('#subscribe').click(function () {
        var email = $('#email').val();
        $.ajax({
                url: '/subscribe',
                type: 'post',
                dataType: 'json',
                data: {email: email}
            })
            .done(function (data) {
                $('.subscribe').html('<strong>' + data.message + '</strong>');
            })
            .fail(function (data) {
                $('.subscribe').append('<strong>' + data.responseJSON.message + '</strong>');
            });
    });

    $('#slack-webhook-button').on('click', function () {
        var input = $('#webhook-input');
        var message = '<p><strong>Not a valid Slack Webhook</strong></p>'
        if (input.val().length && parseUrl(input.val()).authority !== "hooks.slack.com") {
            if (input.parent().has('p').text().length == 0) {
                input.parent().append(message);
            }
        } else {
            input.parent().find('p').remove();
            $.ajax({
                    url: '/notify_with_webhook',
                    type: 'post',
                    dataType: 'json',
                    data: {hook: input.val(), image_path: $('#report-img').attr('src')}
                })
                .done(function (data) {
                    $('#webhook').hide();
                    $('#api').hide();

                    $('.api_response').html('<strong>' + data.message + '</strong>');
                })
                .fail(function (data) {
                    // TODO: There is no error handler in the controller atm.
                    $('.api_response').append('<strong>' + data.responseJSON.message + '</strong>');
                });

        }
    });

    $('#slack-api-button').on('click', function () {
        var input = $('#api-input');
        $.ajax({
                url: '/check_api',
                type: 'post',
                dataType: 'json',
                data: {api_token: input.val()}
            })
            .done(function (data) {
                $('#webhook').hide();
                $('#api').hide();
                $('.api_response').html('<img src="' + data.icon + '">');
                $('.api_response').append('<p><strong>' + data.team_name + '</strong></p>');
                $(function () {
                    $('.api_form')
                        .append('<form id="notify-api-form" data-remote="true"></form>');
                    $('#notify-api-form')
                        .attr('action', '/notify_with_api').attr('method', 'post')
                        .append('<input type="hidden" name="image_path" value="' + $('#report-img').attr('src') + '" />')
                        .append(appendSelect(data.channels))
                        .append($('<input type="submit" value="Post notification" name="submit" class="button" />'));
                });

            })
            .fail(function (data) {
                $('.api_response').html('<strong>' + data.responseJSON.message + '</strong>');
            });
    })


});


function appendSelect(channels) {
    var select = $("<select name='channel'></select>");
    channels.forEach(function (value, i) {
        select.append($("<option></option>")
            .attr("value", value)
            .text('#' + value));
    });
    return select;
}

function parseUrl(url) {
    var pattern = new RegExp("^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\\?([^#]*))?(#(.*))?");
    var matches = url.match(pattern);
    return {
        scheme: matches[2],
        authority: matches[4],
        path: matches[5],
        query: matches[7],
        fragment: matches[9]
    };
}
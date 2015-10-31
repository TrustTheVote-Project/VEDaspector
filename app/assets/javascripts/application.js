// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.fileDownload
//= require bootstrap
//= require turbolinks
//= require_tree .

function ready() {
    $('.download-button').on('click', function(e) {
        e.preventDefault();

        $('#modal-spinner .spinner-text').text('Generating download...');
        $('#modal-spinner').modal();

        $.fileDownload($(this).prop("href"), {
            successCallback: function (url) {
                $('#modal-spinner').modal('hide');
            },
            failCallback: function (url) {
                $('#modal-spinner').modal('hide');
                alert("An error occured, and the file could not be downloaded. Please check VEDaspector’s logs.");
            }
        });
    });

    $('.delete-button').on('click', function(e) {
        e.preventDefault();

        $('#modal-confirm .confirm-text').text('This will delete the current record from VEDaspector. This cannot be undone.');
        $('#modal-confirm').modal();

        $('#modal-confirm .confirm-button').click(function() {
            $('#modal-confirm').modal('hide');
            $('#modal-spinner').modal();
            $('#modal-spinner .spinner-text').text('Deleting...');

            $('#entity-delete-form').submit();
        });
    });
}

$(document).ready(ready);
$(document).on('page:load', ready);
